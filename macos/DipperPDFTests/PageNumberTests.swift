import AppKit
import PDFKit
import CoreText
import XCTest
@testable import DipperPDF

final class PageNumberTests: PDFTestCase {
    func testRangeNumberingPreservesContentAndSourceSnapshot() async throws {
        let source = try makeFile(labels: ["Cover", "First section", "Second section", "Appendix"])
        try Data("Changed on disk".utf8).write(to: source.url)
        let settings = PageNumberSettings(firstPage: 2, lastPage: 3, startingNumber: 7)
        let recorder = ProgressRecorder()
        let result = try await engine.addPageNumbers(source, settings: settings) { await recorder.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(output.pageCount, 4)
        XCTAssertEqual(result.suggestedName, "source-numbered.pdf")
        for (index, label) in ["Cover", "First section", "Second section", "Appendix"].enumerated() {
            let page = try XCTUnwrap(output.page(at: index))
            XCTAssertTrue(try XCTUnwrap(page.string).contains(label))
            let number = index == 1 ? "7" : index == 2 ? "8" : nil
            if let number { XCTAssertTrue(try XCTUnwrap(page.string).contains(number)) }
            else { XCTAssertEqual(page.string?.trimmingCharacters(in: .whitespacesAndNewlines), label) }
        }
        let values = await recorder.values
        XCTAssertEqual(values, [0.5, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
        let large = try await engine.addPageNumbers(source, settings: PageNumberSettings(
            firstPage: 2, lastPage: 2, startingNumber: Int.max)) { _ in }
        let largeDoc = try XCTUnwrap(PDFDocument(data: large.data))
        XCTAssertTrue(try XCTUnwrap(largeDoc.page(at: 1)?.string).contains(String(Int.max)))
    }

    func testPositionsAcrossRotationsCropOriginsAndMixedSizes() async throws {
        let source = try makeFile(labels: ["Portrait", "Landscape", "Upside down", "Other rotation"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        for index in 0..<4 {
            let page = try XCTUnwrap(input.page(at: index))
            page.rotation = index * 90
            page.setBounds(CGRect(x: 10, y: 20, width: 400 + index * 20, height: 760), for: .cropBox)
            let note = PDFAnnotation(bounds: CGRect(x: 70, y: 90, width: 32, height: 32), forType: .text, withProperties: nil)
            note.contents = "Retained note"
            page.addAnnotation(note)
        }
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 4)
        for position in PageNumberPosition.allCases {
            let settings = PageNumberSettings(firstPage: 1, lastPage: 4, startingNumber: 10, fontSize: 20, position: position)
            let result = try await engine.addPageNumbers(snapshot, settings: settings) { _ in }
            let output = try XCTUnwrap(PDFDocument(data: result.data))
            let original = try XCTUnwrap(PDFDocument(data: snapshot.data))
            for index in 0..<4 {
                let page = try XCTUnwrap(output.page(at: index))
                let before = try XCTUnwrap(original.page(at: index))
                XCTAssertEqual(page.rotation, before.rotation)
                XCTAssertEqual(page.bounds(for: .cropBox), before.bounds(for: .cropBox))
                XCTAssertEqual(page.bounds(for: .mediaBox), before.bounds(for: .mediaBox))
                let note = try XCTUnwrap(page.annotations.first { $0.contents == "Retained note" })
                let originalNote = try XCTUnwrap(before.annotations.first { $0.contents == "Retained note" })
                XCTAssertEqual(note.bounds, originalNote.bounds)
                let originalText = try XCTUnwrap(before.string).trimmingCharacters(in: .whitespacesAndNewlines)
                let beforeSelection = try XCTUnwrap(original.findString(originalText, withOptions: []).first)
                let afterSelection = try XCTUnwrap(output.findString(originalText, withOptions: []).first)
                XCTAssertEqual(afterSelection.bounds(for: page), beforeSelection.bounds(for: before))
                let reference = try XCTUnwrap(page.pageRef)
                let crop = reference.getBoxRect(.cropBox)
                let size = index % 2 == 1 ? CGSize(width: crop.height, height: crop.width) : crop.size
                let label = String(10 + index)
                let text = NSAttributedString(string: label, attributes: [
                    NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, 20, nil)
                ])
                let width = CGFloat(CTLineGetTypographicBounds(CTLineCreateWithAttributedString(text), nil, nil, nil))
                let x: CGFloat
                switch position {
                case .left: x = 24
                case .center: x = (size.width - width) / 2
                case .right: x = size.width - width - 24
                }
                let footer = CGRect(x: x, y: 24, width: width, height: 28)
                XCTAssertTrue(try XCTUnwrap(page.string).contains(label))
                // Exercise reopened output, including visible footer placement.
                XCTAssertNotEqual(page.thumbnail(of: size, for: .cropBox).tiffRepresentation,
                                  before.thumbnail(of: size, for: .cropBox).tiffRepresentation)
                let rendered = try XCTUnwrap(page.thumbnail(of: size, for: .cropBox).tiffRepresentation)
                let bitmap = try XCTUnwrap(NSBitmapImageRep(data: rendered))
                let scaleX = CGFloat(bitmap.pixelsWide) / size.width
                let scaleY = CGFloat(bitmap.pixelsHigh) / size.height
                // The fixture has no content in the footer. Confirm visible ink inside
                // the expected upright label, including after every quarter-turn.
                let pixels = CGRect(x: footer.minX * scaleX, y: (size.height - footer.maxY) * scaleY,
                                    width: footer.width * scaleX, height: footer.height * scaleY).integral
                var ink = 0
                for y in Int(pixels.minY)..<Int(pixels.maxY) {
                    for x in Int(pixels.minX)..<Int(pixels.maxX) {
                        if let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB),
                           color.redComponent < 0.5, color.greenComponent < 0.5, color.blueComponent < 0.5 {
                            ink += 1
                        }
                    }
                }
                XCTAssertGreaterThan(ink, 10, "Saved label must render at the visible footer")
            }
        }
    }

    func testInvalidSettingsAndInputsAreRejected() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        for settings in [PageNumberSettings(firstPage: 0, lastPage: 2),
                         PageNumberSettings(firstPage: 2, lastPage: 1),
                         PageNumberSettings(lastPage: 3), PageNumberSettings(startingNumber: 0),
                         PageNumberSettings(lastPage: 2, startingNumber: Int.max),
                         PageNumberSettings(fontSize: 7), PageNumberSettings(fontSize: 33)] {
            await assertPDFError(.numberingSettings) {
                _ = try await self.engine.addPageNumbers(source, settings: settings) { _ in }
            }
        }
        let malformed = PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) {
            _ = try await self.engine.addPageNumbers(malformed, settings: PageNumberSettings()) { _ in }
        }
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.addPageNumbers(PDFFile(url: source.url, data: encrypted, pageCount: 2), settings: PageNumberSettings()) { _ in }
        }
        let tiny = try makeFile("tiny.pdf", size: CGSize(width: 30, height: 30))
        await assertPDFError(.numberingSettings) {
            _ = try await self.engine.addPageNumbers(tiny, settings: PageNumberSettings()) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublication() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let engine = try XCTUnwrap(engine)
        for boundary in [0.5, 1.0] {
            let task = Task {
                try await engine.addPageNumbers(source, settings: PageNumberSettings(lastPage: 2)) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowPreviewSaveInvalidationAndImport() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let destination = folder.appendingPathComponent("numbered.pdf")
        let model = NumberModel(saveDestination: { _ in destination })
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.lastPage, 2)
        model.prepare()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertNotNil(model.result)
        XCTAssertEqual(Set(model.previews.keys), [0, 1])
        XCTAssertEqual(model.progress, 1)
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        for settings in [PageNumberSettings(lastPage: 2, position: .right), PageNumberSettings(startingNumber: 5),
                         PageNumberSettings(fontSize: 20), PageNumberSettings(firstPage: 2, lastPage: 2)] {
            model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
            model.savedURL = destination
            model.status = "Saved"
            model.update(settings)
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.status)
            XCTAssertTrue(model.previews.isEmpty)
        }
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.firstPage, 1)
        XCTAssertEqual(model.settings.lastPage, 1)
        XCTAssertNil(model.result)
    }

    @MainActor func testBusyCancellationRetryAndSourceProtection() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        let model = NumberModel(saveDestination: { _ in source.url })
        model.files = [source]
        try await model.inputsChanged()
        model.prepare()
        model.update(PageNumberSettings(startingNumber: 9))
        model.prepare()
        XCTAssertEqual(model.settings.startingNumber, 1)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertFalse(model.busy)
        model.prepare()
        await model.waitForCompletion()
        let result = try XCTUnwrap(model.result)
        for destination in [source.url, symbolic, hard] {
            do {
                try await engine.save(result, to: destination, sources: [source.url])
                XCTFail("Expected source protection")
            } catch let error as PDFError {
                XCTAssertEqual(error.localizedDescription, PDFError.sourceOverwrite.localizedDescription)
            }
        }
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
        XCTAssertNil(model.savedURL)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }
}
