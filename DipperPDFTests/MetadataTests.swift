import PDFKit
import XCTest
@testable import DipperPDF

final class MetadataTests: PDFTestCase {
    private func annotatedFile() throws -> PDFFile {
        let source = try makeFile(labels: ["First page", "Second page"])
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        doc.documentAttributes = [PDFDocumentAttribute.titleAttribute: "Original title", PDFDocumentAttribute.authorAttribute: "Original author",
                                  PDFDocumentAttribute.subjectAttribute: "Original subject", PDFDocumentAttribute.keywordsAttribute: ["one", "two"],
                                  PDFDocumentAttribute.creatorAttribute: "Fixture creator",
                                  PDFDocumentAttribute.creationDateAttribute: Date(timeIntervalSince1970: 1_700_000_000)]
        let page = try XCTUnwrap(doc.page(at: 0))
        page.rotation = 90
        page.setBounds(CGRect(x: 10, y: 20, width: 400, height: 700), for: .cropBox)
        let annotation = PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 50, height: 60), forType: .text, withProperties: nil)
        annotation.contents = "Retained note"
        page.addAnnotation(annotation)
        let data = try XCTUnwrap(doc.dataRepresentation())
        try data.write(to: source.url)
        return PDFFile(url: source.url, data: data, pageCount: 2)
    }

    func testReadUpdateAndPagePreservationUseSnapshot() async throws {
        let source = try annotatedFile()
        let original = try XCTUnwrap(PDFDocument(data: source.data))
        let metadata = try await engine.metadata(source)
        XCTAssertEqual(metadata, PDFMetadata(title: "Original title", author: "Original author",
                                             subject: "Original subject", keywords: ["one", "two"]))
        let edited = PDFMetadata(title: "A new title — 日本語", author: "New author", subject: "New subject",
                                 keywords: ["birds", "streams"])
        try Data("Disk changed".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let result = try await engine.editMetadata(source, metadata: edited) { await recorder.record($0) }
        let output = PDFFile(url: source.url, data: result.data, pageCount: 2)
        let updated = try await engine.metadata(output)
        XCTAssertEqual(updated, edited)
        XCTAssertEqual(result.suggestedName, "source-metadata.pdf")
        let doc = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(doc.pageCount, original.pageCount)
        for index in 0..<doc.pageCount {
            let page = try XCTUnwrap(doc.page(at: index))
            let before = try XCTUnwrap(original.page(at: index))
            XCTAssertEqual(page.string, before.string)
            XCTAssertEqual(page.rotation, before.rotation)
            XCTAssertEqual(page.bounds(for: .mediaBox), before.bounds(for: .mediaBox))
            XCTAssertEqual(page.bounds(for: .cropBox), before.bounds(for: .cropBox))
        }
        XCTAssertTrue(try XCTUnwrap(doc.page(at: 0)).annotations.contains { $0.contents == "Retained note" })
        XCTAssertEqual(doc.documentAttributes?[PDFDocumentAttribute.creatorAttribute] as? String, "Fixture creator")
        XCTAssertEqual(doc.documentAttributes?[PDFDocumentAttribute.creationDateAttribute] as? Date,
                       original.documentAttributes?[PDFDocumentAttribute.creationDateAttribute] as? Date)
        let progress = await recorder.values
        XCTAssertEqual(progress, [0.5, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Disk changed".utf8))
    }

    func testEmptyFieldsAreRemovedAndMissingFieldsReadAsEmpty() async throws {
        let source = try annotatedFile()
        let result = try await engine.editMetadata(source, metadata: PDFMetadata()) { _ in }
        let attributes = try XCTUnwrap(PDFDocument(data: result.data)).documentAttributes ?? [:]
        for key in [PDFDocumentAttribute.titleAttribute, PDFDocumentAttribute.authorAttribute, PDFDocumentAttribute.subjectAttribute, PDFDocumentAttribute.keywordsAttribute] {
            XCTAssertNil(attributes[key])
        }
        let empty = try await engine.metadata(PDFFile(url: source.url, data: result.data, pageCount: 2))
        XCTAssertEqual(empty, PDFMetadata())
    }

    func testInvalidEncryptedAndCancellation() async throws {
        let source = try makeFile()
        let invalid = PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 1)
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let encryptedData = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        let encrypted = PDFFile(url: source.url, data: encryptedData, pageCount: 1)
        for (input, error) in [(invalid, PDFError.invalid), (encrypted, .encrypted)] {
            await assertPDFError(error) { _ = try await self.engine.metadata(input) }
            await assertPDFError(error) {
                _ = try await self.engine.editMetadata(input, metadata: PDFMetadata()) { _ in }
            }
        }
        let engine = try XCTUnwrap(engine)
        for boundary in [0.5, 1.0] {
            let task = Task {
                try await engine.editMetadata(source, metadata: PDFMetadata(title: "Updated")) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testImportReplacementAndEditingInvalidatesSaveState() async throws {
        let source = try annotatedFile()
        let model = MetadataModel()
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.metadata.title, "Original title")
        XCTAssertEqual(model.keywords, "one, two")
        for edit in [{ model.metadata.title = "Changed" }, { model.metadata.author = "Changed" },
                     { model.metadata.subject = "Changed" }, { model.keywords = "Changed" }] {
            model.result = PDFResult(data: source.data, suggestedName: "old.pdf")
            model.savedURL = folder.appendingPathComponent("old.pdf")
            model.status = "Saved."
            edit()
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertNil(model.status)
        }
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.metadata, PDFMetadata())
        XCTAssertEqual(model.keywords, "")
    }

    @MainActor func testSaveBusyExclusionCancelledPanelAndRetry() async throws {
        let source = try annotatedFile()
        let destination = folder.appendingPathComponent("edited.pdf")
        var requests: [String] = []
        let model = MetadataModel(saveDestination: { requests.append($0); return destination })
        model.prepareAndSave()
        XCTAssertTrue(requests.isEmpty)
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        model.metadata.title = "Edited title"
        model.keywords = " birds, , streams ,"
        model.prepareAndSave()
        model.prepareAndSave()
        XCTAssertEqual(requests, ["source-metadata.pdf"])
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.progress, 1)
        let output = try await engine.load(destination)
        let metadata = try await engine.metadata(output)
        XCTAssertEqual(metadata.title, "Edited title")
        XCTAssertEqual(metadata.keywords, ["birds", "streams"])
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        let cancelled = MetadataModel(saveDestination: { _ in nil })
        cancelled.files = [source]
        cancelled.prepareAndSave()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNil(cancelled.result)
    }

    @MainActor func testEditingTitleRetainsImportedKeywords() async throws {
        let source = try makeFile()
        let keywords = ["river, stream", "wildlife"]
        let seeded = try await engine.editMetadata(source, metadata: PDFMetadata(keywords: keywords)) { _ in }
        try seeded.data.write(to: source.url)
        let destination = folder.appendingPathComponent("edited.pdf")
        let model = MetadataModel(saveDestination: { _ in destination })
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        // PDFKit on macOS 15 splits comma-containing keywords during the first
        // serialization. Compare with the imported fixture, not the pre-write array.
        let importedKeywords = model.metadata.keywords
        XCTAssertFalse(importedKeywords.isEmpty)
        XCTAssertEqual(model.keywords, importedKeywords.joined(separator: ", "))
        model.metadata.title = "New title"
        model.prepareAndSave()
        await model.waitForCompletion()
        let output = try await engine.load(destination)
        let edited = try await engine.metadata(output)
        XCTAssertEqual(edited.title, "New title")
        XCTAssertEqual(edited.keywords, importedKeywords)
    }

    @MainActor func testSourceAliasesAndSaveFailure() async throws {
        let source = try annotatedFile()
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard, folder.appendingPathComponent("missing/output.pdf")] {
            let model = MetadataModel(saveDestination: { _ in destination })
            model.files = [source]
            model.metadata.title = "Changed"
            model.prepareAndSave()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, (destination.lastPathComponent == "output.pdf" ? PDFError.save : .sourceOverwrite).localizedDescription)
            XCTAssertNil(model.result)
            XCTAssertNil(model.savedURL)
            XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        }
    }
}
