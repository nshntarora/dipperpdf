import PDFKit
import XCTest
@testable import DipperPDF

final class RotateModelTests: PDFTestCase {
    @MainActor func testPlainClickReplacesSelection() {
        let model = RotateModel()
        model.select(1, modifiers: [])
        model.select(4, modifiers: [])
        XCTAssertEqual(model.selection, [4])
    }

    @MainActor func testCommandClickTogglesSelection() {
        let model = RotateModel()
        model.select(1, modifiers: [])
        model.select(4, modifiers: .command)
        XCTAssertEqual(model.selection, [1, 4])
        model.select(1, modifiers: .command)
        XCTAssertEqual(model.selection, [4])
    }

    @MainActor func testShiftSelectsForwardAndBackwardRangesFromAnchor() {
        let model = RotateModel()
        model.select(3, modifiers: [])
        model.select(5, modifiers: .shift)
        XCTAssertEqual(model.selection, Set(3...5))
        model.select(1, modifiers: .shift)
        XCTAssertEqual(model.selection, Set(1...3))
    }

    @MainActor func testCommandShiftAddsRangeAndShiftWithoutAnchorSelectsPage() {
        let model = RotateModel()
        model.select(0, modifiers: .shift)
        XCTAssertEqual(model.selection, [0])
        model.select(3, modifiers: .command)
        model.select(5, modifiers: [.command, .shift])
        XCTAssertEqual(model.selection, [0, 3, 4, 5])
    }

    @MainActor func testSelectAllAndReversibleRotation() throws {
        let model = RotateModel()
        model.selectAll()
        XCTAssertTrue(model.selection.isEmpty)
        model.files = [try makeFile(labels: ["First", "Second", "Third"])]
        model.selectAll()
        XCTAssertEqual(model.selection, [0, 1, 2])
        model.rotate(by: -90)
        XCTAssertEqual(model.rotations, [0: 270, 1: 270, 2: 270])
        XCTAssertTrue(model.hasChanges)
        model.rotate(by: 450)
        XCTAssertFalse(model.hasChanges)
    }

    @MainActor func testRotationOnlyChangesSelectedPagesAndClearsSavedState() {
        let model = RotateModel()
        model.selection = [1]
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.savedURL = folder.appendingPathComponent("old.pdf")
        model.status = "Saved."
        model.rotate(by: 90)
        XCTAssertEqual(model.rotations, [1: 90])
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testNewInputResetsSelectionRotationsAnchorAndThumbnails() async throws {
        let model = RotateModel()
        model.select(5, modifiers: [])
        model.rotate(by: 90)
        model.files = [try makeFile(labels: ["First", "Second"])]
        try await model.inputsChanged()
        XCTAssertTrue(model.selection.isEmpty)
        XCTAssertTrue(model.rotations.isEmpty)
        XCTAssertEqual(Set(model.thumbnails.keys), [0, 1])
        XCTAssertEqual(model.progress, 1)
        model.select(1, modifiers: .shift)
        XCTAssertEqual(model.selection, [1])
        model.files = []
        try await model.inputsChanged()
        XCTAssertTrue(model.thumbnails.isEmpty)
    }

    @MainActor func testPrepareAndSaveWritesSelectedRotation() async throws {
        let destination = folder.appendingPathComponent("rotated.pdf")
        var proposedName: String?
        let model = RotateModel(saveDestination: { proposedName = $0; return destination })
        let source = try makeFile(labels: ["First", "Second"])
        model.files = [source]
        model.select(1, modifiers: [])
        model.rotate(by: -90)
        model.prepareAndSave()
        await model.waitForCompletion()
        let doc = try XCTUnwrap(PDFDocument(url: destination))
        XCTAssertEqual(doc.page(at: 0)?.rotation, 0)
        XCTAssertEqual(doc.page(at: 1)?.rotation, 270)
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved rotated.pdf.")
        XCTAssertEqual(proposedName, "source-rotated.pdf")
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.error)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    @MainActor func testCancelledSavePanelAndMissingInputDoNothing() throws {
        var requests = 0
        let model = RotateModel(saveDestination: { _ in requests += 1; return nil })
        model.prepareAndSave()
        XCTAssertEqual(requests, 0)
        model.files = [try makeFile()]
        model.prepareAndSave()
        XCTAssertEqual(requests, 1)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.error)
    }

    @MainActor func testPrepareAndSaveProtectsSource() async throws {
        let source = try makeFile()
        let model = RotateModel(saveDestination: { _ in source.url })
        model.files = [source]
        model.selection = [0]
        model.rotate(by: 90)
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
        XCTAssertNil(model.savedURL)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }
}
