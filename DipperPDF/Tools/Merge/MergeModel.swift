import SwiftUI

@MainActor
final class MergeModel: ToolModel {
    func move(_ id: UUID, before target: UUID) {
        guard !busy, id != target,
              let source = files.firstIndex(where: { $0.id == id }),
              let destination = files.firstIndex(where: { $0.id == target }) else { return }
        files.move(fromOffsets: IndexSet(integer: source), toOffset: destination > source ? destination + 1 : destination)
        result = nil
    }
    func nudge(_ id: UUID, by offset: Int) {
        guard let index = files.firstIndex(where: { $0.id == id }), files.indices.contains(index + offset) else { return }
        files.swapAt(index, index + offset)
        result = nil
    }
    func remove(_ id: UUID) { files.removeAll { $0.id == id }; result = nil }
    func merge() {
        let inputs = files
        run {
            self.result = try await PDFEngine.shared.merge(inputs) { value in await self.report(value) }
        }
    }
}
