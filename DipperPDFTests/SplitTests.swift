import PDFKit
import XCTest
@testable import DipperPDF

final class SplitTests: PDFTestCase {
    func testSplitPreservesOrderTextGeometryAndSnapshot() async throws {
        let source = try makeFile(labels: ["One", "Two", "Three", "Four", "Five"])
        let input = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(input.page(at: 2))
        page.rotation = 90
        page.setBounds(CGRect(x: 10, y: 20, width: 400, height: 760), for: .cropBox)
        let note = PDFAnnotation(bounds: CGRect(x: 50, y: 100, width: 30, height: 30), forType: .text, withProperties: nil)
        note.contents = "Keep this note"
        page.addAnnotation(note)
        let snapshot = PDFFile(url: source.url, data: try XCTUnwrap(input.dataRepresentation()), pageCount: 5)
        try Data("Changed on disk".utf8).write(to: source.url)
        let recorder = ProgressRecorder()
        let outputs = try await engine.split(snapshot, pagesPerFile: 2) { await recorder.record($0) }
        XCTAssertEqual(outputs.map(\.suggestedName), ["source-pages-1-2.pdf", "source-pages-3-4.pdf", "source-pages-5-5.pdf"])
        let docs = try outputs.map { try XCTUnwrap(PDFDocument(data: $0.data)) }
        XCTAssertEqual(docs.map(\.pageCount), [2, 2, 1])
        var labels = ["One", "Two", "Three", "Four", "Five"].makeIterator()
        for doc in docs {
            for index in 0..<doc.pageCount {
                XCTAssertTrue(try XCTUnwrap(doc.page(at: index)?.string).contains(try XCTUnwrap(labels.next())))
            }
        }
        let retained = try XCTUnwrap(docs[1].page(at: 0))
        XCTAssertEqual(retained.rotation, 90)
        XCTAssertEqual(retained.bounds(for: .cropBox), page.bounds(for: .cropBox))
        XCTAssertEqual(retained.bounds(for: .mediaBox), page.bounds(for: .mediaBox))
        XCTAssertTrue(retained.annotations.contains { $0.contents == "Keep this note" })
        let progress = await recorder.values
        XCTAssertEqual(progress, [0.2, 0.4, 0.6, 0.8, 1])
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Changed on disk".utf8))
    }

    func testSinglePagesAndWholeDocument() async throws {
        let source = try makeFile(labels: ["A", "B", "C"])
        let singles = try await engine.split(source, pagesPerFile: 1) { _ in }
        XCTAssertEqual(singles.count, 3)
        XCTAssertTrue(singles.allSatisfy { PDFDocument(data: $0.data)?.pageCount == 1 })
        let whole = try await engine.split(source, pagesPerFile: 3) { _ in }
        XCTAssertEqual(whole.count, 1)
        XCTAssertEqual(PDFDocument(data: whole[0].data)?.pageCount, 3)
        let single = try makeFile("single.pdf")
        let one = try await engine.split(single, pagesPerFile: 1) { _ in }
        XCTAssertEqual(one.count, 1)
    }

