import SwiftUI
import AppKit

@MainActor
final class RemoveModel: ToolModel {
    @Published var thumbnails: [Int: NSImage] = [:]
    @Published private(set) var selection: Set<Int> = []
    private var anchor: Int?

    var remainingCount: Int { (files.first?.pageCount ?? 0) - selection.count }
    var canRemove: Bool { !selection.isEmpty && remainingCount > 0 }

    override func inputsChanged() async throws {
        thumbnails = [:]; selection = []; anchor = nil
        result = nil
        guard let file = files.first else { return }
        try await PDFEngine.shared.thumbnails(file) { index, data in
            await self.receiveThumbnail(index, data: data, total: file.pageCount)
        }
    }

    private func receiveThumbnail(_ index: Int, data: Data, total: Int) {
        thumbnails[index] = NSImage(data: data)
        progress = Double(index + 1) / Double(total)
    }

    func select(_ index: Int, modifiers: NSEvent.ModifierFlags) {
        guard !busy, let file = files.first, (0..<file.pageCount).contains(index) else { return }
        if modifiers.contains(.shift), let anchor {
            let range = Set(min(anchor, index)...max(anchor, index))
            selection = modifiers.contains(.command) ? selection.union(range) : range
        } else if modifiers.contains(.command) {
            if selection.contains(index) { selection.remove(index) } else { selection.insert(index) }
            anchor = index
        } else { selection = [index]; anchor = index }
        result = nil
    }

    func selectAll() {
        guard !busy, let file = files.first else { return }
        selection = Set(0..<file.pageCount)
        result = nil
    }

    func clearSelection() {
        guard !busy else { return }
        selection = []; anchor = nil
        result = nil
    }

    func prepareAndSave() {
        guard !busy, canRemove, let file = files.first else { return }
        let removed = selection
        let name = file.url.deletingPathExtension().lastPathComponent + "-removed.pdf"
        guard let destination = saveDestination(name) else { return }
        run {
            let output = try await PDFEngine.shared.removePages(file, removing: removed) { value in
                await self.report(value)
            }
            try await PDFEngine.shared.save(output, to: destination, sources: [file.url])
            self.result = output
            self.savedURL = destination
            self.status = "Saved \(destination.lastPathComponent)."
        }
    }
}
