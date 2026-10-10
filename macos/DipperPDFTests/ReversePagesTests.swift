import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class ReversePagesTests: PDFTestCase {
    func testReversalPreservesTextRotationGeometryAnnotationsAndSnapshot() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(input.page(at: 0))
        page.rotation = 90
        page.setBounds(CGRect(x: 10, y: 20, width: 400, height: 760), for: .cropBox)
        let note = PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 50, height: 60), forType: .text, withProperties: nil)
        note.contents = "Retained note"
        page.addAnnotation(note)
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 3)
        let original = try XCTUnwrap(PDFDocument(data: snapshot.data)?.page(at: 0))
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let result = try await engine.reversePages(snapshot) { await recorder.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(output.pageCount, 3)
        for (index, label) in ["Third", "Second", "First"].enumerated() {
            XCTAssertTrue(try XCTUnwrap(output.page(at: index)?.string).contains(label))
        }
        let retained = try XCTUnwrap(output.page(at: 2))
        XCTAssertEqual(retained.rotation, original.rotation)
        XCTAssertEqual(retained.bounds(for: .cropBox), original.bounds(for: .cropBox))
        XCTAssertEqual(retained.bounds(for: .mediaBox), original.bounds(for: .mediaBox))
        let retainedNote = try XCTUnwrap(retained.annotations.first { $0.contents == note.contents })
        XCTAssertEqual(retainedNote.bounds, try XCTUnwrap(original.annotations.first { $0.contents == note.contents }).bounds)
        XCTAssertEqual(result.suggestedName, "source-reversed.pdf")
        let values = await recorder.values
        XCTAssertEqual(values, [1.0 / 3.0, 2.0 / 3.0, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
    }

    func testSinglePageAndDoubleReversal() async throws {
        let single = try makeFile("single.pdf", labels: ["Only page"])
        let one = try await engine.reversePages(single) { _ in }
        XCTAssertEqual(PDFDocument(data: one.data)?.pageCount, 1)
        XCTAssertTrue(try XCTUnwrap(PDFDocument(data: one.data)?.page(at: 0)?.string).contains("Only page"))
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let reversed = try await engine.reversePages(source) { _ in }
        let twice = try await engine.reversePages(PDFFile(url: source.url, data: reversed.data, pageCount: 3)) { _ in }
        let document = try XCTUnwrap(PDFDocument(data: twice.data))
        for (index, label) in ["First", "Second", "Third"].enumerated() {
            XCTAssertTrue(try XCTUnwrap(document.page(at: index)?.string).contains(label))
        }
    }

    func testMalformedAndEncryptedInputAreRejected() async throws {
        let invalid = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) { _ = try await self.engine.reversePages(invalid) { _ in } }
        let source = try makeFile()
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.reversePages(PDFFile(url: source.url, data: encrypted, pageCount: 1)) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublishing() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let engine = try XCTUnwrap(engine)
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.reversePages(source) { progress in
                    if progress >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testSaveCancelledPanelAndEmptyInput() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let destination = folder.appendingPathComponent("reversed.pdf")
        var proposedName: String?
        let model = ReverseModel(saveDestination: { proposedName = $0; return destination })
        model.prepareAndSave()
        XCTAssertNil(proposedName)
        let cancelled = ReverseModel(saveDestination: { _ in nil })
        cancelled.files = [source]
        cancelled.prepareAndSave()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNil(cancelled.result)
        model.files = [source]
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertEqual(proposedName, "source-reversed.pdf")
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved reversed.pdf.")
        XCTAssertNil(model.error)
        XCTAssertEqual(model.progress, 1)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        XCTAssertTrue(try XCTUnwrap(PDFDocument(url: destination)?.page(at: 0)?.string).contains("Second"))
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.first?.url, replacement.url)
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testSourceAndAliasesAreProtected() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard] {
            let model = ReverseModel(saveDestination: { _ in destination })
            model.files = [source]
            model.prepareAndSave()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.result)
            XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        }
    }

    @MainActor func testBusyExclusionCancellationAndRetry() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let destination = folder.appendingPathComponent("reversed.pdf")
        var requests = 0
        let model = ReverseModel(saveDestination: { _ in requests += 1; return destination })
        model.files = [source]
        model.prepareAndSave()
        model.prepareAndSave()
        XCTAssertEqual(requests, 1)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertNil(model.error)
    }
}
