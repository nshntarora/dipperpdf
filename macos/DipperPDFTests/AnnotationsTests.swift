import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class AnnotationsTests: PDFTestCase {
    func testRemovesMarkupButPreservesLinksFormsTextGeometryAndSnapshot() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let types: [PDFAnnotationSubtype] = [.text, .freeText, .line, .square, .circle,
            .init(rawValue: "Polygon"), .init(rawValue: "PolyLine"), .highlight, .underline, .strikeOut, .init(rawValue: "Squiggly"),
            .stamp, .init(rawValue: "Caret"), .ink, .popup]
        for (index, type) in types.enumerated() {
            let page = try XCTUnwrap(doc.page(at: index % 3))
            let annotation = PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 80, height: 30), forType: type, withProperties: nil)
            annotation.contents = "Review markup"
            page.addAnnotation(annotation)
        }
        let first = try XCTUnwrap(doc.page(at: 0))
        first.rotation = 90
        first.setBounds(CGRect(x: 10, y: 20, width: 400, height: 760), for: .cropBox)
        let link = PDFAnnotation(bounds: CGRect(x: 30, y: 100, width: 100, height: 20), forType: .link, withProperties: nil)
        link.url = URL(string: "https://example.com")
        first.addAnnotation(link)
        let field = PDFAnnotation(bounds: CGRect(x: 30, y: 200, width: 100, height: 20), forType: .widget, withProperties: nil)
        field.widgetFieldType = .text
        field.fieldName = "Name"
        field.widgetStringValue = "Dipper"
        first.addAnnotation(field)
        let data = try XCTUnwrap(doc.dataRepresentation())
        let snapshot = PDFFile(url: source.url, data: data, pageCount: 3)
        let input = try XCTUnwrap(PDFDocument(data: data))
        let originalCount = try XCTUnwrap(input.page(at: 0)).annotations.count
        let expectedTypes = Set(types.map { $0.rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "/")) })
        // Verify fixture serialization actually retained every markup subtype.
        let serializedTypes = Set((0..<3).flatMap { index in
            input.page(at: index)!.annotations.compactMap(\.type).map {
                $0.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            }
        })
        XCTAssertTrue(expectedTypes.isSubset(of: serializedTypes), "Missing types: \(expectedTypes.subtracting(serializedTypes))")
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let result = try await engine.removeAnnotations(snapshot) { await recorder.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(output.pageCount, 3)
        for (index, label) in ["First", "Second", "Third"].enumerated() {
            let page = try XCTUnwrap(output.page(at: index))
            let original = try XCTUnwrap(input.page(at: index))
            XCTAssertTrue(try XCTUnwrap(page.string).contains(label))
            XCTAssertEqual(page.rotation, original.rotation)
            for box in [PDFDisplayBox.mediaBox, .cropBox, .bleedBox, .trimBox, .artBox] {
                XCTAssertEqual(page.bounds(for: box), original.bounds(for: box))
            }
            XCTAssertFalse(page.annotations.contains {
                expectedTypes.contains(($0.type ?? "").trimmingCharacters(in: CharacterSet(charactersIn: "/")))
            })
        }
        let kept = try XCTUnwrap(output.page(at: 0))
        XCTAssertEqual(kept.annotations.count, 2)
        let retainedLink = try XCTUnwrap(kept.annotations.first { $0.type?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == "Link" })
        XCTAssertEqual(try XCTUnwrap(retainedLink.url), try XCTUnwrap(link.url))
        let retainedField = try XCTUnwrap(kept.annotations.first { $0.type?.trimmingCharacters(in: CharacterSet(charactersIn: "/")) == "Widget" })
        XCTAssertEqual(retainedField.fieldName, "Name")
        XCTAssertEqual(retainedField.widgetStringValue, "Dipper")
        XCTAssertEqual(result.suggestedName, "source-without-annotations.pdf")
        let progress = await recorder.values
        XCTAssertEqual(progress, [1.0 / 3.0, 2.0 / 3.0, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
        XCTAssertEqual(PDFDocument(data: snapshot.data)?.page(at: 0)?.annotations.count, originalCount)
    }

    func testNoMarkupReturnsOriginalBytesAndRetainsOtherAnnotationTypes() async throws {
        let source = try makeFile()
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(doc.page(at: 0))
        page.addAnnotation(PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 30, height: 30), forType: .init(rawValue: "FileAttachment"), withProperties: nil))
        let data = try XCTUnwrap(doc.dataRepresentation())
        XCTAssertEqual(try XCTUnwrap(PDFDocument(data: data)?.page(at: 0)).annotations.count, 1)
        let file = PDFFile(url: source.url, data: data, pageCount: 1)
        let output = try await engine.removeAnnotations(file) { _ in }
        XCTAssertEqual(output.data, data)
        let clean = try await engine.removeAnnotations(source) { _ in }
        XCTAssertEqual(clean.data, source.data)
    }

    private func makeAnnotatedFile(labels: [String]) throws -> PDFFile {
        let source = try makeFile(labels: labels)
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(doc.page(at: 0))
        page.addAnnotation(PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 80, height: 30), forType: .text, withProperties: nil))
        let data = try XCTUnwrap(doc.dataRepresentation())
        try data.write(to: source.url)
        return PDFFile(url: source.url, data: data, pageCount: labels.count)
    }

    func testMalformedAndEncryptedInputAreRejected() async throws {
        let invalid = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) { _ = try await self.engine.removeAnnotations(invalid) { _ in } }
        let source = try makeFile()
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.removeAnnotations(PDFFile(url: source.url, data: encrypted, pageCount: 1)) { _ in }
        }
    }

    func testCancellationBetweenPagesAndBeforePublishing() async throws {
        let source = try makeAnnotatedFile(labels: ["First", "Second", "Third"])
        let engine = try XCTUnwrap(engine)
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.removeAnnotations(source) { progress in
                    if progress >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testSaveCancelledPanelAndEmptyInput() async throws {
        let source = try makeAnnotatedFile(labels: ["First", "Second"])
        let destination = folder.appendingPathComponent("cleaned.pdf")
        var proposedName: String?
        let model = AnnotationsModel(saveDestination: { proposedName = $0; return destination })
        model.prepare()
        XCTAssertNil(proposedName)
        let cancelled = AnnotationsModel(saveDestination: { _ in nil })
        cancelled.files = [source]
        cancelled.prepare()
        await cancelled.waitForCompletion()
        cancelled.save()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNotNil(cancelled.result)
        model.files = [source]
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(proposedName, "source-without-annotations.pdf")
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.status, "Saved cleaned.pdf.")
        XCTAssertNil(model.error)
        XCTAssertEqual(model.progress, 1)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        XCTAssertTrue(try XCTUnwrap(PDFDocument(url: destination)?.page(at: 0)?.string).contains("First"))
        XCTAssertTrue(try XCTUnwrap(PDFDocument(url: destination)?.page(at: 0)).annotations.isEmpty)
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.first?.url, replacement.url)
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testSourceAndAliasesAreProtected() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard] {
            let model = AnnotationsModel(saveDestination: { _ in destination })
            model.files = [source]
            model.prepare()
            await model.waitForCompletion()
            model.save()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
            XCTAssertNil(model.savedURL)
            XCTAssertNotNil(model.result)
            XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        }
    }

    @MainActor func testBusyExclusionCancellationAndRetry() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let destination = folder.appendingPathComponent("cleaned.pdf")
        var requests = 0
        let model = AnnotationsModel(saveDestination: { _ in requests += 1; return destination })
        model.files = [source]
        model.prepare()
        model.prepare()
        XCTAssertEqual(requests, 0)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.prepare()
        await model.waitForCompletion()
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertNil(model.error)
    }
}
