import SwiftUI

@MainActor
final class MergeModel: ToolModel {
    func move(_ id: UUID, over target: UUID) {
        guard !busy, id != target,
              let source = files.firstIndex(where: { $0.id == id }),
              let destination = files.firstIndex(where: { $0.id == target }) else { return }
        // SwiftUI's destination offset moves a row after the target when dragging down.
        files.move(fromOffsets: IndexSet(integer: source), toOffset: destination > source ? destination + 1 : destination)
        result = nil
    }
    func move(from offsets: IndexSet, to destination: Int) {
        guard !busy else { return }
        files.move(fromOffsets: offsets, toOffset: destination)
        result = nil
    }
    func nudge(_ id: UUID, by offset: Int) {
        guard !busy, let index = files.firstIndex(where: { $0.id == id }),
              files.indices.contains(index + offset) else { return }
        files.swapAt(index, index + offset)
        result = nil
    }
    func remove(_ id: UUID) {
        guard !busy else { return }
        files.removeAll { $0.id == id }
        result = nil
    }
    func merge() {
        guard !busy, files.count >= 2 else { return }
        let inputs = files
        result = nil
        run {
            let output = try await PDFEngine.shared.merge(inputs) { value in await self.report(value) }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
