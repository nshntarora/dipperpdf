import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class PDFEngineTests: PDFTestCase {
    func testLoadSnapshotsBytesAndPageCount() async throws {
        let original = try makeFile(labels: ["First", "Second"])
        let loaded = try await engine.load(original.url)
        try Data("Changed on disk".utf8).write(to: original.url)
        XCTAssertEqual(loaded.data, original.data)
        XCTAssertEqual(loaded.pageCount, 2)
        XCTAssertEqual(loaded.url, original.url)
    }

    func testLoadRejectsInvalidPDF() async throws {
        let url = folder.appendingPathComponent("invalid.pdf")
        try Data("not a PDF".utf8).write(to: url)
        await assertPDFError(.invalid) { _ = try await self.engine.load(url) }
    }

    func testLoadRejectsPDFWithoutPages() async throws {
        let url = folder.appendingPathComponent("empty.pdf")
        // Core Graphics silently adds a blank page to a zero-page drawing context.
        // Construct a valid PDF with an explicitly empty page tree instead.
        var pdf = "%PDF-1.4\n"
        var offsets = [0]
        for object in ["<< /Type /Catalog /Pages 2 0 R >>", "<< /Type /Pages /Kids [] /Count 0 >>"] {
            offsets.append(pdf.utf8.count)
            pdf += "\(offsets.count - 1) 0 obj\n\(object)\nendobj\n"
        }
        let xref = pdf.utf8.count
        pdf += "xref\n0 3\n0000000000 65535 f \n"
        for offset in offsets.dropFirst() { pdf += String(format: "%010d 00000 n \n", offset) }
        pdf += "trailer\n<< /Size 3 /Root 1 0 R >>\nstartxref\n\(xref)\n%%EOF\n"
        let data = Data(pdf.utf8)
        let document = PDFDocument(data: data)
        // PDFKit versions may reject an empty tree before exposing a document.
        XCTAssertTrue(document == nil || document?.pageCount == 0)
        try data.write(to: url)
        await assertPDFError(.invalid) { _ = try await self.engine.load(url) }
    }

    func testLoadReportsMissingFile() async {
        await assertPDFError(.permission) {
            _ = try await self.engine.load(self.folder.appendingPathComponent("missing.pdf"))
        }
    }

    func testLoadRejectsEncryptedPDF() async throws {
        let input = try makeFile()
        let doc = try XCTUnwrap(PDFDocument(data: input.data))
        let url = folder.appendingPathComponent("encrypted.pdf")
        XCTAssertTrue(doc.write(to: url, withOptions: [.userPasswordOption: "password", .ownerPasswordOption: "owner"]))
        await assertPDFError(.encrypted) { _ = try await self.engine.load(url) }
    }

    func testLightCompression() async throws { try await assertCompression(.light) }
    func testBalancedCompression() async throws { try await assertCompression(.balanced) }
    func testStrongCompression() async throws { try await assertCompression(.strong) }

    private func assertCompression(_ level: CompressionLevel) async throws {
        let source = try makeFile("scan.pdf", labels: ["Searchable text", "Second page"], image: true)
        let progress = ProgressRecorder()
        let result = try await engine.compress(source, level: level) { await progress.record($0) }
        let doc = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertLessThan(result.data.count, source.data.count / 2)
        XCTAssertEqual(doc.pageCount, 2)
        XCTAssertTrue(try XCTUnwrap(doc.string).contains("Searchable text"))
        XCTAssertTrue(try XCTUnwrap(doc.string).contains("Second page"))
        XCTAssertEqual(doc.page(at: 0)?.bounds(for: .mediaBox), CGRect(x: 0, y: 0, width: 612, height: 792))
        XCTAssertEqual(result.suggestedName, "scan-compressed.pdf")
        let values = await progress.values
        XCTAssertEqual(values, [0.1, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    func testCompressionNeverEnlargesTextPDF() async throws {
        let source = try makeFile()
        for level in CompressionLevel.allCases {
            let result = try await engine.compress(source, level: level, progress: { _ in })
            XCTAssertLessThanOrEqual(result.data.count, source.data.count)
            XCTAssertTrue(PDFDocument(data: result.data)?.string?.contains("Searchable text") == true)
        }
    }

    func testMergePreservesOrderGeometryRotationAndAnnotations() async throws {
        let first = try makeFile("first.pdf", labels: ["First", "Second"])
        let source = try makeFile("third.pdf", labels: ["Third"], size: CGSize(width: 800, height: 400))
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(input.page(at: 0))
        page.rotation = 90
        let media = CGRect(x: 0, y: 0, width: 800, height: 400)
        let crop = CGRect(x: 20, y: 10, width: 760, height: 380)
        page.setBounds(media, for: .mediaBox)
        page.setBounds(crop, for: .cropBox)
        let annotation = PDFAnnotation(bounds: CGRect(x: 60, y: 60, width: 80, height: 30), forType: .text, withProperties: nil)
        annotation.contents = "Retained annotation"
        page.addAnnotation(annotation)
        let data = try XCTUnwrap(input.dataRepresentation())
        try data.write(to: source.url)
        let third = try await engine.load(source.url)
        let progress = ProgressRecorder()
        let result = try await engine.merge([third, first]) { await progress.record($0) }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(output.pageCount, 3)
        for (index, text) in ["Third", "First", "Second"].enumerated() {
            XCTAssertTrue(output.page(at: index)?.string?.contains(text) == true)
        }
        let mergedPage = try XCTUnwrap(output.page(at: 0))
        XCTAssertEqual(mergedPage.rotation, 90)
        XCTAssertEqual(mergedPage.bounds(for: .mediaBox), media)
        XCTAssertEqual(mergedPage.bounds(for: .cropBox), crop)
        XCTAssertTrue(mergedPage.annotations.contains { $0.contents == annotation.contents })
        XCTAssertEqual(result.suggestedName, "Merged.pdf")
        let values = await progress.values
        XCTAssertEqual(values, [1.0 / 3, 2.0 / 3, 1])
        XCTAssertEqual(try Data(contentsOf: first.url), first.data)
        XCTAssertEqual(try Data(contentsOf: third.url), third.data)
    }

    func testMergeRejectsInsufficientInputs() async throws {
        let file = try makeFile()
        for inputs in [[], [file]] {
            await assertPDFError(.processing) { _ = try await self.engine.merge(inputs, progress: { _ in }) }
        }
    }

    func testAllToolsRejectInvalidInputData() async {
        let invalid = PDFFile(url: folder.appendingPathComponent("bad.pdf"), data: Data("invalid".utf8), pageCount: 1)
        await assertPDFError(.invalid) { _ = try await self.engine.compress(invalid, level: .balanced, progress: { _ in }) }
        await assertPDFError(.invalid) { _ = try await self.engine.merge([invalid, invalid], progress: { _ in }) }
        await assertPDFError(.invalid) { _ = try await self.engine.rotate(invalid, rotations: [:], progress: { _ in }) }
        await assertPDFError(.invalid) { try await self.engine.thumbnails(invalid, receive: { _, _ in }) }
    }

    func testRotationCombinesExistingAnglesAndLeavesUnselectedPagesAlone() async throws {
        let source = try makeFile(labels: ["First", "Second", "Third"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        input.page(at: 0)?.rotation = 90
        let file = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 3)
        let progress = ProgressRecorder()
        let result = try await engine.rotate(file, rotations: [0: -90, 1: -450]) { await progress.record($0) }
        let doc = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual((0..<3).map { doc.page(at: $0)?.rotation }, [0, 270, 0])
        XCTAssertTrue(doc.page(at: 1)?.string?.contains("Second") == true)
        XCTAssertEqual(doc.page(at: 0)?.bounds(for: .mediaBox), input.page(at: 0)?.bounds(for: .mediaBox))
        XCTAssertEqual(result.suggestedName, "source-rotated.pdf")
        let values = await progress.values
        XCTAssertEqual(values, [1.0 / 3, 2.0 / 3, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    func testRotationWithNoChangesPreservesPages() async throws {
        let file = try makeFile(labels: ["First", "Second"])
        let result = try await engine.rotate(file, rotations: [:], progress: { _ in })
        let doc = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertEqual(doc.pageCount, 2)
        XCTAssertEqual(doc.page(at: 0)?.rotation, 0)
        XCTAssertTrue(doc.page(at: 1)?.string?.contains("Second") == true)
    }

    func testThumbnailsAreDecodablePNGsForEveryPage() async throws {
        let file = try makeFile(labels: ["First", "Second"])
        let recorder = ProgressRecorder()
        try await engine.thumbnails(file) { await recorder.record(index: $0, data: $1) }
        let thumbnails = await recorder.thumbnails
        XCTAssertEqual(Set(thumbnails.keys), [0, 1])
        for data in thumbnails.values {
            XCTAssertEqual(Array(data.prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10])
            let image = try XCTUnwrap(NSBitmapImageRep(data: data))
            XCTAssertGreaterThan(image.pixelsWide, 0)
            XCTAssertGreaterThan(image.pixelsHigh, 0)
        }
    }

    func testSaveWritesExactBytesAndPreservesSource() async throws {
        let file = try makeFile()
        let result = PDFResult(data: file.data, suggestedName: "copy.pdf")
        let destination = folder.appendingPathComponent(result.suggestedName)
        try Data("old destination".utf8).write(to: destination)
        try await engine.save(result, to: destination, sources: [file.url])
        XCTAssertEqual(try Data(contentsOf: destination), file.data)
        XCTAssertEqual(try Data(contentsOf: file.url), file.data)
    }

    func testSaveRejectsSourceAndItsAliases() async throws {
        let file = try makeFile()
        let symlink = folder.appendingPathComponent("symlink.pdf")
        let hardlink = folder.appendingPathComponent("hardlink.pdf")
        try FileManager.default.createSymbolicLink(at: symlink, withDestinationURL: file.url)
        try FileManager.default.linkItem(at: file.url, to: hardlink)
        let result = PDFResult(data: Data("must not overwrite".utf8), suggestedName: "copy.pdf")
        for destination in [file.url, symlink, hardlink, folder.appendingPathComponent("sub/../source.pdf")] {
            await assertPDFError(.sourceOverwrite) {
                try await self.engine.save(result, to: destination, sources: [file.url])
            }
        }
        XCTAssertEqual(try Data(contentsOf: file.url), file.data)
    }

    func testSaveReportsUnwritableDestination() async throws {
        let file = try makeFile()
        await assertPDFError(.save) {
            try await self.engine.save(PDFResult(data: file.data, suggestedName: "copy.pdf"),
                to: self.folder.appendingPathComponent("missing/copy.pdf"), sources: [])
        }
    }

    func testAllOperationsHonorCancellation() async throws {
        let file = try makeFile()
        let engine = try XCTUnwrap(engine)
        let destination = folder.appendingPathComponent("cancelled.pdf")
        // Self-cancel before entering the engine: independent of task scheduling.
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            let operations: [() async throws -> Void] = [
                { _ = try await engine.load(file.url) },
                { _ = try await engine.compress(file, level: .balanced, progress: { _ in }) },
                { _ = try await engine.merge([file, file], progress: { _ in }) },
                { _ = try await engine.rotate(file, rotations: [0: 90], progress: { _ in }) },
                { try await engine.thumbnails(file, receive: { _, _ in }) },
                { try await engine.save(PDFResult(data: file.data, suggestedName: "cancelled.pdf"), to: destination, sources: []) }
            ]
            for operation in operations {
                do { try await operation(); XCTFail("Cancelled operation succeeded") }
                catch is CancellationError { }
                catch { XCTFail("Unexpected cancellation error: \(error)") }
            }
        }
        await task.value
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
    }

    func testMergeHonorsCancellationBetweenPages() async throws {
        let file = try makeFile(labels: ["First", "Second"])
        let engine = try XCTUnwrap(engine)
        let task = Task {
            try await engine.merge([file, file]) { _ in withUnsafeCurrentTask { $0?.cancel() } }
        }
        do { _ = try await task.value; XCTFail("Merge ignored cancellation") }
        catch is CancellationError { }
    }
}
