import AppKit
import PDFKit
import XCTest
@testable import DipperPDF

final class UnlockTests: PDFTestCase {
    private func encryptedFile(user: String = "reader", restricted: Bool = false) throws -> PDFFile {
        let source = try makeFile(labels: ["First page", "Second page"])
        let document = try XCTUnwrap(PDFDocument(data: source.data))
        let page = try XCTUnwrap(document.page(at: 0))
        page.rotation = 90
        page.setBounds(CGRect(x: 12, y: 20, width: 500, height: 760), for: .cropBox)
        let note = PDFAnnotation(bounds: CGRect(x: 40, y: 50, width: 80, height: 40), forType: .text, withProperties: nil)
        note.contents = "Retained note"
        page.addAnnotation(note)
        document.documentAttributes = [PDFDocumentAttribute.titleAttribute: "Protected document"]
        var options: [PDFDocumentWriteOption: Any] = [.ownerPasswordOption: "owner", .userPasswordOption: user]
        if restricted { options[.accessPermissionsOption] = 0 }
        let data = try XCTUnwrap(document.dataRepresentation(options: options))
        try data.write(to: source.url)
        XCTAssertTrue(try XCTUnwrap(PDFDocument(data: data)).isEncrypted)
        return PDFFile(url: source.url, data: data, pageCount: 2)
    }

    func testPasswordRemovalPreservesPagesAndValidatesUnencryptedOutput() async throws {
        let source = try encryptedFile()
        let snapshot = try await engine.loadForUnlock(source.url)
        XCTAssertEqual(snapshot.data, source.data)
        XCTAssertEqual(snapshot.pageCount, 0)
        let original = try XCTUnwrap(PDFDocument(data: source.data))
        XCTAssertTrue(original.unlock(withPassword: "reader"))
        let result = try await engine.unlock(snapshot, password: "reader") { _ in }
        let output = try XCTUnwrap(PDFDocument(data: result.data))
        XCTAssertFalse(output.isEncrypted)
        XCTAssertFalse(output.isLocked)
        XCTAssertEqual(output.pageCount, 2)
        XCTAssertEqual(output.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String, "Protected document")
        for (index, label) in ["First page", "Second page"].enumerated() {
            let page = try XCTUnwrap(output.page(at: index))
            XCTAssertTrue(try XCTUnwrap(page.string).contains(label))
            XCTAssertEqual(page.rotation, original.page(at: index)?.rotation)
            XCTAssertEqual(page.bounds(for: .cropBox), original.page(at: index)?.bounds(for: .cropBox))
            XCTAssertEqual(page.bounds(for: .mediaBox), original.page(at: index)?.bounds(for: .mediaBox))
        }
        XCTAssertTrue(try XCTUnwrap(output.page(at: 0)).annotations.contains { $0.contents == "Retained note" })
        XCTAssertEqual(result.suggestedName, "source-unlocked.pdf")
        XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        _ = try await engine.load(writeResult(result))
    }

    private func writeResult(_ result: PDFResult) throws -> URL {
        let url = folder.appendingPathComponent(result.suggestedName)
        try result.data.write(to: url)
        return url
    }

    func testWrongPasswordAndRestrictedUserRequireRetryWithOwnerPassword() async throws {
        let source = try encryptedFile(restricted: true)
        for password in ["wrong", ""] {
            do { _ = try await engine.unlock(source, password: password) { _ in }; XCTFail("Expected password failure") }
            catch PDFError.incorrectPassword { }
        }
        do { _ = try await engine.unlock(source, password: "reader") { _ in }; XCTFail("Expected permission failure") }
        catch PDFError.restrictedPDF { }
        let output = try await engine.unlock(source, password: "owner") { _ in }
        XCTAssertFalse(try XCTUnwrap(PDFDocument(data: output.data)).isEncrypted)
    }

    func testAlreadyOpenEncryptedPDFStillChecksPermissions() async throws {
        let source = try encryptedFile(user: "", restricted: true)
        XCTAssertFalse(try XCTUnwrap(PDFDocument(data: source.data)).isLocked)
        let loaded = try await engine.loadForUnlock(source.url)
        for password in ["", "wrong"] {
            do { _ = try await engine.unlock(loaded, password: password) { _ in }; XCTFail("Expected permission failure") }
            catch PDFError.restrictedPDF { }
        }
        let result = try await engine.unlock(loaded, password: "owner") { _ in }
        XCTAssertFalse(try XCTUnwrap(PDFDocument(data: result.data)).isEncrypted)
        await assertPDFError(.encrypted) { _ = try await self.engine.load(source.url) }
        await assertPDFError(.encrypted) { _ = try await self.engine.reversePages(loaded) { _ in } }
    }

