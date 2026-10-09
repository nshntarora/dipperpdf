import SwiftUI

@MainActor
final class TextModel: ToolModel {
    override init(saveDestination: @escaping @MainActor (String) -> URL? = {
        FilePanels.save(name: $0, contentType: .plainText)
    }) {
        super.init(saveDestination: saveDestination)
    }

    func prepareAndSave() {
        guard !busy, let file = files.first else { return }
        let name = file.url.deletingPathExtension().lastPathComponent + "-text.txt"
        guard let destination = saveDestination(name) else { return }
        run {
            let output = try await PDFEngine.shared.extractText(file) { value in
                await self.report(value)
            }
            try await PDFEngine.shared.save(output, to: destination, sources: [file.url])
            self.result = output
            self.savedURL = destination
            self.status = "Saved \(destination.lastPathComponent)."
        }
    }
}
