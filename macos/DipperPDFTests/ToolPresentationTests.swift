import AppKit
import PDFKit
import SwiftUI
import XCTest
@testable import DipperPDF

/// Native view-harness captures for visual review, not dialog or accessibility interaction tests.
final class ToolPresentationTests: PDFTestCase {
    @MainActor private var captureWindow: NSWindow?
    @MainActor func testAllToolLayoutsAtMinimumSizeInLightAndDark() async throws {
        let source = try makeFile("Example document.pdf", labels: ["Quarterly report", "Financial overview", "Next steps"])
        let outputFolder = FileManager.default.temporaryDirectory.appendingPathComponent("DipperPDF-UI-review", isDirectory: true)
        try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        defer { captureWindow?.close(); captureWindow = nil }
        print("Native UI harness captures: \(outputFolder.path)")
        for scheme in [ColorScheme.light, .dark] {
            let suffix = scheme == .light ? "light" : "dark"
            try await capture(AppShell(), name: "home-\(suffix)", size: CGSize(width: 1050, height: 800), scheme: scheme, folder: outputFolder)
            let sample = ReverseModel(saveDestination: { _ in self.folder.appendingPathComponent("saved-copy.pdf") })
            sample.files = [source]
            sample.busy = true
            sample.progress = 0.45
            sample.stage = "Preparing result…"
            try await capture(ReverseView(model: sample), name: "shared-processing-\(suffix)", scheme: scheme, folder: outputFolder)
            sample.busy = false
            sample.prepare()
            await sample.waitForCompletion()
            sample.save()
            await sample.waitForCompletion()
            try await capture(ToolStatus(model: sample), name: "shared-saved-\(suffix)", scheme: scheme, folder: outputFolder)
            for tool in PDFTool.allCases {
                try await capture(tool.destination, name: "\(tool.id)-empty-\(suffix)", scheme: scheme, folder: outputFolder)
                let (model, view, prepare) = try await loaded(tool, source: source)
                try await capture(view, name: "\(tool.id)-loaded-\(suffix)", scheme: scheme, folder: outputFolder)
                if let unlock = model as? UnlockModel { unlock.updatePassword("reader") }
                prepare()
                await model.waitForCompletion()
                XCTAssertNil(model.error, tool.title)
                XCTAssertFalse(model.preparedOutputs.isEmpty, tool.title)
                // Capture the actual prepared bytes in the shared result presentation.
                try await capture(ToolResultSection(tool: tool, model: model, detail: nil),
                            name: "\(tool.id)-result-\(suffix)", scheme: scheme, folder: outputFolder,
                            previewBarrier: tool == .text ? nil : model.preparedOutputs.first?.data)
                try await capture(view, name: "\(tool.id)-ready-\(suffix)", scheme: scheme, folder: outputFolder,
                                  previewBarrier: tool == .text ? nil : model.preparedOutputs.first?.data)
            }
        }
    }

    @MainActor func testRedactionStatesInLightAndDark() async throws {
        let source = try makeFile("Contact details.pdf", labels: [
            "Contact alice@example.com", "Call +1 (415) 555-0123", "Card 4111 1111 1111 1111"])
        let captures = FileManager.default.temporaryDirectory.appendingPathComponent("DipperPDF-Redact-review", isDirectory: true)
        try FileManager.default.createDirectory(at: captures, withIntermediateDirectories: true)
        defer { captureWindow?.close(); captureWindow = nil }
        print("Redaction UI captures: \(captures.path)")
        for scheme in [ColorScheme.light, .dark] {
            let suffix = scheme == .light ? "light" : "dark"
            let destination = folder.appendingPathComponent("redacted-\(suffix).pdf")
            let model = RedactModel(saveDestination: { _ in destination })
            try await capture(RedactView(model: model), name: "redact-empty-\(suffix)", scheme: scheme, folder: captures)
            model.files = [source]
            try await model.inputsChanged()
            model.update(RedactionSettings(lastPage: 3, emails: true, phones: true, creditCards: true))
            try await capture(RedactView(model: model), name: "redact-loaded-\(suffix)", scheme: scheme, folder: captures)
            try await capture(RedactView(model: model), name: "redact-settings-\(suffix)",
                              size: CGSize(width: 690, height: 1100), scheme: scheme, folder: captures)
            model.busy = true
            model.progress = 0.45
            model.stage = "Finding and redacting text…"
            try await capture(RedactView(model: model), name: "redact-processing-\(suffix)", scheme: scheme, folder: captures)
            model.busy = false
            model.prepare()
            await model.waitForCompletion()
            XCTAssertNil(model.error)
            XCTAssertEqual(model.matchCount, 3)
            let result = try XCTUnwrap(model.result)
            try await capture(RedactView(model: model), name: "redact-ready-\(suffix)", scheme: scheme, folder: captures, previewBarrier: result.data)
            try await capture(ToolResultSection(tool: .redact, model: model,
                detail: "3 text matches redacted · Image-only PDF at 144 dpi. Review every page before sharing."),
                name: "redact-result-\(suffix)", scheme: scheme, folder: captures, previewBarrier: result.data)
            model.save()
            await model.waitForCompletion()
            XCTAssertEqual(model.savedURL, destination)
            try await capture(ToolStatus(model: model), name: "redact-saved-\(suffix)", scheme: scheme, folder: captures)
            model.update(RedactionSettings(lastPage: 3, text: "No such phrase"))
            model.prepare()
            await model.waitForCompletion()
            XCTAssertNotNil(model.error)
            try await capture(ToolStatus(model: model), name: "redact-error-\(suffix)", scheme: scheme, folder: captures)
        }
    }

