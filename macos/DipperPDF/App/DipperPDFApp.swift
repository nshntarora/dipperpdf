import SwiftUI
import AppKit
import Foundation

@main
struct DipperPDFApp: App {
    @NSApplicationDelegateAdaptor(DipperAppDelegate.self) private var appDelegate
    @FocusedValue(\.selectAllPages) private var selectAllPages
    var body: some Scene {
        WindowGroup {
            AppShell().frame(minWidth: 900, minHeight: 650)
                .tint(DipperTheme.accent)
                .foregroundStyle(DipperTheme.ink)
        }
        .defaultSize(width: 1050, height: 800)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About DipperPDF") { appDelegate.showAboutPanel() }
            }
            CommandGroup(after: .pasteboard) {
                Button("Select All Pages") { selectAllPages?() }
                    .keyboardShortcut("a").disabled(selectAllPages == nil)
            }
        }
    }
}

@MainActor
private final class DipperAppDelegate: NSObject, NSApplicationDelegate {
    private var aboutPanel: NSPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Use this build's bundled artwork even when the Dock has cached an older icon.
        guard let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
              let icon = NSImage(contentsOf: url) else { return }
        NSApplication.shared.applicationIconImage = icon
    }

    func showAboutPanel() {
        if let aboutPanel {
            aboutPanel.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 580),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "About DipperPDF"
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = false
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentViewController = NSHostingController(rootView: DipperAboutView())
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        aboutPanel = panel
    }
}

private struct DipperAboutView: View {
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

    var body: some View {
        VStack(spacing: 18) {
            DipperAppIcon(size: 92)

            VStack(spacing: 6) {
                Text("DipperPDF")
                    .font(.system(size: 28, weight: .bold))
                Text(versionText)
                    .font(DipperTheme.bodyFont)
                    .foregroundStyle(DipperTheme.secondary)
            }

            Text("Private PDF tools, right on your Mac.")
                .font(.title3)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                aboutDetail("lock.fill", title: "Your PDFs stay private", detail: "Files are processed locally and are never uploaded.")
                aboutDetail("doc.on.doc", title: "Originals stay protected", detail: "Every tool saves a separate output file.")
                aboutDetail("person.crop.circle.badge.checkmark", title: "No account required", detail: "DipperPDF is free, offline, and open source.")
            }
            .padding(18)
            .toolSurface()

            HStack(spacing: 18) {
                Link("DipperPDF.com", destination: URL(string: "https://dipperpdf.com")!)
                Link("Get help", destination: URL(string: "https://dipperpdf.com/docs")!)
                Link("Report an issue", destination: URL(string: "https://github.com/nshntarora/dipperpdf/issues")!)
            }
            .font(.callout)

            Text("© \(Calendar.current.component(.year, from: .now)) DipperPDF")
                .font(DipperTheme.captionFont)
                .foregroundStyle(DipperTheme.secondary)

            Button("Done") { NSApplication.shared.keyWindow?.performClose(nil) }
                .buttonStyle(ToolActionStyle())
                .keyboardShortcut(.defaultAction)
                .accessibilityHint("Closes the About DipperPDF window")
        }
        .padding(28)
        .frame(width: 500, height: 580)
        .background(DipperTheme.background)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("About DipperPDF")
    }

    private var versionText: String {
        guard let build, build != version else { return "Version \(version)" }
        return "Version \(version) (\(build))"
    }

    private func aboutDetail(_ symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(DipperTheme.accent)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail)
                    .font(DipperTheme.bodyFont)
                    .foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
