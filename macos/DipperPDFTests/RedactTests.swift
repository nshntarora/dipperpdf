import AppKit
import CoreText
import PDFKit
import XCTest
@testable import DipperPDF

final class RedactTests: PDFTestCase {
    func testLiteralCaseUnicodeAndPatternToggles() throws {
        let text = "😀 literal [secret] SECRET secret"
        XCTAssertEqual(try RedactionSettings(text: "[secret]").matches(in: text).map { (text as NSString).substring(with: $0) }, ["[secret]"])
        XCTAssertEqual(try RedactionSettings(text: "secret").matches(in: text).count, 3)
        XCTAssertEqual(try RedactionSettings(text: "SECRET", matchCase: true).matches(in: text).count, 1)
        let contacts = "Emails: alice+work@example.co.uk and BOB@EXAMPLE.COM\nPhone: +1 (415) 555-0123\nLocal: 555.0199\nCard: 4111 1111 1111 1111\nShort: 1234\nLong: 12345678901234567890"
        func values(_ settings: RedactionSettings) throws -> [String] {
            try settings.matches(in: contacts).map { (contacts as NSString).substring(with: $0) }
        }
        XCTAssertEqual(try values(RedactionSettings(emails: true)), ["alice+work@example.co.uk", "BOB@EXAMPLE.COM"])
        XCTAssertEqual(try values(RedactionSettings(phones: true)), ["+1 (415) 555-0123", "555.0199"])
        XCTAssertEqual(try values(RedactionSettings(creditCards: true)), ["4111 1111 1111 1111"])
        XCTAssertEqual(try values(RedactionSettings(text: "alice", emails: true)), ["alice+work@example.co.uk", "BOB@EXAMPLE.COM"])
        XCTAssertTrue(try values(RedactionSettings()).isEmpty)
        XCTAssertTrue(try RedactionSettings(creditCards: true).matches(in: "1 2345 6789 0123 4567 8901").isEmpty)
        for number in ["378282246310005", "6011-1111-1111-1117", "1234567890123", "1234567890123456789"] {
            XCTAssertEqual(try RedactionSettings(creditCards: true).matches(in: number), [NSRange(location: 0, length: number.utf16.count)])
        }
    }

