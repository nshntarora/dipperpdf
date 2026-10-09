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
    static func save(name: String, contentType: UTType = .pdf) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [contentType]
        panel.nameFieldStringValue = name
        panel.canCreateDirectories = true
        panel.title = contentType == .plainText ? "Save extracted text" : "Save a new PDF"
        return panel.runModal() == .OK ? panel.url : nil
    }
}
