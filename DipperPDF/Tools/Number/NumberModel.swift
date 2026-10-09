import SwiftUI

@MainActor
final class NumberModel: ToolModel {
    @Published private(set) var settings = PageNumberSettings()
    @Published private(set) var previews: [Int: Data] = [:]

    var canNumber: Bool {
        guard let file = files.first else { return false }
        return settings.isValid(pageCount: file.pageCount)
    }

    func update(_ settings: PageNumberSettings) {
        guard !busy else { return }
        self.settings = settings
        result = nil
        previews = [:]
        error = nil
    }

    override func inputsChanged() async throws {
        settings.firstPage = 1
        settings.lastPage = files.first?.pageCount ?? 1
        result = nil
        previews = [:]
    }

    func prepare() {
        guard !busy, canNumber, let file = files.first else { return }
        let settings = settings
        result = nil
        previews = [:]
        run {
            let output = try await PDFEngine.shared.addPageNumbers(file, settings: settings) { value in
                await self.report(value * 0.8)
            }
            let previewFile = PDFFile(url: file.url, data: output.data, pageCount: file.pageCount)
            try await PDFEngine.shared.thumbnails(previewFile) { index, data in
                await self.receivePreview(index, data: data, count: file.pageCount)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }

    private func receivePreview(_ index: Int, data: Data, count: Int) {
        previews[index] = data
        report(0.8 + 0.2 * Double(index + 1) / Double(count))
    }
}
