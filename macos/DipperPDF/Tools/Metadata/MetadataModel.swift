import SwiftUI

@MainActor
final class MetadataModel: ToolModel {
    @Published private(set) var originalMetadata = PDFMetadata()
    @Published private(set) var outputMetadata = PDFMetadata()
    @Published var metadata = PDFMetadata() {
        didSet { result = nil }
    }
    @Published var keywords = "" {
        didSet { result = nil }
    }

    override func inputsChanged() async throws {
        metadata = PDFMetadata()
        originalMetadata = PDFMetadata()
        outputMetadata = PDFMetadata()
        keywords = ""
        guard let file = files.first else { return }
        metadata = try await PDFEngine.shared.metadata(file)
        originalMetadata = metadata
        keywords = metadata.keywords.joined(separator: ", ")
    }

    func prepare() {
        guard !busy, let file = files.first else { return }
        var edited = metadata
        // Keep imported keyword boundaries intact when only another field changes.
        if keywords != metadata.keywords.joined(separator: ", ") {
            edited.keywords = keywords.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
        }
        result = nil
        run {
            let output = try await PDFEngine.shared.editMetadata(file, metadata: edited) { value in
                await self.report(value)
            }
            let snapshot = PDFFile(url: file.url, data: output.data, pageCount: file.pageCount)
            let details = try await PDFEngine.shared.metadata(snapshot)
            try Task.checkCancellation()
            self.outputMetadata = details
            self.result = output
        }
    }
}
