import SwiftUI

@MainActor
final class SplitModel: ToolModel {
    @Published private(set) var pagesPerFile = 1
    @Published private(set) var outputs: [PDFResult] = []
    override var preparedOutputs: [PDFResult] { outputs }
    var outputNames: [String] { outputs.map(\.suggestedName) }
    private let chooseFolder: @MainActor () -> URL?

    init(chooseFolder: @escaping @MainActor () -> URL? = { FilePanels.folder() }) {
        self.chooseFolder = chooseFolder
        super.init()
    }

    var outputCount: Int {
        guard let file = files.first else { return 0 }
        return (file.pageCount - 1) / pagesPerFile + 1
    }

    override func invalidateResult() {
        outputs = []
        super.invalidateResult()
    }

    func setPagesPerFile(_ value: Int) {
        guard !busy, value > 0, let file = files.first, value <= file.pageCount else { return }
        pagesPerFile = value
        invalidateResult()
    }

    override func inputsChanged() async throws {
        pagesPerFile = 1
        invalidateResult()
    }

    func prepare() {
        guard !busy, let file = files.first else { return }
        let count = pagesPerFile
        invalidateResult()
        run {
            let outputs = try await PDFEngine.shared.split(file, pagesPerFile: count) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.outputs = outputs
        }
    }

    override func save() {
        guard !busy, !outputs.isEmpty, let file = files.first, let folder = chooseFolder() else { return }
        let outputs = outputs
        run(stage: "Saving PDFs…") {
            let destination = try await PDFEngine.shared.saveSplit(outputs, in: folder,
                name: file.url.deletingPathExtension().lastPathComponent + "-split", sources: [file.url]) { value in
                await self.report(value)
            }
            self.savedURL = destination
            self.status = "Saved \(outputs.count) PDFs in \(destination.lastPathComponent)."
        }
    }
}
