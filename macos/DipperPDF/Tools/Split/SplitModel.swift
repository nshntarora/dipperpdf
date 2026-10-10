import SwiftUI

@MainActor
final class SplitModel: ToolModel {
    @Published private(set) var pagesPerFile = 1
    @Published private(set) var outputNames: [String] = []
    private let chooseFolder: @MainActor () -> URL?

    init(chooseFolder: @escaping @MainActor () -> URL? = { FilePanels.folder() }) {
        self.chooseFolder = chooseFolder
        super.init()
    }

    var outputCount: Int {
        guard let file = files.first else { return 0 }
        return (file.pageCount - 1) / pagesPerFile + 1
    }

    func setPagesPerFile(_ value: Int) {
        guard !busy, value > 0, let file = files.first, value <= file.pageCount else { return }
        pagesPerFile = value
        outputNames = []; result = nil
    }

    override func inputsChanged() async throws {
        pagesPerFile = 1
        outputNames = []; result = nil
    }

    func splitAndSave() {
        guard !busy, let file = files.first, let folder = chooseFolder() else { return }
        let count = pagesPerFile
        outputNames = []; result = nil
        run {
            let outputs = try await PDFEngine.shared.split(file, pagesPerFile: count) { value in
                await self.report(value * 0.8)
            }
            let destination = try await PDFEngine.shared.saveSplit(outputs, in: folder,
                name: file.url.deletingPathExtension().lastPathComponent + "-split", sources: [file.url]) { value in
                await self.report(0.8 + value * 0.2)
            }
            self.outputNames = outputs.map(\.suggestedName)
            self.savedURL = destination
            self.status = "Saved \(outputs.count) PDFs in \(destination.lastPathComponent)."
        }
    }
}
