import SwiftUI

@MainActor
final class MetadataModel: ToolModel {
    @Published var metadata = PDFMetadata() {
        didSet { result = nil }
    }
    @Published var keywords = "" {
        didSet { result = nil }
    }

    override func inputsChanged() async throws {
        metadata = PDFMetadata()
        keywords = ""
        guard let file = files.first else { return }
        metadata = try await PDFEngine.shared.metadata(file)
        keywords = metadata.keywords.joined(separator: ", ")
    }

    func prepareAndSave() {
        guard !busy, let file = files.first else { return }
        var edited = metadata
        // Keep imported keyword boundaries intact when only another field changes.
        if keywords != metadata.keywords.joined(separator: ", ") {
            edited.keywords = keywords.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
        }
        let name = file.url.deletingPathExtension().lastPathComponent + "-metadata.pdf"
        guard let destination = saveDestination(name) else { return }
        run {
            let output = try await PDFEngine.shared.editMetadata(file, metadata: edited) { value in
                await self.report(value)
            }
            try await PDFEngine.shared.save(output, to: destination, sources: [file.url])
            self.result = output
            self.savedURL = destination
            self.status = "Saved \(destination.lastPathComponent)."
        }
    }
}
