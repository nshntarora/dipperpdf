import SwiftUI
import AppKit

@MainActor
final class RotateModel: ToolModel {
    @Published var thumbnails: [Int: NSImage] = [:]
    @Published var selection: Set<Int> = []
    @Published var rotations: [Int: Int] = [:]
    private var anchor: Int?

    override func inputsChanged() async throws {
        thumbnails = [:]; selection = []; rotations = [:]; anchor = nil
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
    }
    func setSelection(_ pages: Set<Int>) {
        guard !busy, let file = files.first, pages.allSatisfy({ (0..<file.pageCount).contains($0) }) else { return }
        selection = pages
        anchor = nil
    }

    func selectAll() {
        guard !busy, let file = files.first else { return }
        selection = Set(0..<file.pageCount)
    }
    func rotate(by degrees: Int) {
        guard !busy else { return }
        for index in selection { rotations[index] = ((rotations[index, default: 0] + degrees) % 360 + 360) % 360 }
        result = nil; status = nil
    }
    var hasChanges: Bool { rotations.values.contains { $0 != 0 } }
    func prepare() {
        guard !busy, hasChanges, let file = files.first else { return }
        let changes = rotations
        result = nil
        run {
            let output = try await PDFEngine.shared.rotate(file, rotations: changes) { value in await self.report(value) }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
