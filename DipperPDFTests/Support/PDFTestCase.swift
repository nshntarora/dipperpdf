import AppKit
import CoreText
import PDFKit
import XCTest
@testable import DipperPDF

/// Each test owns its directory and actor; no checked-in documents or user files.
class PDFTestCase: XCTestCase {
    var folder: URL!
    var engine: PDFEngine!

    override func setUpWithError() throws {
        folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("DipperPDFTests-\(UUID())", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        engine = PDFEngine()
    }

    override func tearDownWithError() throws {
        engine = nil
        try FileManager.default.removeItem(at: folder)
        folder = nil
    }

    func makeFile(_ name: String = "source.pdf", labels: [String] = ["Searchable text"],
                  image: Bool = false, size: CGSize = CGSize(width: 612, height: 792)) throws -> PDFFile {
        let data = try Self.pdf(labels: labels, image: image, size: size)
        let url = folder.appendingPathComponent(name)
        try data.write(to: url)
        return PDFFile(url: url, data: data, pageCount: labels.count)
    }

    static func pdf(labels: [String], image: Bool = false,
                    size: CGSize = CGSize(width: 612, height: 792)) throws -> Data {
        let data = NSMutableData()
        var bounds = CGRect(origin: .zero, size: size)
        let consumer = try XCTUnwrap(CGDataConsumer(data: data))
        let context = try XCTUnwrap(CGContext(consumer: consumer, mediaBox: &bounds, nil))
        var raster: CGImage?
        if image {
            // Deterministic noise defeats lossless compression and exercises Quartz.
            let width = 1200, height = 1500
            var bytes = [UInt8](repeating: 0, count: width * height * 3)
            var seed: UInt64 = 7
            for index in bytes.indices {
                seed = seed &* 6364136223846793005 &+ 1
                bytes[index] = UInt8(truncatingIfNeeded: seed >> 32)
            }
            let provider = try XCTUnwrap(CGDataProvider(data: Data(bytes) as CFData))
            raster = try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8,
                bitsPerPixel: 24, bytesPerRow: width * 3, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: 0), provider: provider, decode: nil,
                shouldInterpolate: true, intent: .defaultIntent))
        }
        for label in labels {
            context.beginPDFPage(nil)
            if let raster { context.draw(raster, in: CGRect(x: 0, y: 0, width: size.width, height: size.height - 72)) }
            let text = NSAttributedString(string: label, attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, 18, nil)
            ])
            context.textPosition = CGPoint(x: 30, y: size.height - 37)
            CTLineDraw(CTLineCreateWithAttributedString(text), context)
            context.endPDFPage()
        }
        context.closePDF()
        return data as Data
    }

    func assertPDFError(_ expected: PDFError, file: StaticString = #filePath, line: UInt = #line,
                        operation: () async throws -> Void) async {
        do {
            try await operation()
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch let error as PDFError {
            switch (error, expected) {
            case (.croppingSettings, .croppingSettings), (.watermarkSettings, .watermarkSettings), (.noText, .noText), (.numberingSettings, .numberingSettings), (.splitCount, .splitCount), (.invalid, .invalid), (.encrypted, .encrypted), (.permission, .permission),
                 (.pageSelection, .pageSelection), (.extractionSelection, .extractionSelection), (.processing, .processing), (.save, .save), (.sourceOverwrite, .sourceOverwrite): break
            default: XCTFail("Expected \(expected), got \(error)", file: file, line: line)
            }
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}

actor ProgressRecorder {
    private(set) var values: [Double] = []
    private(set) var thumbnails: [Int: Data] = [:]
    func record(_ value: Double) { values.append(value) }
    func record(index: Int, data: Data) { thumbnails[index] = data }
}