    func testBurnedPixelsRemovedTextAndExtrasSnapshotAndSourceProtection() async throws {
        let source = try makeFile(labels: ["Private alice@example.com public", "Keep this page visible"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        input.documentAttributes = [PDFDocumentAttribute.titleAttribute: "Secret source metadata", PDFDocumentAttribute.authorAttribute: "Private author"]
        let first = try XCTUnwrap(input.page(at: 0))
        let note = PDFAnnotation(bounds: CGRect(x: 100, y: 100, width: 30, height: 30), forType: .text, withProperties: nil)
        note.contents = "Secret annotation"
        first.addAnnotation(note)
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 2)
        let onDisk = Data("Changed on disk".utf8)
        try onDisk.write(to: source.url)
        let settings = RedactionSettings(emails: true)
        let output = try await engine.redact(snapshot, settings: settings) { _ in }
        let doc = try XCTUnwrap(PDFDocument(data: output.pdf.data))
        XCTAssertEqual(output.matchCount, 1)
        XCTAssertEqual(output.pdf.suggestedName, "source-redacted.pdf")
        XCTAssertEqual(doc.pageCount, 2)
        XCTAssertNil(doc.documentAttributes?[PDFDocumentAttribute.titleAttribute])
        XCTAssertNil(doc.documentAttributes?[PDFDocumentAttribute.authorAttribute])
        XCTAssertNil(doc.outlineRoot)
        for index in 0..<2 {
            let page = try XCTUnwrap(doc.page(at: index))
            XCTAssertTrue((page.string ?? "").isEmpty)
            XCTAssertTrue(page.annotations.isEmpty)
            XCTAssertEqual(page.rotation, 0)
            XCTAssertEqual(page.bounds(for: .mediaBox), CGRect(x: 0, y: 0, width: 612, height: 792))
            let reference = try XCTUnwrap(page.pageRef)
            var resources: CGPDFDictionaryRef?
            XCTAssertTrue(CGPDFDictionaryGetDictionary(try XCTUnwrap(reference.dictionary), "Resources", &resources))
            var fonts: CGPDFDictionaryRef?
            XCTAssertFalse(CGPDFDictionaryGetDictionary(try XCTUnwrap(resources), "Font", &fonts))
            var xobjects: CGPDFDictionaryRef?
            XCTAssertTrue(CGPDFDictionaryGetDictionary(try XCTUnwrap(resources), "XObject", &xobjects))
            XCTAssertEqual(CGPDFDictionaryGetCount(try XCTUnwrap(xobjects)), 1)
        }
        let range = try XCTUnwrap(try settings.matches(in: first.string ?? "").first)
        let bounds = try XCTUnwrap(first.selection(for: range)).bounds(for: first)
        XCTAssertTrue(try isBlack(try XCTUnwrap(doc.page(at: 0)), in: bounds.insetBy(dx: 1, dy: 1)))
        XCTAssertFalse(try isBlack(try XCTUnwrap(doc.page(at: 1)), in: bounds.insetBy(dx: 1, dy: 1)))
        try assertEmbeddedImagePixelIsBlack(try XCTUnwrap(doc.page(at: 0)), at: CGPoint(x: bounds.midX * 2, y: bounds.midY * 2))
        XCTAssertEqual(try Data(contentsOf: source.url), onDisk)
        let destination = folder.appendingPathComponent("redacted.pdf")
        try await engine.save(output.pdf, to: destination, sources: [source.url])
        XCTAssertEqual(try Data(contentsOf: destination), output.pdf.data)
        for target in [source.url, folder.appendingPathComponent("symbolic.pdf"), folder.appendingPathComponent("hard.pdf")] {
            if target.lastPathComponent == "symbolic.pdf" { try FileManager.default.createSymbolicLink(at: target, withDestinationURL: source.url) }
            if target.lastPathComponent == "hard.pdf" { try FileManager.default.linkItem(at: source.url, to: target) }
            await assertPDFError(.sourceOverwrite) { try await self.engine.save(output.pdf, to: target, sources: [source.url]) }
        }
    }

    func testPatternsAcrossRotationsMixedSizesAndCropOrigins() async throws {
        let source = try makeFile(labels: ["alice@example.com", "+1 (415) 555-0123", "4111 1111 1111 1111", "Secret"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        for index in 0..<4 {
            let page = try XCTUnwrap(input.page(at: index))
            page.rotation = index * 90
            page.setBounds(CGRect(x: 10, y: 20, width: 500 + index * 20, height: 760), for: .cropBox)
        }
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 4)
        let reopened = try XCTUnwrap(PDFDocument(data: snapshot.data))
        let settings = RedactionSettings(lastPage: 4, text: "secret", emails: true, phones: true, creditCards: true)
        let output = try await engine.redact(snapshot, settings: settings) { _ in }
        let doc = try XCTUnwrap(PDFDocument(data: output.pdf.data))
        XCTAssertEqual(output.matchCount, 4)
        for index in 0..<4 {
            let before = try XCTUnwrap(reopened.page(at: index))
            let after = try XCTUnwrap(doc.page(at: index))
            let reference = try XCTUnwrap(before.pageRef)
            let crop = reference.getBoxRect(.cropBox)
            let size = index % 2 == 0 ? crop.size : CGSize(width: crop.height, height: crop.width)
            XCTAssertEqual(after.bounds(for: .mediaBox).size, size)
            let transform = reference.getDrawingTransform(.cropBox, rect: CGRect(origin: .zero, size: size), rotate: 0, preserveAspectRatio: true)
            let range = try XCTUnwrap(try settings.matches(in: before.string ?? "").first)
            let bounds = try XCTUnwrap(before.selection(for: range)).bounds(for: before)
            XCTAssertTrue(try isBlack(after, in: bounds.applying(transform).insetBy(dx: 1, dy: 1)), "Rotation \(index * 90)")
        }
    }

    func testMultilinePhraseRepeatedMatchesAndUnicodeOffsets() async throws {
        let bytes = NSMutableData()
        var media = CGRect(x: 0, y: 0, width: 612, height: 792)
        let consumer = try XCTUnwrap(CGDataConsumer(data: bytes))
        let context = try XCTUnwrap(CGContext(consumer: consumer, mediaBox: &media, nil))
        context.beginPDFPage(nil)
        for (index, label) in ["Café before Secret", "Phrase continuation", "Secret"].enumerated() {
            let text = NSAttributedString(string: label, attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, 18, nil)])
            context.textPosition = CGPoint(x: 30, y: 740 - index * 40)
            CTLineDraw(CTLineCreateWithAttributedString(text), context)
        }
        context.endPDFPage()
        context.closePDF()
        let source = PDFFile(url: folder.appendingPathComponent("multiline.pdf"), data: bytes as Data, pageCount: 1)
        let input = try XCTUnwrap(PDFDocument(data: source.data)?.page(at: 0))
        let text = try XCTUnwrap(input.string)
        XCTAssertTrue(text.contains("Café"))
        let output = try await engine.redact(source, settings: RedactionSettings(text: "Secret")) { _ in }
        XCTAssertEqual(output.matchCount, 2)
        let phrase = "Secret\nPhrase continuation"
        XCTAssertTrue(text.contains(phrase))
        let settings = RedactionSettings(text: "Secret Phrase continuation")
        let multiline = try await engine.redact(source, settings: settings) { _ in }
        XCTAssertEqual(multiline.matchCount, 1)
        let result = try XCTUnwrap(PDFDocument(data: multiline.pdf.data)?.page(at: 0))
        let range = try XCTUnwrap(try settings.matches(in: text).first)
        let selection = try XCTUnwrap(input.selection(for: range))
        XCTAssertEqual(selection.selectionsByLine().count, 2)
        for line in selection.selectionsByLine() {
            XCTAssertTrue(try isBlack(result, in: line.bounds(for: input).insetBy(dx: 1, dy: 1)))
        }
    }