    @MainActor private func loaded(_ tool: PDFTool, source: PDFFile) async throws -> (ToolModel, AnyView, () -> Void) {
        let model: ToolModel
        let view: AnyView
        let prepare: () -> Void
        switch tool {
        case .compress: let m = CompressModel(); model = m; view = AnyView(CompressView(model: m)); prepare = m.compress
        case .merge: let m = MergeModel(); model = m; view = AnyView(MergeView(model: m)); prepare = m.merge
        case .rotate: let m = RotateModel(); model = m; view = AnyView(RotateView(model: m)); prepare = m.prepare
        case .remove: let m = RemoveModel(); model = m; view = AnyView(RemoveView(model: m)); prepare = m.prepare
        case .extract: let m = ExtractModel(); model = m; view = AnyView(ExtractView(model: m)); prepare = m.prepare
        case .split: let m = SplitModel(); model = m; view = AnyView(SplitView(model: m)); prepare = m.prepare
        case .number: let m = NumberModel(); model = m; view = AnyView(NumberView(model: m)); prepare = m.prepare
        case .reverse: let m = ReverseModel(); model = m; view = AnyView(ReverseView(model: m)); prepare = m.prepare
        case .metadata: let m = MetadataModel(); model = m; view = AnyView(MetadataView(model: m)); prepare = m.prepare
        case .text: let m = TextModel(); model = m; view = AnyView(TextView(model: m)); prepare = m.prepare
        case .watermark: let m = WatermarkModel(); model = m; view = AnyView(WatermarkView(model: m)); prepare = m.prepare
        case .redact: let m = RedactModel(); model = m; view = AnyView(RedactView(model: m)); prepare = m.prepare
        case .crop: let m = CropModel(); model = m; view = AnyView(CropView(model: m)); prepare = m.prepare
        case .annotations: let m = AnnotationsModel(); model = m; view = AnyView(AnnotationsView(model: m)); prepare = m.prepare
        case .unlock: let m = UnlockModel(); model = m; view = AnyView(UnlockView(model: m)); prepare = m.prepare
        }
        model.files = [source]
        if tool == .unlock {
            let doc = try XCTUnwrap(PDFDocument(data: source.data))
            let bytes = try XCTUnwrap(doc.dataRepresentation(options: [PDFDocumentWriteOption.ownerPasswordOption: "owner", PDFDocumentWriteOption.userPasswordOption: "reader"]))
            model.files = [PDFFile(url: source.url, data: bytes, pageCount: source.pageCount)]
        }
        try await model.inputsChanged()
        if let m = model as? MergeModel { m.files.append(try makeFile("Appendix.pdf")) }
        if let m = model as? RotateModel { m.setSelection([1]); m.rotate(by: 90) }
        if let m = model as? RemoveModel { m.setSelection([1]) }
        if let m = model as? ExtractModel { m.setSelection([0, 2]) }
        if let m = model as? RedactModel { m.update(RedactionSettings(lastPage: source.pageCount, text: "report")) }
        if let m = model as? UnlockModel { m.updatePassword("reader") }
        return (model, view, prepare)
    }

    @MainActor private func capture<V: View>(_ view: V, name: String,
                                             size: CGSize = CGSize(width: 690, height: 610),
                                             scheme: ColorScheme, folder: URL, previewBarrier: Data? = nil) async throws {
        let root = view.frame(width: size.width, height: size.height, alignment: .topLeading)
            .background(DipperTheme.background).tint(DipperTheme.accent).foregroundStyle(DipperTheme.ink)
            .environment(\.colorScheme, scheme)
        let host = NSHostingView(rootView: root)
        let window: NSWindow
        if let current = captureWindow {
            window = current
            window.setContentSize(size)
        } else {
            window = NSWindow(contentRect: CGRect(origin: .zero, size: size), styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            captureWindow = window
        }
        window.appearance = NSAppearance(named: scheme == .light ? .aqua : .darkAqua)
        window.contentView = host
        host.frame = CGRect(origin: .zero, size: size)
        host.layoutSubtreeIfNeeded()
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
        if let previewBarrier {
            // Wait for the actor's queued rendering, then let image delivery reach the view.
            _ = try await PDFEngine.shared.preview(previewBarrier, page: 0)
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async { continuation.resume() }
            }
        }
        host.layoutSubtreeIfNeeded()
        defer { window.contentView = nil }
        XCTAssertLessThanOrEqual(host.fittingSize.width, size.width + 1, name)
        XCTAssertLessThanOrEqual(host.fittingSize.height, size.height + 1, name)
        let bitmap = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: host.bounds))
        host.cacheDisplay(in: host.bounds, to: bitmap)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        try png.write(to: folder.appendingPathComponent(name + ".png"))
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
