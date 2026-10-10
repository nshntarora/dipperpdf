import SwiftUI
import AppKit

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
            CommandGroup(after: .pasteboard) {
                Button("Select All Pages") { selectAllPages?() }
                    .keyboardShortcut("a").disabled(selectAllPages == nil)
            }
        }
    }
}

@MainActor
private final class DipperAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Use this build's bundled artwork even when the Dock has cached an older icon.
        guard let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
              let icon = NSImage(contentsOf: url) else { return }
        NSApplication.shared.applicationIconImage = icon
    }
}
