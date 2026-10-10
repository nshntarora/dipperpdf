import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class WatermarkTests: PDFTestCase {
    func testRangePreservesSearchableContentAndUsesSnapshot() async throws {
        let source = try makeFile(labels: ["Cover", "Section", "Appendix"])
        let changed = Data("Changed on disk".utf8)
        try changed.write(to: source.url)
        let recorder = ProgressRecorder()
        let result = try await engine.addWatermark(source, settings: WatermarkSettings(firstPage: 2, lastPage: 2)) {
            await recorder.record($0)
        }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        let before = try XCTUnwrap(PDFDocument(data: source.data))
        XCTAssertEqual(output.pageCount, 3)
        XCTAssertEqual(result.suggestedName, "source-watermarked.pdf")
        for (index, label) in ["Cover", "Section", "Appendix"].enumerated() {
            let page = try XCTUnwrap(output.page(at: index))
            XCTAssertTrue(try XCTUnwrap(page.string).contains(label))
            XCTAssertEqual(page.string?.contains("DRAFT"), index == 1)
            if index != 1 {
                XCTAssertEqual(page.thumbnail(of: CGSize(width: 306, height: 396), for: .cropBox).tiffRepresentation,
                               before.page(at: index)?.thumbnail(of: CGSize(width: 306, height: 396), for: .cropBox).tiffRepresentation)
            }
        }
        let progress = await recorder.values
        XCTAssertEqual(progress, [1])
        XCTAssertEqual(try Data(contentsOf: source.url), changed)
    }

    func testVisiblePlacementAcrossRotationsCropOriginsPositionsAndAngles() async throws {
        // A blank fixture lets us measure the watermark's actual rendered ink bounds.
        let source = try makeFile(labels: ["", "", "", ""])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        for index in 0..<4 {
            let page = try XCTUnwrap(input.page(at: index))
            page.rotation = index * 90
            page.setBounds(CGRect(x: 10, y: 20, width: 400 + index * 20, height: 700), for: .cropBox)
            let note = PDFAnnotation(bounds: CGRect(x: 70, y: 90, width: 32, height: 32), forType: .link, withProperties: nil)
            note.url = URL(string: "https://example.com")
            page.addAnnotation(note)
        }
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 4)
        let original = try XCTUnwrap(PDFDocument(data: snapshot.data))
        for position in WatermarkPosition.allCases {
            for angle in [-90, -45, 0, 45, 90] {
                let settings = WatermarkSettings(lastPage: 4, opacity: 0.5, angle: angle, position: position)
                let result = try await engine.addWatermark(snapshot, settings: settings) { _ in }
                let output = try XCTUnwrap(PDFDocument(data: result.data))
                for index in 0..<4 {
                    let page = try XCTUnwrap(output.page(at: index))
                    let before = try XCTUnwrap(original.page(at: index))
                    XCTAssertEqual(page.rotation, before.rotation)
                    for box in [PDFDisplayBox.mediaBox, .cropBox, .bleedBox, .trimBox, .artBox] {
                        XCTAssertEqual(page.bounds(for: box), before.bounds(for: box))
                    }
                    XCTAssertEqual(page.annotations.first?.url, before.annotations.first?.url)
                    XCTAssertEqual(page.annotations.first?.bounds, before.annotations.first?.bounds)
                    let crop = page.bounds(for: .cropBox)
                    let size = index % 2 == 0 ? crop.size : CGSize(width: crop.height, height: crop.width)
                    let (ink, darkness) = try inkBounds(page, size: size)
                    XCTAssertGreaterThan(ink.width, 10)
                    XCTAssertGreaterThan(ink.height, 10)
                    XCTAssertTrue(CGRect(origin: .zero, size: size).insetBy(dx: 22, dy: 22).contains(ink))
                    // Rotated letters need not fill the corners of the layout rectangle.
                    XCTAssertEqual(ink.midX, size.width / 2, accuracy: 6)
                    switch position {
                    case .top: XCTAssertEqual(ink.minY, 24, accuracy: 9)
                    case .center: XCTAssertEqual(ink.midY, size.height / 2, accuracy: 6)
                    case .bottom: XCTAssertEqual(ink.maxY, size.height - 24, accuracy: 9)
                    }
                    // Thumbnail color management can shift nominal 50% gray.
                    XCTAssertGreaterThan(darkness, 0.3)
                    XCTAssertLessThan(darkness, 0.6)
                }
            }
        }
        let long = WatermarkSettings(text: String(repeating: "LONG ", count: 40), fontSize: 96, angle: 45)
        let fitted = try await engine.addWatermark(snapshot, settings: long) { _ in }
        let fittedPage = try XCTUnwrap(PDFDocument(data: fitted.data)?.page(at: 0))
        let (bounds, _) = try inkBounds(fittedPage, size: CGSize(width: 400, height: 700))
        XCTAssertTrue(CGRect(x: 22, y: 22, width: 356, height: 656).contains(bounds))
    }

    private func inkBounds(_ page: PDFPage, size: CGSize) throws -> (CGRect, CGFloat) {
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: try XCTUnwrap(page.thumbnail(of: CGSize(width: size.width / 2, height: size.height / 2), for: .cropBox).tiffRepresentation)))
        var minX = bitmap.pixelsWide, minY = bitmap.pixelsHigh, maxX = 0, maxY = 0
        var darkness: CGFloat = 0
        for y in 0..<bitmap.pixelsHigh {
            for x in 0..<bitmap.pixelsWide {
                let color = try XCTUnwrap(bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB))
                darkness = max(darkness, 1 - color.redComponent)
                if color.redComponent < 0.95 {
                    minX = min(minX, x); maxX = max(maxX, x)
                    minY = min(minY, y); maxY = max(maxY, y)
                }
            }
        }
        let scaleX = size.width / CGFloat(bitmap.pixelsWide), scaleY = size.height / CGFloat(bitmap.pixelsHigh)
        return (CGRect(x: CGFloat(minX) * scaleX, y: CGFloat(minY) * scaleY,
                       width: CGFloat(max(0, maxX - minX + 1)) * scaleX,
                       height: CGFloat(max(0, maxY - minY + 1)) * scaleY), darkness)
    }

    func testInvalidSettingsAndEncryptedInputAreRejected() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        for settings in [WatermarkSettings(text: "  "), WatermarkSettings(text: "Two\nlines"),
                         WatermarkSettings(text: String(repeating: "a", count: 201)),
                         WatermarkSettings(firstPage: 0), WatermarkSettings(firstPage: 2, lastPage: 1),
                         WatermarkSettings(lastPage: 3), WatermarkSettings(fontSize: 11),
                         WatermarkSettings(fontSize: 97), WatermarkSettings(opacity: 0),
                         WatermarkSettings(opacity: .nan), WatermarkSettings(opacity: 1.1),
                         WatermarkSettings(angle: 91)] {
            await assertPDFError(.watermarkSettings) {
                _ = try await self.engine.addWatermark(source, settings: settings) { _ in }
            }
        }
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.addWatermark(PDFFile(url: source.url, data: encrypted, pageCount: 2), settings: WatermarkSettings()) { _ in }
        }
        let invalid = PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 1)
        await assertPDFError(.invalid) {
            _ = try await self.engine.addWatermark(invalid, settings: WatermarkSettings()) { _ in }
        }
        let tiny = try makeFile("tiny.pdf", size: CGSize(width: 30, height: 30))
        await assertPDFError(.watermarkSettings) {
            _ = try await self.engine.addWatermark(tiny, settings: WatermarkSettings()) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublication() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let engine = try XCTUnwrap(engine)
        for boundary in [0.5, 1.0] {
            let task = Task {
                try await engine.addWatermark(source, settings: WatermarkSettings(lastPage: 2)) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowPreviewSaveInvalidationAndReplacement() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let destination = folder.appendingPathComponent("watermarked.pdf")
        let model = WatermarkModel(saveDestination: { _ in destination })
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.lastPage, 2)
        model.prepare()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertNotNil(model.result)
        let preview = try await engine.preview(try XCTUnwrap(model.result).data, page: 1)
        XCTAssertEqual(preview.pageCount, 2)
        XCTAssertNotNil(NSImage(data: preview.imageData))
        XCTAssertEqual(model.progress, 1)
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        for settings in [WatermarkSettings(text: "PRIVATE"), WatermarkSettings(position: .top),
                         WatermarkSettings(opacity: 0.6), WatermarkSettings(angle: 0),
                         WatermarkSettings(fontSize: 24), WatermarkSettings(firstPage: 2, lastPage: 2)] {
            model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
            model.savedURL = destination
            model.status = "Saved"
            model.update(settings)
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.status)
        }
        var invalid = model.settings
        invalid.text = ""
        model.update(invalid)
        XCTAssertFalse(model.canWatermark)
        model.prepare()
        XCTAssertFalse(model.busy)
        invalid.text = "PRIVATE"
        model.update(invalid)
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.firstPage, 1)
        XCTAssertEqual(model.settings.lastPage, 1)
        XCTAssertEqual(model.settings.text, "PRIVATE")
        XCTAssertNil(model.result)
    }

    @MainActor func testBusyCancellationRetryAndSourceProtection() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        let model = WatermarkModel(saveDestination: { _ in source.url })
        model.files = [source]
        try await model.inputsChanged()
        model.prepare()
        model.update(WatermarkSettings(text: "CHANGED"))
        model.prepare()
        XCTAssertEqual(model.settings.text, "DRAFT")
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
