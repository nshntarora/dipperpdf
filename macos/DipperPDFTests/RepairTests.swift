import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class RepairTests: PDFTestCase {
    func testRebuildPreservesPagesTextGeometryAnnotationsMetadataAndSnapshot() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        input.documentAttributes = [PDFDocumentAttribute.titleAttribute: "Repair example", PDFDocumentAttribute.authorAttribute: "DipperPDF"]
        let first = try XCTUnwrap(input.page(at: 0))
        first.rotation = 90
        first.setBounds(CGRect(x: 10, y: 20, width: 400, height: 760), for: .cropBox)
        let note = PDFAnnotation(bounds: CGRect(x: 30, y: 40, width: 50, height: 60), forType: .text, withProperties: nil)
        note.contents = "Retained note"
        first.addAnnotation(note)
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 3)
        let original = try XCTUnwrap(PDFDocument(data: snapshot.data)?.page(at: 0))
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let repaired = try await engine.repair(snapshot) { await recorder.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: repaired.data))
        XCTAssertEqual(output.pageCount, 3)
        for (index, label) in ["First", "Second", "Third"].enumerated() {
            XCTAssertTrue(try XCTUnwrap(output.page(at: index)?.string).contains(label))
        }
        let page = try XCTUnwrap(output.page(at: 0))
        XCTAssertEqual(page.rotation, original.rotation)
        XCTAssertEqual(page.bounds(for: .cropBox), original.bounds(for: .cropBox))
        XCTAssertEqual(page.bounds(for: .mediaBox), original.bounds(for: .mediaBox))
        XCTAssertTrue(page.annotations.contains { $0.contents == note.contents })
        XCTAssertEqual(output.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String, "Repair example")
        XCTAssertEqual(output.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String, "DipperPDF")
        XCTAssertEqual(repaired.suggestedName, "source-repaired.pdf")
        let values = await recorder.values
        XCTAssertEqual(values.count, 4)
        XCTAssertEqual(values.last, 1)
        XCTAssertEqual(values, values.sorted())
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
    }

    func testRepairRewritesDamagedCrossReferencePointer() async throws {
        let source = try makeFile(labels: ["Recoverable first", "Recoverable second"])
        var damaged = source.data
        let marker = try XCTUnwrap(damaged.range(of: Data("startxref\n".utf8), options: .backwards))
        var end = marker.upperBound
        while end < damaged.endIndex, (48...57).contains(damaged[end]) { end += 1 }
        XCTAssertGreaterThan(end, marker.upperBound)
        damaged.replaceSubrange(marker.upperBound..<end, with: Data(repeating: 48, count: end - marker.upperBound))
        XCTAssertNotEqual(damaged, source.data)
        try damaged.write(to: source.url)
        // Exercise the import path so recoverable structural damage can reach Prepare.
        let loaded = try await engine.load(source.url)
        let repaired = try await engine.repair(loaded) { _ in }
        let output = try XCTUnwrap(PDFDocument(data: repaired.data))
        XCTAssertEqual(output.pageCount, 2)
        XCTAssertTrue(try XCTUnwrap(output.page(at: 0)?.string).contains("Recoverable first"))
        XCTAssertTrue(try XCTUnwrap(output.page(at: 1)?.string).contains("Recoverable second"))
        XCTAssertNotEqual(repaired.data, damaged)
        XCTAssertEqual(try Data(contentsOf: source.url), damaged)
        let destination = folder.appendingPathComponent("repaired.pdf")
        try await engine.save(repaired, to: destination, sources: [source.url])
        let reopened = try await engine.load(destination)
        XCTAssertEqual(reopened.pageCount, 2)
    }

    func testUnrecoverableEmptyEncryptedAndInconsistentInputsAreRejected() async throws {
        for bytes in [Data("not a PDF".utf8), try Self.pdf(labels: [])] {
            let file = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: bytes, pageCount: 0)
            await assertPDFError(.invalid) { _ = try await self.engine.repair(file) { _ in } }
        }
        let source = try makeFile()
        for password in ["", "reader"] {
            let document = try XCTUnwrap(PDFDocument(data: source.data))
            let encrypted = try XCTUnwrap(document.dataRepresentation(options: [
                PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: password
            ]))
            let file = PDFFile(url: source.url, data: encrypted, pageCount: 1)
            await assertPDFError(.encrypted) { _ = try await self.engine.repair(file) { _ in } }
        }
        let mismatched = PDFFile(url: source.url, data: source.data, pageCount: 2)
        await assertPDFError(.invalid) { _ = try await self.engine.repair(mismatched) { _ in } }
    }

    func testCancellationBetweenPagesAndBeforePublication() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let engine = try XCTUnwrap(engine)
        for boundary in [0.3, 1.0] {
            let task = Task {
                try await engine.repair(source) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testPreparationCancellationSaveRetryAndInputInvalidation() async throws {
        let source = try makeFile(labels: ["First", "Second"])
        let destination = folder.appendingPathComponent("repaired.pdf")
        var chosen: URL?
        var requests = 0
        let model = RepairModel(saveDestination: { name in
            requests += 1
            XCTAssertEqual(name, "source-repaired.pdf")
            return chosen
        })
        model.prepare()
        XCTAssertFalse(model.busy)
        model.files = [source]
        model.prepare()
        model.prepare()
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.prepare()
        await model.waitForCompletion()
        let prepared = try XCTUnwrap(model.result)
        XCTAssertEqual(requests, 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        model.save()
        XCTAssertEqual(model.result?.data, prepared.data)
        chosen = folder.appendingPathComponent("missing/output.pdf")
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.save.localizedDescription)
        XCTAssertEqual(model.result?.data, prepared.data)
        chosen = destination
        model.save()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(try Data(contentsOf: destination), prepared.data)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        let replacement = try makeFile("replacement.pdf")
        model.add([replacement.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.files.first?.url, replacement.url)
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
    }

    @MainActor func testSourceAndAliasesAreProtected() async throws {
        let source = try makeFile()
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard] {
            let model = RepairModel(saveDestination: { _ in destination })
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
}
