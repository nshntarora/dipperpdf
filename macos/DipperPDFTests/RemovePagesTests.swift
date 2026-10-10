import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class RemovePagesTests: PDFTestCase {
    func testRemovalPreservesOrderTextGeometryAnnotationsAndSnapshot() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third", "Fourth", "Fifth"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(input.page(at: 2))
        page.rotation = 90
        page.setBounds(CGRect(x: 10, y: 20, width: 400, height: 760), for: .cropBox)
        let annotation = PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 50, height: 60), forType: .text, withProperties: nil)
        annotation.contents = "Retained note"
        page.addAnnotation(annotation)
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 5)
        // Processing reads the supplied snapshot, even if the disk file has changed.
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let result = try await engine.removePages(snapshot, removing: [1, 3]) { await recorder.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(output.pageCount, 3)
        for (index, label) in ["First", "Third", "Fifth"].enumerated() {
            XCTAssertTrue(try XCTUnwrap(output.page(at: index)?.string).contains(label))
        }
        let retained = try XCTUnwrap(output.page(at: 1))
        XCTAssertEqual(retained.rotation, 90)
        XCTAssertEqual(retained.bounds(for: .cropBox), page.bounds(for: .cropBox))
        XCTAssertEqual(retained.bounds(for: .mediaBox), page.bounds(for: .mediaBox))
        // PDFKit can serialize companion annotations differently across macOS versions.
        // Check the intended note rather than the total serialized annotation count.
        let notes = retained.annotations.filter { $0.type == annotation.type && $0.contents == annotation.contents }
        XCTAssertEqual(notes.count, 1)
        let retainedNote = try XCTUnwrap(notes.first)
        // Compare against the serialized input: PDFKit normalizes text-note icon bounds.
        let original = try XCTUnwrap(PDFDocument(data: snapshot.data))
        let originalPage = try XCTUnwrap(original.page(at: 2))
        let originalNote = try XCTUnwrap(originalPage.annotations.first {
            $0.type == annotation.type && $0.contents == annotation.contents
        })
        XCTAssertEqual(retainedNote.bounds, originalNote.bounds)
        XCTAssertEqual(result.suggestedName, "source-removed.pdf")
        let values = await recorder.values
        XCTAssertEqual(values, [0.2, 0.4, 0.6, 0.8, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
    }

    func testInvalidSelectionsAreRejected() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        for indices: Set<Int> in [[], [0, 1, 2], [-1], [3], [0, 9]] {
            await assertPDFError(.pageSelection) {
                _ = try await self.engine.removePages(source, removing: indices) { _ in }
            }
        }
        let single = try makeFile("single.pdf")
        await assertPDFError(.pageSelection) {
            _ = try await self.engine.removePages(single, removing: [0]) { _ in }
        }
    }

    func testMalformedAndEncryptedInputAreRejected() async throws {
        let invalid = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) {
            _ = try await self.engine.removePages(invalid, removing: [0]) { _ in }
        }
        let source = try makeFile(labels: ["First", "Second"])
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.removePages(PDFFile(url: source.url, data: encrypted, pageCount: 2), removing: [0]) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublishing() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let engine = try XCTUnwrap(engine)
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.removePages(source, removing: [1]) { progress in
                    if progress >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do {
                _ = try await task.value
                XCTFail("Expected cancellation")
            } catch is CancellationError { }
        }
    }

    @MainActor func testSelectionSupportsClickCommandShiftAndCommandShift() throws {
        let model = RemoveModel()
        model.files = [try makeFile(labels: ["1", "2", "3", "4", "5", "6"])]
        model.select(1, modifiers: .shift)
        XCTAssertEqual(model.selection, [1])
        model.select(3, modifiers: [])
        XCTAssertEqual(model.selection, [3])
        model.select(5, modifiers: .shift)
        XCTAssertEqual(model.selection, [3, 4, 5])
        model.select(1, modifiers: .shift)
        XCTAssertEqual(model.selection, [1, 2, 3])
        model.select(0, modifiers: .command)
        model.select(2, modifiers: [.command, .shift])
        XCTAssertEqual(model.selection, [0, 1, 2, 3])
        model.select(1, modifiers: .command)
        XCTAssertEqual(model.selection, [0, 2, 3])
        model.select(-1, modifiers: [])
        model.select(6, modifiers: [])
        XCTAssertEqual(model.selection, [0, 2, 3])
        XCTAssertEqual(model.remainingCount, 3)
        XCTAssertTrue(model.canRemove)
    }

    @MainActor func testSelectionInvalidatesResultAndSaveConfirmation() throws {
        let model = RemoveModel()
        model.files = [try makeFile(labels: ["1", "2", "3"])]
        for change in [{ model.select(1, modifiers: []) }, { model.selectAll() }, { model.clearSelection() }] {
            model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
            model.savedURL = folder.appendingPathComponent("old.pdf")
            model.status = "Saved."
            change()
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.status)
        }
        model.select(2, modifiers: .shift)
        XCTAssertEqual(model.selection, [2], "Clear Selection must reset the range anchor")
    }

    @MainActor func testImportResetsStateAndLoadsThumbnails() async throws {
        let model = RemoveModel()
        model.files = [try makeFile(labels: ["1", "2", "3"])]
        model.select(2, modifiers: [])
        let replacement = try makeFile("replacement.pdf", labels: ["A", "B"])
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.first?.url, replacement.url)
        XCTAssertTrue(model.selection.isEmpty)
        XCTAssertEqual(Set(model.thumbnails.keys), [0, 1])
        XCTAssertEqual(model.progress, 1)
        model.select(0, modifiers: .shift)
        XCTAssertEqual(model.selection, [0])
        model.files = []
        try await model.inputsChanged()
        XCTAssertTrue(model.thumbnails.isEmpty)
        XCTAssertTrue(model.selection.isEmpty)
    }

    @MainActor func testEmptyAllAndSinglePageSelectionsDoNotOpenSavePanel() throws {
        var requests = 0
        let model = RemoveModel(saveDestination: { _ in requests += 1; return nil })
        model.prepare()
        model.files = [try makeFile(labels: ["1", "2"])]
        model.prepare()
        model.selectAll()
        XCTAssertEqual(model.remainingCount, 0)
        XCTAssertFalse(model.canRemove)
        model.prepare()
        model.files = [try makeFile("single.pdf")]
        model.selectAll()
        model.prepare()
        XCTAssertEqual(requests, 0)
    }

    @MainActor func testSaveAndCancelledPanel() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let destination = folder.appendingPathComponent("removed.pdf")
        var proposedName: String?
        let cancelled = RemoveModel(saveDestination: { _ in nil })
        cancelled.files = [source]
        cancelled.select(1, modifiers: [])
        cancelled.prepare()
        await cancelled.waitForCompletion()
        cancelled.save()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNotNil(cancelled.result)
        let model = RemoveModel(saveDestination: { proposedName = $0; return destination })
        model.files = [source]
        model.select(1, modifiers: [])
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        let output = try XCTUnwrap(PDFDocument(url: destination))
        XCTAssertEqual(output.pageCount, 2)
        XCTAssertTrue(try XCTUnwrap(output.page(at: 1)?.string).contains("Third"))
        XCTAssertEqual(proposedName, "source-removed.pdf")
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved removed.pdf.")
        XCTAssertEqual(model.progress, 1)
        XCTAssertNil(model.error)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    @MainActor func testSourceAndAliasesAreProtected() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard] {
            let model = RemoveModel(saveDestination: { _ in destination })
            model.files = [source]
            model.select(1, modifiers: [])
            model.prepare()
            await model.waitForCompletion()
            model.save()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
            XCTAssertNil(model.savedURL)
            XCTAssertNotNil(model.result)
            XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        }
    }

    @MainActor func testBusyExclusionCancellationAndRetry() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let destination = folder.appendingPathComponent("removed.pdf")
        var requests = 0
        let model = RemoveModel(saveDestination: { _ in requests += 1; return destination })
        model.files = [source]
        model.select(1, modifiers: [])
        model.prepare()
        model.select(0, modifiers: [])
        model.selectAll()
        model.clearSelection()
        model.prepare()
        XCTAssertEqual(requests, 0)
        XCTAssertEqual(model.selection, [1])
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertNil(model.error)
    }
}