    func testInvalidNoMatchEncryptedOversizedAndCancellation() async throws {
        let source = try makeFile(labels: ["Secret", "Secret"])
        for settings in [RedactionSettings(), RedactionSettings(firstPage: 0, text: "secret"),
                         RedactionSettings(firstPage: 2, lastPage: 1, text: "secret"), RedactionSettings(lastPage: 3, text: "secret")] {
            await expect(.redactionSettings) { _ = try await self.engine.redact(source, settings: settings) { _ in } }
        }
        await expect(.noRedactionMatches) {
            _ = try await self.engine.redact(source, settings: RedactionSettings(text: "absent")) { _ in }
        }
        let scanned = try makeFile(labels: [""], image: true)
        await expect(.noRedactionMatches) {
            _ = try await self.engine.redact(scanned, settings: RedactionSettings(emails: true)) { _ in }
        }
        let large = try makeFile(labels: ["Secret"], size: CGSize(width: 12_000, height: 12_000))
        await expect(.redactionPageSize) {
            _ = try await self.engine.redact(large, settings: RedactionSettings(text: "secret")) { _ in }
        }
        let encrypted = try XCTUnwrap(PDFDocument(data: source.data)?.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.redact(PDFFile(url: source.url, data: encrypted, pageCount: 2), settings: RedactionSettings(text: "secret")) { _ in }
        }
        await assertPDFError(.invalid) {
            _ = try await self.engine.redact(PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 2), settings: RedactionSettings(text: "secret")) { _ in }
        }
        let engine = try XCTUnwrap(engine)
        for boundary in [0.15, 0.65, 1.0] {
            let task = Task {
                try await engine.redact(source, settings: RedactionSettings(lastPage: 2, text: "secret")) { progress in
                    if progress >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") } catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowInvalidationSaveRetryAndReplacement() async throws {
        let source = try makeFile(labels: ["Secret", "Public"])
        var destination: URL?
        let model = RedactModel(saveDestination: { _ in destination })
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.lastPage, 2)
        XCTAssertFalse(model.canPrepare)
        model.update(RedactionSettings(lastPage: 2, text: "secret"))
        model.prepare()
        model.update(RedactionSettings(text: "changed"))
        XCTAssertEqual(model.settings.text, "secret")
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.matchCount, 1)
        let result = try XCTUnwrap(model.result)
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.result?.data, result.data)
        destination = source.url
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
        XCTAssertEqual(model.result?.data, result.data)
        destination = folder.appendingPathComponent("output.pdf")
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        for settings in [RedactionSettings(text: "secret", matchCase: true), RedactionSettings(emails: true),
                         RedactionSettings(phones: true), RedactionSettings(creditCards: true), RedactionSettings(firstPage: 2, lastPage: 2, text: "secret")] {
            model.result = result
            model.savedURL = destination
            model.update(settings)
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertEqual(model.matchCount, 0)
        }
        model.prepare()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.noRedactionMatches.localizedDescription)
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.text, "")
        XCTAssertEqual(model.settings.lastPage, 2)
        XCTAssertNil(model.result)
    }

    private func expect(_ expected: PDFError, operation: () async throws -> Void) async {
        do { try await operation(); XCTFail("Expected \(expected)") }
        catch { XCTAssertEqual(error.localizedDescription, expected.localizedDescription) }
    }

    /// Inspect the embedded image itself, so an overlay over recoverable pixels cannot pass.
    private func assertEmbeddedImagePixelIsBlack(_ page: PDFPage, at point: CGPoint) throws {
        let reference = try XCTUnwrap(page.pageRef)
        var resources: CGPDFDictionaryRef?
        var objects: CGPDFDictionaryRef?
        XCTAssertTrue(CGPDFDictionaryGetDictionary(try XCTUnwrap(reference.dictionary), "Resources", &resources))
        XCTAssertTrue(CGPDFDictionaryGetDictionary(try XCTUnwrap(resources), "XObject", &objects))
        var image: CGPDFStreamRef?
        CGPDFDictionaryApplyBlock(try XCTUnwrap(objects), { _, object, _ in
            var stream: CGPDFStreamRef?
            if CGPDFObjectGetValue(object, .stream, &stream) { image = stream }
            return true
        }, nil)
        let stream = try XCTUnwrap(image)
        let dictionary = try XCTUnwrap(CGPDFStreamGetDictionary(stream))
        var width = 0, height = 0, bits = 0
        XCTAssertTrue(CGPDFDictionaryGetInteger(dictionary, "Width", &width))
        XCTAssertTrue(CGPDFDictionaryGetInteger(dictionary, "Height", &height))
        XCTAssertTrue(CGPDFDictionaryGetInteger(dictionary, "BitsPerComponent", &bits))
        XCTAssertEqual(width, 1224)
        XCTAssertEqual(height, 1584)
        XCTAssertEqual(bits, 8)
        var format = CGPDFDataFormat.raw
        let pixels = try XCTUnwrap(CGPDFStreamCopyData(stream, &format)) as Data
        XCTAssertEqual(format, .raw)
        let components = pixels.count / (width * height)
        XCTAssertTrue([1, 3, 4].contains(components))
        let offset = ((height - 1 - Int(point.y)) * width + Int(point.x)) * components
        for component in 0..<min(components, 3) { XCTAssertEqual(pixels[offset + component], 0) }
    }

    private func isBlack(_ page: PDFPage, in region: CGRect) throws -> Bool {
        let bounds = page.bounds(for: .mediaBox)
        let width = Int(ceil(bounds.width)), height = Int(ceil(bounds.height))
        let context = try XCTUnwrap(CGContext(data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(bounds)
        context.drawPDFPage(try XCTUnwrap(page.pageRef))
        let bytes = try XCTUnwrap(context.data).assumingMemoryBound(to: UInt8.self)
        let rect = region.intersection(bounds)
        guard !rect.isEmpty else { return false }
        for y in Int(ceil(rect.minY))..<Int(floor(rect.maxY)) {
            for x in Int(ceil(rect.minX))..<Int(floor(rect.maxX)) {
                // Bitmap memory rows run from the top; PDF coordinates run from the bottom.
                let offset = ((height - 1 - y) * width + x) * 4
                if bytes[offset] > 2 || bytes[offset + 1] > 2 || bytes[offset + 2] > 2 { return false }
            }
        }
        return true
    }
}
