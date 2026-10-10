import SwiftUI

@MainActor
final class AnnotationsModel: ToolModel {
    func prepare() {
        guard !busy, let file = files.first else { return }
        result = nil
        run {
            let output = try await PDFEngine.shared.removeAnnotations(file) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
