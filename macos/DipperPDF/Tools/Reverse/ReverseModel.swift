import SwiftUI

@MainActor
final class ReverseModel: ToolModel {
    func prepare() {
        guard !busy, let file = files.first else { return }
        result = nil
        run {
            let output = try await PDFEngine.shared.reversePages(file) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
