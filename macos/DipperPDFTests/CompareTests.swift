import AppKit
import CoreText
import PDFKit
import XCTest
@testable import DipperPDF

final class CompareTests: PDFTestCase {
    private func makeLines(_ name: String, lines: [String]) throws -> PDFFile {
        let bytes = NSMutableData()
        var bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let consumer = try XCTUnwrap(CGDataConsumer(data: bytes as CFMutableData))
        let context = try XCTUnwrap(CGContext(consumer: consumer, mediaBox: &bounds, nil))
        context.beginPDFPage(nil)
        for (index, line) in lines.enumerated() {
            let text = NSAttributedString(string: line, attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, 12, nil)
            ])
            context.textPosition = CGPoint(x: 36, y: 740 - index * 20)
            CTLineDraw(CTLineCreateWithAttributedString(text), context)
        }
        context.endPDFPage()
        context.closePDF()
        let url = folder.appendingPathComponent(name)
        try (bytes as Data).write(to: url)
        return PDFFile(url: url, data: bytes as Data, pageCount: 1)
    }

    func testRepeatedLinesAndUnicodePreserveUnchangedContext() async throws {
        let original = try makeLines("Original.pdf", lines: ["Repeated line", "Removed café", "Repeated line", "Last line"])
        let revised = try makeLines("Revised.pdf", lines: ["Repeated line", "Repeated line", "Added résumé", "Last line"])
        let output = try await engine.compareText(original, revised: revised) { _ in }
        XCTAssertEqual(output.changedPages, [1])
        XCTAssertEqual(output.addedLines, 1)
        XCTAssertEqual(output.removedLines, 1)
        let report = try XCTUnwrap(PDFDocument(data: output.result.data)?.string)
        XCTAssertTrue(report.contains("− Removed café"))
        XCTAssertTrue(report.contains("+ Added résumé"))
        XCTAssertTrue(report.contains("= Last line"))
    }

    @MainActor func testBothInputsAndTheirAliasesAreProtected() async throws {
        let original = try makeFile("Original.pdf")
        let revised = try makeFile("Revised.pdf")
        for source in [original, revised] {
            let symbolic = folder.appendingPathComponent(source.name + "-symbolic.pdf")
            let hard = folder.appendingPathComponent(source.name + "-hard.pdf")
            try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
            try FileManager.default.linkItem(at: source.url, to: hard)
            for destination in [source.url, symbolic, hard] {
                let model = CompareModel(saveDestination: { _ in destination })
                model.files = [original, revised]
                model.prepare()
                await model.waitForCompletion()
                model.save()
                await model.waitForCompletion()
                XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
                XCTAssertNotNil(model.result)
                XCTAssertNil(model.savedURL)
                XCTAssertEqual(try Data(contentsOf: source.url), source.data)
            }
        }
    }

    func testIdenticalTextHasNoChangesAndReportIsSearchable() async throws {
        let file = try makeFile(labels: ["Unchanged first", "Unchanged second"])
        let output = try await engine.compareText(file, revised: file) { _ in }
        XCTAssertEqual(output.changedPages, [])
        XCTAssertEqual(output.addedLines, 0)
        XCTAssertEqual(output.removedLines, 0)
        XCTAssertEqual(output.pagesWithoutText, [])
        let report = try XCTUnwrap(PDFDocument(data: output.result.data)?.string)
        XCTAssertTrue(report.contains("No selectable-text changes."))
        XCTAssertTrue(report.contains("Unchanged first"))
        XCTAssertEqual(output.result.suggestedName, "source-comparison.pdf")
    }

    func testReplacementsExtraPagesAndSwapDirection() async throws {
        let original = try makeFile("Original.pdf", labels: ["Old wording", "Same wording"])
        let revised = try makeFile("Revised.pdf", labels: ["New wording", "Same wording", "Added page"])
        let recorder = ProgressRecorder()
        let output = try await engine.compareText(original, revised: revised) { await recorder.record($0) }
        XCTAssertEqual(output.changedPages, [1, 3])
        XCTAssertEqual(output.addedLines, 2)
        XCTAssertEqual(output.removedLines, 1)
        let report = try XCTUnwrap(PDFDocument(data: output.result.data)?.string)
        XCTAssertTrue(report.contains("− Old wording"))
        XCTAssertTrue(report.contains("+ New wording"))
        XCTAssertTrue(report.contains("Original page missing"))
        let reverse = try await engine.compareText(revised, revised: original) { _ in }
        XCTAssertEqual(reverse.addedLines, 1)
        XCTAssertEqual(reverse.removedLines, 2)
        XCTAssertEqual(reverse.changedPages, [1, 3])
        let progress = await recorder.values
        XCTAssertEqual(progress.last, 1)
        XCTAssertEqual(progress, progress.sorted())
        XCTAssertEqual(try Data(contentsOf: original.url), original.data)
        XCTAssertEqual(try Data(contentsOf: revised.url), revised.data)
    }

    func testMissingTextRequiresReviewEvenWhenBothPagesHaveNoText() async throws {
        let blank = try makeFile("Blank.pdf", labels: [""])
        let text = try makeFile("Text.pdf")
        let both = try await engine.compareText(blank, revised: blank) { _ in }
        XCTAssertEqual(both.pagesWithoutText, [1])
        XCTAssertTrue(try XCTUnwrap(PDFDocument(data: both.result.data)?.string).contains("equality cannot be determined"))
        let one = try await engine.compareText(blank, revised: text) { _ in }
        XCTAssertEqual(one.pagesWithoutText, [1])
        XCTAssertEqual(one.changedPages, [1])
        XCTAssertEqual(one.addedLines, 1)
    }

    func testMalformedEncryptedAndCancelledInputs() async throws {
        let original = try makeFile(labels: ["First", "Second"])
        let bad = PDFFile(url: original.url, data: Data("invalid".utf8), pageCount: 1)
        await assertPDFError(.invalid) { _ = try await self.engine.compareText(original, revised: bad) { _ in } }
        let doc = try XCTUnwrap(PDFDocument(data: original.data))
        let encrypted = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        await assertPDFError(.encrypted) {
            _ = try await self.engine.compareText(PDFFile(url: original.url, data: encrypted, pageCount: 2), revised: original) { _ in }
        }
        let engine = try XCTUnwrap(engine)
        for boundary in [0.45, 1.0] {
            let task = Task {
                try await engine.compareText(original, revised: original) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowInputLimitInvalidationAndSaveRetry() async throws {
        let original = try makeFile("Original.pdf", labels: ["Old wording"])
        let revised = try makeFile("Revised.pdf", labels: ["New wording"])
        let destination = folder.appendingPathComponent("Report.pdf")
        var selected: URL?
        var requests = 0
        let model = CompareModel(saveDestination: { _ in requests += 1; return selected })
        model.prepare()
        XCTAssertFalse(model.busy)
        model.add([original.url, revised.url], multiple: true)
        await model.waitForCompletion()
        XCTAssertTrue(model.canPrepare)
        model.add([original.url], multiple: true)
        XCTAssertNotNil(model.error)
        XCTAssertEqual(model.files.count, 2)
        model.prepare()
        model.prepare()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(requests, 0)
        XCTAssertNotNil(model.comparison)
        model.save()
        XCTAssertNotNil(model.result)
        for source in [original.url, revised.url] {
            selected = source
            model.save()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
            XCTAssertNotNil(model.result)
        }
        selected = destination
        model.save()
        await model.waitForCompletion()
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        model.swap()
        XCTAssertEqual(model.files.first?.url, revised.url)
        XCTAssertNil(model.result)
        XCTAssertNil(model.comparison)
        XCTAssertNil(model.savedURL)
        model.prepare()
        await model.waitForCompletion()
        model.remove(model.files[0].id)
        XCTAssertFalse(model.canPrepare)
        XCTAssertNil(model.result)
        XCTAssertNil(model.comparison)
        model.add([revised.url], multiple: true)
        await model.waitForCompletion()
        XCTAssertNil(model.result)
    }

    @MainActor func testBusyExclusionAndCancellation() async throws {
        let file = try makeFile(labels: ["First", "Second"])
        let model = CompareModel()
        model.files = [file, file]
        model.prepare()
        model.swap()
        model.remove(file.id)
        XCTAssertEqual(model.files.count, 2)
        model.cancel()
        await model.waitForCompletion()
        XCTAssertFalse(model.busy)
        XCTAssertNil(model.result)
        XCTAssertNil(model.comparison)
        model.prepare()
        await model.waitForCompletion()
        XCTAssertNotNil(model.result)
    }

    func testLongReportPaginatesWithoutLosingText() async throws {
        let labels = (1...90).map { "Unique page \($0)" }
        let original = try makeFile(labels: labels)
        let revised = try makeFile("Revised.pdf", labels: labels.map { $0 + " revised" })
        let output = try await engine.compareText(original, revised: revised) { _ in }
        let document = try XCTUnwrap(PDFDocument(data: output.result.data))
        XCTAssertGreaterThan(document.pageCount, 1)
        XCTAssertTrue(try XCTUnwrap(document.string).contains("Unique page 90 revised"))
        XCTAssertEqual(output.changedPages.count, 90)
    }
}
