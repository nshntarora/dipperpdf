import AppKit
import XCTest
@testable import DipperPDF

final class AppModelTests: XCTestCase {
    func testCatalogRegistersAllPDFToolsWithUniqueIdentity() {
        XCTAssertEqual(Set(PDFTool.allCases), [.compress, .merge, .rotate, .remove, .extract, .split, .number, .reverse, .metadata, .text, .watermark, .crop, .annotations, .unlock])
        XCTAssertEqual(Set(PDFTool.allCases.map(\.id)).count, PDFTool.allCases.count)
        for tool in PDFTool.allCases {
            XCTAssertFalse(tool.title.isEmpty)
            XCTAssertFalse(tool.subtitle.isEmpty)
            XCTAssertFalse(tool.symbol.isEmpty)
            XCTAssertNotNil(NSImage(systemSymbolName: tool.symbol, accessibilityDescription: nil), tool.title)
        }
    }

    func testFileIdentityAndDisplayName() {
        let url = URL(fileURLWithPath: "/tmp/My document.pdf")
        let file = PDFFile(url: url, data: Data(repeating: 0, count: 1024), pageCount: 1)
        let other = PDFFile(url: url, data: file.data, pageCount: 1)
        XCTAssertEqual(file.name, "My document.pdf")
        XCTAssertEqual(file.size, ByteCountFormatter.string(fromByteCount: 1024, countStyle: .file))
        XCTAssertNotEqual(file.id, other.id)
    }

    func testCompressionPresetsHaveOrderedResolutionAndQuality() {
        XCTAssertEqual(CompressionLevel.allCases, [.light, .balanced, .strong])
        XCTAssertEqual(CompressionLevel.allCases.map(\.dpi), [250, 150, 96])
        XCTAssertEqual(CompressionLevel.allCases.map(\.quality), [0.85, 0.65, 0.4])
        for level in CompressionLevel.allCases {
            XCTAssertTrue(level.detail.contains("\(level.dpi) dpi"))
        }
    }

    func testEveryDomainErrorHasActionableDescription() throws {
        for error in [PDFError.invalid, .encrypted, .permission, .processing, .save, .sourceOverwrite, .pageSelection, .extractionSelection, .splitCount, .numberingSettings, .noText, .watermarkSettings, .croppingSettings, .notEncrypted, .incorrectPassword, .restrictedPDF] {
            XCTAssertFalse(try XCTUnwrap(error.errorDescription).isEmpty)
        }
    }
    func testTypedPageRangesNormalizeDuplicatesAndUseZeroBasedIndices() throws {
        let pages = try PageSelection.parse(" 1–3, 5, 2, 5-6 ", pageCount: 6)
        XCTAssertEqual(pages, [0, 1, 2, 4, 5])
        XCTAssertEqual(PageSelection.format(pages), "1–3, 5–6")
        XCTAssertEqual(try PageSelection.parse(PageSelection.format(pages), pageCount: 6), pages)
        XCTAssertEqual(try PageSelection.parse("  ", pageCount: 6), [])
        XCTAssertEqual(PageSelection.format([]), "")
    }

    func testTypedPageRangesRejectMalformedReversedAndOutOfBoundsValues() {
        for text in ["0", "7", "2-1", "1-7", "-1", "1-", "1,,2", "1,", "abc", "1-2-3", "1.5", "999999999999999999999999"] {
            XCTAssertThrowsError(try PageSelection.parse(text, pageCount: 6), text)
        }
    }

}