    func testInvalidCountsAndInputs() async throws {
        let source = try makeFile(labels: ["A", "B"])
        for count in [0, -1, 3, Int.max] {
            await assertPDFError(.splitCount) {
                _ = try await self.engine.split(source, pagesPerFile: count) { _ in }
            }
        }
        let bad = PDFFile(url: source.url, data: Data("bad".utf8), pageCount: 2)
        await assertPDFError(.invalid) { _ = try await self.engine.split(bad, pagesPerFile: 1) { _ in } }
        let doc = try XCTUnwrap(PDFDocument(data: source.data))
        let bytes = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: ""]))
        let encrypted = PDFFile(url: source.url, data: bytes, pageCount: 2)
        await assertPDFError(.encrypted) { _ = try await self.engine.split(encrypted, pagesPerFile: 1) { _ in } }
    }

    func testProcessingCancellationBetweenPagesAndBeforePublishing() async throws {
        let source = try makeFile(labels: ["A", "B", "C"])
        let engine = try XCTUnwrap(engine)
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.split(source, pagesPerFile: 2) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    func testBatchSaveUsesFreshFolderAndLeavesSourcesAndAliasesUnchanged() async throws {
        let source = try makeFile(labels: ["A", "B", "C"])
        let outputs = try await engine.split(source, pagesPerFile: 2) { _ in }
        let existing = folder.appendingPathComponent("source-split")
        try FileManager.default.createDirectory(at: existing, withIntermediateDirectories: false)
        let symbolic = existing.appendingPathComponent(outputs[0].suggestedName)
        let hard = existing.appendingPathComponent(outputs[1].suggestedName)
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        let recorder = ProgressRecorder()
        let destination = try await engine.saveSplit(outputs, in: folder, name: "source-split", sources: [source.url]) { await recorder.record($0) }
        XCTAssertEqual(destination.lastPathComponent, "source-split-2")
        for output in outputs {
            XCTAssertEqual(try Data(contentsOf: destination.appendingPathComponent(output.suggestedName)), output.data)
        }
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        XCTAssertEqual(try Data(contentsOf: symbolic), source.data)
        XCTAssertEqual(try Data(contentsOf: hard), source.data)
        let values = await recorder.values
        XCTAssertEqual(values, [0.5, 1])
        XCTAssertFalse(try FileManager.default.contentsOfDirectory(atPath: folder.path).contains { $0.hasPrefix(".dipper") })
    }

    func testCancelledBatchSaveCleansUpEveryOutput() async throws {
        let source = try makeFile(labels: ["A", "B", "C"])
        let engine = try XCTUnwrap(engine)
        let folder = try XCTUnwrap(folder)
        let outputs = try await engine.split(source, pagesPerFile: 1) { _ in }
        for boundary in [1.0 / 3.0, 1.0] {
            let task = Task {
                try await engine.saveSplit(outputs, in: folder, name: "source-split", sources: [source.url]) { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
            XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), ["source.pdf"])
        }
    }

    func testSaveFailureAndInvalidNamesDoNotPublishPartialBatch() async throws {
        let source = try makeFile()
        let valid = PDFResult(data: source.data, suggestedName: "part.pdf")
        for outputs in [[], [valid, valid], [PDFResult(data: source.data, suggestedName: "../escape.pdf")]] {
            await assertPDFError(.save) {
                _ = try await self.engine.saveSplit(outputs, in: self.folder, name: "split", sources: [source.url]) { _ in }
            }
        }
        await assertPDFError(.save) {
            _ = try await self.engine.saveSplit([valid], in: source.url, name: "split", sources: [source.url]) { _ in }
        }
        // Force the publication to fail after staging all files.
        await assertPDFError(.save) {
            _ = try await self.engine.saveSplit([valid], in: self.folder, name: String(repeating: "x", count: 300), sources: [source.url]) { _ in }
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), ["source.pdf"])
    }

    @MainActor func testWorkflowSaveBusyExclusionInvalidationAndImportReset() async throws {
        let source = try makeFile(labels: ["A", "B", "C", "D", "E"])
        var requests = 0
        let model = SplitModel(chooseFolder: { requests += 1; return self.folder })
        model.splitAndSave()
        XCTAssertEqual(requests, 0)
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.pagesPerFile, 1)
        model.setPagesPerFile(2)
        XCTAssertEqual(model.outputCount, 3)
        model.splitAndSave()
        model.setPagesPerFile(4)
        model.splitAndSave()
        XCTAssertEqual(model.pagesPerFile, 2)
        XCTAssertEqual(requests, 1)
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.outputNames.count, 3)
        XCTAssertEqual(model.savedURL?.lastPathComponent, "source-split")
        XCTAssertEqual(model.progress, 1)
        model.setPagesPerFile(3)
        XCTAssertTrue(model.outputNames.isEmpty)
        XCTAssertNil(model.savedURL)
        XCTAssertNil(model.status)
        model.setPagesPerFile(0)
        model.setPagesPerFile(6)
        XCTAssertEqual(model.pagesPerFile, 3)
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.pagesPerFile, 1)
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
    }

    @MainActor func testCancelledFolderPanelAndJobCanRetry() async throws {
        let source = try makeFile(labels: ["A", "B"])
        let cancelled = SplitModel(chooseFolder: { nil })
        cancelled.files = [source]
        cancelled.splitAndSave()
        XCTAssertFalse(cancelled.busy)
        XCTAssertNil(cancelled.savedURL)
        let model = SplitModel(chooseFolder: { self.folder })
        model.files = [source]
        model.splitAndSave()
        model.cancel()
        await model.waitForCompletion()
        XCTAssertTrue(model.outputNames.isEmpty)
        XCTAssertNil(model.savedURL)
        XCTAssertEqual(model.status, "Cancelled. Your originals are unchanged.")
        model.splitAndSave()
        await model.waitForCompletion()
        XCTAssertEqual(model.outputNames.count, 2)
        XCTAssertNil(model.error)
    }
}
