import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class CropTests: PDFTestCase {
    func testRangeCropUsesSnapshotAndPreservesOtherPagesAndContent() async throws {
        let source = try makeFile(labels: ["Cover", "Chapter", "Appendix"])
        let recorder = ProgressRecorder()
        let changed = Data("Changed on disk".utf8)
        try changed.write(to: source.url)
        let output = try await engine.crop(source, settings: CropSettings(
            firstPage: 2, lastPage: 2, top: 100, bottom: 20, left: 30, right: 40)) { await recorder.record($0) }
        let doc = try XCTUnwrap(PDFDocument(data: output.data))
        XCTAssertEqual(output.suggestedName, "source-cropped.pdf")
        XCTAssertEqual(doc.pageCount, 3)
        for index in 0..<3 {
            let page = try XCTUnwrap(doc.page(at: index))
            XCTAssertEqual(page.bounds(for: .mediaBox), CGRect(x: 0, y: 0, width: 612, height: 792))
            XCTAssertEqual(page.bounds(for: .cropBox), index == 1 ?
                CGRect(x: 30, y: 20, width: 542, height: 672) : page.bounds(for: .mediaBox))
            // Cropping hides content; restoring the box reveals the original text.
            page.setBounds(page.bounds(for: .mediaBox), for: .cropBox)
            XCTAssertTrue(try XCTUnwrap(page.string).contains(["Cover", "Chapter", "Appendix"][index]))
        }
        let progress = await recorder.values
        XCTAssertEqual(progress, [1])
        XCTAssertEqual(try Data(contentsOf: source.url), changed)
    }

    func testVisibleMarginsAcrossRotationsMixedSizesAndExistingCropOrigins() async throws {
        let source = try makeFile(labels: ["Zero", "Ninety", "One eighty", "Two seventy"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        for index in 0..<4 {
            let page = try XCTUnwrap(input.page(at: index))
            page.rotation = index * 90
            page.setBounds(CGRect(x: -20, y: -10, width: 650 + index * 10, height: 830), for: .mediaBox)
            page.setBounds(CGRect(x: 10, y: 20, width: 400 + index * 10, height: 700), for: .cropBox)
            let note = PDFAnnotation(bounds: CGRect(x: 70, y: 90, width: 32, height: 32), forType: .text, withProperties: nil)
            note.contents = "Retained note"
            page.addAnnotation(note)
        }
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 4)
        let original = try XCTUnwrap(PDFDocument(data: snapshot.data))
        let recorder = ProgressRecorder()
        let output = try await engine.crop(snapshot, settings: CropSettings(
            lastPage: 4, top: 10, bottom: 20, left: 30, right: 40)) { await recorder.record($0) }
        let doc = try XCTUnwrap(PDFDocument(data: output.data))
        let expected = [CGRect(x: 40, y: 40, width: 330, height: 670),
                        CGRect(x: 20, y: 50, width: 380, height: 630),
                        CGRect(x: 50, y: 30, width: 350, height: 670),
                        CGRect(x: 30, y: 60, width: 400, height: 630)]
        for index in 0..<4 {
            let page = try XCTUnwrap(doc.page(at: index))
            let before = try XCTUnwrap(original.page(at: index))
            XCTAssertEqual(page.bounds(for: .cropBox), expected[index])
            XCTAssertEqual(page.bounds(for: .mediaBox), before.bounds(for: .mediaBox))
            XCTAssertEqual(page.rotation, index * 90)
            XCTAssertEqual(try XCTUnwrap(page.annotations.first).bounds, try XCTUnwrap(before.annotations.first).bounds)
            // Verify reopened crop boxes are used by the same renderer as the UI.
            let visible = index % 2 == 0 ? expected[index].size : CGSize(width: expected[index].height, height: expected[index].width)
            let rendered = page.thumbnail(of: visible, for: .cropBox)
            XCTAssertEqual(rendered.size.width / rendered.size.height, visible.width / visible.height, accuracy: 0.01)
        }
        let progress = await recorder.values
        XCTAssertEqual(progress, [0.25, 0.5, 0.75, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    func testInvalidSettingsIncludingEmptyAreaOnLaterPage() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        for settings in [CropSettings(firstPage: 0), CropSettings(firstPage: 2, lastPage: 1),
                         CropSettings(lastPage: 3), CropSettings(top: -1), CropSettings(bottom: .infinity),
                         CropSettings(left: .nan), CropSettings(right: Double.greatestFiniteMagnitude),
                         CropSettings(top: 792, bottom: 0), CropSettings(left: 600, right: 12)] {
            await assertPDFError(.croppingSettings) {
                _ = try await self.engine.crop(source, settings: settings) { _ in }
            }
        }
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        try XCTUnwrap(doc.page(at: 1)).setBounds(CGRect(x: 0, y: 0, width: 30, height: 30), for: .cropBox)
        let mixed = PDFFile(url: source.url, data: try XCTUnwrap(doc.dataRepresentation()), pageCount: 2)
        await assertPDFError(.croppingSettings) {
            _ = try await self.engine.crop(mixed, settings: CropSettings(lastPage: 2)) { _ in }
        }
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        // Zero margins are a valid no-op and never remove a crop box.
        let unchanged = try await engine.crop(source, settings: CropSettings(top: 0, bottom: 0, left: 0, right: 0)) { _ in }
        let reopened = try XCTUnwrap(PDFDocument(data: unchanged.data))
        XCTAssertEqual(reopened.page(at: 0)?.bounds(for: .cropBox), CGRect(x: 0, y: 0, width: 612, height: 792))
    }

    func testInvalidAndEncryptedInputsAreRejected() async throws {
        let source = try makeFile()
        await assertPDFError(.invalid) {
            _ = try await self.engine.crop(PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 1), settings: CropSettings()) { _ in }
        }
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.crop(PDFFile(url: source.url, data: encrypted, pageCount: 1), settings: CropSettings()) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublication() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let engine = try XCTUnwrap(engine)
        for boundary in [0.5, 1.0] {
            let task = Task {
                try await engine.crop(source, settings: CropSettings(lastPage: 2)) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowPreviewSaveInvalidationAndReplacement() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let destination = folder.appendingPathComponent("cropped.pdf")
        let model = CropModel(saveDestination: { _ in destination })
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
        for settings in [CropSettings(top: 25), CropSettings(bottom: 25), CropSettings(left: 25),
                         CropSettings(right: 25), CropSettings(firstPage: 2, lastPage: 2)] {
            model.result = PDFResult(data: Data(), suggestedName: "old.pdf")
            model.savedURL = destination
            model.status = "Saved"
            model.update(settings)
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.status)
            XCTAssertTrue(model.previews.isEmpty)
        }
        model.add([try makeFile("replacement.pdf").url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.settings.firstPage, 1)
        XCTAssertEqual(model.settings.lastPage, 1)
        XCTAssertNil(model.result)
    }

    @MainActor func testWorkflowBusyCancellationInvalidAreaRetryAndSourceProtection() async throws {
        let source = try makeFile(labels: ["One", "Two"])
        let model = CropModel(saveDestination: { _ in source.url })
        model.files = [source]
        try await model.inputsChanged()
        model.prepare()
        model.update(CropSettings(top: 9))
        model.prepare()
        XCTAssertEqual(model.settings.top, 18)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertFalse(model.busy)
        model.update(CropSettings(lastPage: 2, top: 792))
        model.prepare()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.croppingSettings.localizedDescription)
        XCTAssertNil(model.result)
        model.update(CropSettings(lastPage: 2))
        model.prepare()
        await model.waitForCompletion()
        let result = try XCTUnwrap(model.result)
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
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
