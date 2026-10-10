import SwiftUI

@MainActor
final class AnnotationsModel: ToolModel {
    func prepareAndSave() {
        guard !busy, let file = files.first else { return }
        let name = file.url.deletingPathExtension().lastPathComponent + "-without-annotations.pdf"
        guard let destination = saveDestination(name) else { return }
        run {
            let output = try await PDFEngine.shared.removeAnnotations(file) { value in
                await self.report(value)
            }
            try await PDFEngine.shared.save(output, to: destination, sources: [file.url])
            self.result = output
            self.savedURL = destination
            self.status = "Saved \(destination.lastPathComponent)."
        }
    }
}
