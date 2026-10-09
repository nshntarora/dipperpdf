import AppKit
import UniformTypeIdentifiers

@MainActor
enum FilePanels {
    static func open(multiple: Bool) -> [URL] {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = multiple
        panel.canChooseDirectories = false
        panel.prompt = "Add PDF"
        return panel.runModal() == .OK ? panel.urls : []
    }
    static func folder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.title = "Choose a folder for split PDFs"
        panel.prompt = "Save Here"
        return panel.runModal() == .OK ? panel.url : nil
    }
    static func save(name: String) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = name
        panel.canCreateDirectories = true
        panel.title = "Save a new PDF"
        return panel.runModal() == .OK ? panel.url : nil
    }
}
