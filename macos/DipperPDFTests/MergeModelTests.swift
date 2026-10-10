import PDFKit
import XCTest
@testable import DipperPDF

final class MergeModelTests: PDFTestCase {
    @MainActor func testMergeUsesCurrentOrder() async throws {
        let first = try makeFile("first.pdf", labels: ["First"])
        let second = try makeFile("second.pdf", labels: ["Second"])
        let model = MergeModel()
        model.files = [second, first]
        model.merge()
        await model.waitForCompletion()
        let result = try XCTUnwrap(model.result)
        let document = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertTrue(document.page(at: 0)?.string?.contains("Second") == true)
        XCTAssertTrue(document.page(at: 1)?.string?.contains("First") == true)
        XCTAssertEqual(model.progress, 1)
        XCTAssertNil(model.error)
        XCTAssertFalse(model.busy)
    }

    @MainActor func testInsufficientInputsCannotPrepare() async throws {
        let model = MergeModel()
        model.files = [try makeFile()]
        model.merge()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertNil(model.result)
        XCTAssertFalse(model.busy)
    }

    @MainActor func testDragReordersInBothDirectionsAndInvalidatesOutput() throws {
        let files = try [makeFile("a.pdf"), makeFile("b.pdf"), makeFile("c.pdf")]
        let model = MergeModel()
        model.files = files
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.savedURL = folder.appendingPathComponent("old.pdf")
        model.status = "Saved."
        model.move(files[0].id, over: files[2].id)
        XCTAssertEqual(model.files.map(\.id), [files[1].id, files[2].id, files[0].id])
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
        model.move(files[0].id, over: files[1].id)
        XCTAssertEqual(model.files.map(\.id), files.map(\.id))
    }

    @MainActor func testInvalidDragAndBusyDragDoNotChangeInputs() throws {
        let files = try [makeFile("a.pdf"), makeFile("b.pdf")]
        let model = MergeModel()
        model.files = files
        model.move(files[0].id, over: files[0].id)
        model.move(UUID(), over: files[0].id)
        model.move(files[0].id, over: UUID())
        model.busy = true
        model.move(files[0].id, over: files[1].id)
        XCTAssertEqual(model.files.map(\.id), files.map(\.id))
    }

    @MainActor func testEveryReorderAndRemovalIsIgnoredWhileBusy() throws {
        let files = try [makeFile("a.pdf"), makeFile("b.pdf"), makeFile("c.pdf")]
        let model = MergeModel()
        model.files = files
        model.busy = true
        model.move(from: IndexSet(integer: 0), to: 3)
        model.nudge(files[0].id, by: 1)
        model.remove(files[0].id)
        XCTAssertEqual(model.files.map(\.id), files.map(\.id))
    }

    @MainActor func testListMoveUsesModelAndInvalidatesPreviousOutput() throws {
        let files = try [makeFile("a.pdf"), makeFile("b.pdf"), makeFile("c.pdf")]
        let model = MergeModel()
        model.files = files
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.move(from: IndexSet(integer: 0), to: 3)
        XCTAssertEqual(model.files.map(\.id), [files[1].id, files[2].id, files[0].id])
        XCTAssertNil(model.result)
    }

    @MainActor func testNudgeBoundsAndRemove() throws {
        let files = try [makeFile("a.pdf"), makeFile("b.pdf")]
        let model = MergeModel()
        model.files = files
        model.nudge(files[0].id, by: -1)
        model.nudge(files[1].id, by: 1)
        model.nudge(UUID(), by: 1)
        XCTAssertEqual(model.files.map(\.id), files.map(\.id))
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.nudge(files[1].id, by: -1)
        XCTAssertEqual(model.files.map(\.id), [files[1].id, files[0].id])
        XCTAssertNil(model.result)
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.remove(files[0].id)
        XCTAssertEqual(model.files.map(\.id), [files[1].id])
        XCTAssertNil(model.result)
    }
}
