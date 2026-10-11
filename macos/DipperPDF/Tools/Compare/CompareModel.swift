import SwiftUI

@MainActor
final class CompareModel: ToolModel {
    @Published private(set) var comparison: PDFComparison?
    var canPrepare: Bool { files.count == 2 && !busy }

    override func add(_ urls: [URL], multiple: Bool) {
        guard !busy, !urls.isEmpty else { return }
        guard files.count + urls.count <= 2 else {
            error = "Choose exactly two PDFs. Remove an input before adding its replacement."
            return
        }
        super.add(urls, multiple: true)
    }

    override func invalidateResult() {
        comparison = nil
        super.invalidateResult()
    }

    func remove(_ id: UUID) {
        guard !busy else { return }
        files.removeAll { $0.id == id }
        invalidateResult()
    }

    func swap() {
        guard canPrepare else { return }
        files.swapAt(0, 1)
        invalidateResult()
    }

    func prepare() {
        guard canPrepare else { return }
        let original = files[0], revised = files[1]
        invalidateResult()
        run(stage: "Comparing selectable text…") {
            let comparison = try await PDFEngine.shared.compareText(original, revised: revised) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.comparison = comparison
            self.result = comparison.result
        }
    }
}
