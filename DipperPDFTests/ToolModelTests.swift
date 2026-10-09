import XCTest
@testable import DipperPDF

final class ToolModelTests: PDFTestCase {
    @MainActor func testInitialState() {
        let model = ToolModel()
        XCTAssertTrue(model.files.isEmpty)
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
        XCTAssertNil(model.error)
        XCTAssertFalse(model.busy)
        XCTAssertEqual(model.progress, 0)
    }

    @MainActor func testRunResetsStaleStateAndReportsCompletion() async {
        let model = ToolModel()
        model.error = "Old failure"
        model.status = "Old save"
        model.savedURL = folder.appendingPathComponent("old.pdf")
        model.progress = 1
        model.run { model.report(0.5) }
        XCTAssertTrue(model.busy)
        XCTAssertEqual(model.progress, 0)
        XCTAssertNil(model.error)
        XCTAssertNil(model.status)
        XCTAssertNil(model.savedURL)
        await model.waitForCompletion()
        XCTAssertFalse(model.busy)
        XCTAssertEqual(model.progress, 0.5)
    }

    @MainActor func testRunRejectsOverlappingJob() async {
        let model = ToolModel()
        var invocations = 0
        model.run { invocations += 1 }
        model.run { invocations += 100 }
        await model.waitForCompletion()
        XCTAssertEqual(invocations, 1)
        model.run { invocations += 1 }
        await model.waitForCompletion()
        XCTAssertEqual(invocations, 2)
    }

    @MainActor func testRunSurfacesErrorsAndCanRecover() async {
        let model = ToolModel()
        model.run { throw PDFError.processing }
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.processing.localizedDescription)
        XCTAssertFalse(model.busy)
        model.run { model.report(1) }
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.progress, 1)
    }

    @MainActor func testCancellationRestoresIdleStateWithoutError() async {
        let model = ToolModel()
        model.run { try Task.checkCancellation() }
        model.cancel() // The main-actor task cannot begin until this test yields.
        await model.waitForCompletion()
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.error)
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.cancel() // Cancelling an idle model is harmless.
    }

    @MainActor func testSingleImportUsesOnlyFirstURLAndInvalidatesResult() async throws {
        let files = try [makeFile("first.pdf"), makeFile("second.pdf")]
        let model = ToolModel()
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.savedURL = folder.appendingPathComponent("old.pdf")
        model.add(files.map(\.url), multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.map(\.url), [files[0].url])
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(model.busy)
    }

    @MainActor func testMultipleImportAppendsValidFilesAndReportsFailures() async throws {
        let existing = try makeFile("existing.pdf")
        let valid = try makeFile("valid.pdf")
        let missing = folder.appendingPathComponent("missing.pdf")
        let model = ToolModel()
        model.files = [existing]
        model.add([missing, valid.url], multiple: true)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.map(\.url), [existing.url, valid.url])
        XCTAssertTrue(try XCTUnwrap(model.error).contains("missing.pdf"))
        XCTAssertTrue(try XCTUnwrap(model.error).contains(PDFError.permission.localizedDescription))
        XCTAssertFalse(model.busy)
    }

    @MainActor func testFailedOrEmptyImportRetainsPreviousInputAndResult() async throws {
        let file = try makeFile()
        let model = ToolModel()
        model.files = [file]
        model.result = PDFResult(data: file.data, suggestedName: "copy.pdf")
        model.add([folder.appendingPathComponent("missing.pdf")], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.map(\.id), [file.id])
        XCTAssertEqual(model.result?.data, file.data)
        model.add([], multiple: true)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.map(\.id), [file.id])
        XCTAssertEqual(model.result?.data, file.data)
    }

    @MainActor func testCancelledImportKeepsExistingFiles() async throws {
        let file = try makeFile()
        let model = ToolModel()
        model.files = [file]
        model.add([file.url], multiple: true)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertEqual(model.files.map(\.id), [file.id])
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.error)
    }

    @MainActor func testSaveUsesSuggestedNameAndUpdatesConfirmation() async throws {
        let source = try makeFile()
        let destination = folder.appendingPathComponent("copy.pdf")
        var suggestedName: String?
        let model = ToolModel(saveDestination: { suggestedName = $0; return destination })
        model.files = [source]
        model.result = PDFResult(data: source.data, suggestedName: "proposed.pdf")
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(suggestedName, "proposed.pdf")
        XCTAssertEqual(try Data(contentsOf: destination), source.data)
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved copy.pdf.")
        XCTAssertNil(model.error)
        XCTAssertFalse(model.busy)
    }

    @MainActor func testSaveWithoutResultOrWithCancelledPanelDoesNothing() {
        var requests = 0
        let model = ToolModel(saveDestination: { _ in requests += 1; return nil })
        model.save()
        XCTAssertEqual(requests, 0)
        model.result = PDFResult(data: Data(), suggestedName: "copy.pdf")
        model.save()
        XCTAssertEqual(requests, 1)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testBusySaveDoesNotOpenPanel() {
        var requests = 0
        let model = ToolModel(saveDestination: { _ in requests += 1; return nil })
        model.result = PDFResult(data: Data(), suggestedName: "copy.pdf")
        model.busy = true
        model.save()
        XCTAssertEqual(requests, 0)
    }

    @MainActor func testSaveErrorLeavesResultAvailableForRetry() async throws {
        let source = try makeFile()
        let model = ToolModel(saveDestination: { _ in source.url })
        model.files = [source]
        model.result = PDFResult(data: source.data, suggestedName: "copy.pdf")
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
        XCTAssertEqual(model.result?.data, source.data)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
        XCTAssertFalse(model.busy)
    }

    @MainActor func testClearingResultClearsSavedConfirmation() {
        let model = ToolModel()
        model.result = PDFResult(data: Data(), suggestedName: "copy.pdf")
        model.savedURL = folder.appendingPathComponent("copy.pdf")
        model.status = "Saved."
        model.result = nil
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }
}