    func testEmptyUserPasswordWithoutRestrictionsNeedsNoPassword() async throws {
        let source = try encryptedFile(user: "")
        let result = try await engine.unlock(source, password: "") { _ in }
        XCTAssertFalse(try XCTUnwrap(PDFDocument(data: result.data)).isEncrypted)
    }

    func testPlainMalformedAndUnreadableInputsAreRejected() async throws {
        let plain = try makeFile()
        do { _ = try await engine.loadForUnlock(plain.url); XCTFail("Expected unencrypted rejection") }
        catch PDFError.notEncrypted { }
        do { _ = try await engine.unlock(plain, password: "reader") { _ in }; XCTFail("Expected unencrypted rejection") }
        catch PDFError.notEncrypted { }
        try Data("not a PDF".utf8).write(to: plain.url)
        await assertPDFError(.invalid) { _ = try await self.engine.loadForUnlock(plain.url) }
        await assertPDFError(.permission) { _ = try await self.engine.loadForUnlock(self.folder.appendingPathComponent("missing.pdf")) }
    }

    func testSnapshotAndCancellationAtPageAndPublicationBoundaries() async throws {
        let source = try encryptedFile()
        let loaded = try await engine.loadForUnlock(source.url)
        try Data("Replaced after import".utf8).write(to: source.url)
        let result = try await engine.unlock(loaded, password: "reader") { _ in }
        XCTAssertEqual(PDFDocument(data: result.data)?.pageCount, 2)
        XCTAssertEqual(try Data(contentsOf: source.url), Data("Replaced after import".utf8))
        let engine = try XCTUnwrap(engine)
        for boundary in [0.5, 1.0] {
            let task = Task {
                try await engine.unlock(loaded, password: "reader") { value in
                    if value >= boundary { withUnsafeCurrentTask { $0?.cancel() } }
                }
            }
            do { _ = try await task.value; XCTFail("Expected cancellation") }
            catch is CancellationError { }
        }
    }

    @MainActor func testWorkflowImportRetrySaveAndInvalidation() async throws {
        let source = try encryptedFile()
        let destination = folder.appendingPathComponent("unlocked.pdf")
        let model = UnlockModel(saveDestination: { _ in destination })
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.files.first?.data, source.data)
        model.updatePassword("wrong")
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertEqual(model.error, PDFError.incorrectPassword.localizedDescription)
        XCTAssertFalse(FileManager.default.fileExists(atPath: destination.path))
        model.updatePassword("reader")
        model.prepareAndSave()
        model.updatePassword("ignored while busy")
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.password, "")
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.progress, 1)
        XCTAssertFalse(try XCTUnwrap(PDFDocument(url: destination)).isEncrypted)
        XCTAssertEqual(try Data(contentsOf: destination), model.result?.data)
        // The password has been cleared; another save reuses the validated unlocked bytes.
        model.prepareAndSave()
        await model.waitForCompletion()
        XCTAssertNil(model.error)
        XCTAssertEqual(model.savedURL, destination)
        XCTAssertEqual(model.password, "")
        model.updatePassword("new password")
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        model.add([source.url], multiple: false)
        await model.waitForCompletion()
        XCTAssertEqual(model.password, "")
    }

    @MainActor func testWorkflowCancellationPanelCancellationAndSourceProtection() async throws {
        let source = try encryptedFile()
        let symbolic = folder.appendingPathComponent("symbolic.pdf")
        let hard = folder.appendingPathComponent("hard.pdf")
        try FileManager.default.createSymbolicLink(at: symbolic, withDestinationURL: source.url)
        try FileManager.default.linkItem(at: source.url, to: hard)
        for destination in [source.url, symbolic, hard] {
            let model = UnlockModel(saveDestination: { _ in destination })
            model.files = [source]
            model.updatePassword("reader")
            model.prepareAndSave()
            await model.waitForCompletion()
            XCTAssertEqual(model.error, PDFError.sourceOverwrite.localizedDescription)
            XCTAssertNil(model.result)
            XCTAssertEqual(try Data(contentsOf: source.url), source.data)
        }
        let model = UnlockModel(saveDestination: { _ in self.folder.appendingPathComponent("cancelled.pdf") })
        model.files = [source]
        model.updatePassword("reader")
        model.prepareAndSave()
        model.cancel()
        await model.waitForCompletion()
        XCTAssertNil(model.result)
        XCTAssertNil(model.savedURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.appendingPathComponent("cancelled.pdf").path))
        let panel = UnlockModel(saveDestination: { _ in nil })
        panel.files = [source]
        panel.updatePassword("reader")
        panel.prepareAndSave()
        XCTAssertFalse(panel.busy)
        XCTAssertNil(panel.result)
    }
}
