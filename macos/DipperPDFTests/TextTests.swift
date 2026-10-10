import PDFKit
import XCTest
@testable import DipperPDF

final class TextTests: PDFTestCase {
    func testUTF8TextPageOrderBlankPagesProgressAndSnapshot() async throws {
        let source = try makeFile(labels: ["Café — river survey", "", "Final observations"])
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let output = try await engine.extractText(source) { await recorder.record($0) }
        XCTAssertEqual(String(data: output.data, encoding: .utf8), "Café — river survey\n\n\n\nFinal observations\n")
        XCTAssertEqual(output.suggestedName, "source-text.txt")
        let values = await recorder.values
        XCTAssertEqual(values, [1.0 / 3.0, 2.0 / 3.0, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
    }

    func testImageOnlyAndBlankPDFsHaveNoSelectableText() async throws {
        for image in [false, true] {
            let source = try makeFile(labels: [""], image: image)
            await assertPDFError(.noText) { _ = try await self.engine.extractText(source) { _ in } }
        }
    }

    @MainActor func testNoTextDoesNotPublishAndSaveFailureRetainsResult() async throws {
        let destination = folder.appendingPathComponent("text.txt")
        let model = TextModel(saveDestination: { _ in destination })
        model.files = [try makeFile(labels: [""])]
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.noText.localizedDescription)
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        let failing = TextModel(saveDestination: { _ in self.folder.appendingPathComponent("missing/text.txt") })
        failing.files = [try makeFile()]
        failing.prepare()
        await failing.waitForCompletion()
        failing.save()
        await failing.waitForCompletion()
        XCTAssertEqual(failing.error, PDFError.save.localizedDescription)
        XCTAssertNotNil(failing.result)
        XCTAssertNil(failing.savedURL)
    }

    func testMalformedAndEncryptedInputAreRejected() async throws {
        let invalid = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) { _ = try await self.engine.extractText(invalid) { _ in } }
        let source = try makeFile()
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.extractText(PDFFile(url: source.url, data: encrypted, pageCount: 1)) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublishing() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let engine = try XCTUnwrap(engine)
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.extractText(source) { progress in
                    if progress >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testSaveCancelledPanelAndEmptyInput() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let destination = folder.appendingPathComponent("text.txt")
        var proposedName: String?
        let model = TextModel(saveDestination: { proposedName = $0; return destination })
        model.prepare()
        XCTAssertNil(proposedName)
        let cancelled = TextModel(saveDestination: { _ in nil })
        cancelled.files = [source]
        cancelled.prepare()
        await cancelled.waitForCompletion()
        cancelled.save()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNotNil(cancelled.result)
        model.files = [source]
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(proposedName, "source-text.txt")
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved text.txt.")
        XCTAssertNil(model.error)
        XCTAssertEqual(model.progress, 1)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        XCTAssertEqual(try String(contentsOf: destination, encoding: .utf8), "First\n\nSecond\n")
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
            let model = TextModel(saveDestination: { _ in destination })
            model.files = [source]
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
        let destination = folder.appendingPathComponent("text.txt")
        var requests = 0
        let model = TextModel(saveDestination: { _ in requests += 1; return destination })
        model.files = [source]
        model.prepare()
        model.prepare()
        XCTAssertEqual(requests, 0)
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
