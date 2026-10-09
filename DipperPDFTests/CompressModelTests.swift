import PDFKit
import XCTest
@testable import DipperPDF

final class CompressModelTests: PDFTestCase {
    @MainActor func testDefaultsAndCompressWithoutInput() async {
        let model = CompressModel()
        XCTAssertEqual(model.level, .balanced)
        XCTAssertEqual(model.savings, "")
        model.compress()
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.result)
    }

    @MainActor func testCompressionProducesResultProgressAndSavings() async throws {
        let model = CompressModel()
        let file = try makeFile(image: true)
        model.files = [file]
        model.compress()
        XCTAssertTrue(model.busy)
        await model.waitForCompletion()
        let result = try XCTUnwrap(model.result)
        XCTAssertLessThan(result.data.count, file.data.count)
        XCTAssertTrue(PDFDocument(data: result.data)?.string?.contains("Searchable text") == true)
        XCTAssertEqual(model.progress, 1)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.error)
        XCTAssertTrue(model.savings.hasSuffix("% saved"))
    }

    @MainActor func testChangingLevelInvalidatesResultAndSaveConfirmation() {
        let model = CompressModel()
        model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
        model.savedURL = folder.appendingPathComponent("old.pdf")
        model.status = "Saved."
        model.level = .strong
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testSavingsReflectOutputByteCount() throws {
        let model = CompressModel()
        model.files = [PDFFile(url: folder.appendingPathComponent("source.pdf"), data: Data(repeating: 0, count: 100), pageCount: 1)]
        model.result = PDFResult(data: Data(repeating: 0, count: 25), suggestedName: "out.pdf")
        XCTAssertEqual(model.savings, "75.0% saved")
        model.result = PDFResult(data: model.files[0].data, suggestedName: "out.pdf")
        XCTAssertEqual(model.savings, "0.0% saved")
    }

    @MainActor func testCompressionErrorRestoresIdleState() async {
        let model = CompressModel()
        model.files = [PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data(), pageCount: 1)]
        model.compress()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.invalid.localizedDescription)
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.result)
    }
}
