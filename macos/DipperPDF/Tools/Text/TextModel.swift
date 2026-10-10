import SwiftUI

@MainActor
final class TextModel: ToolModel {
    override init(saveDestination: @escaping @MainActor (String) -> URL? = {
        FilePanels.save(name: $0, contentType: .plainText)
    }) {
        super.init(saveDestination: saveDestination)
    }

    func prepare() {
        guard !busy, let file = files.first else { return }
        result = nil
        run {
            let output = try await PDFEngine.shared.extractText(file) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }
}
