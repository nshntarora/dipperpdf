import SwiftUI

@MainActor
final class RepairModel: ToolModel {
    func prepare() {
        guard !busy, let file = files.first else { return }
        invalidateResult()
        run(stage: "Rebuilding PDF…") {
            let output = try await PDFEngine.shared.repair(file) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
