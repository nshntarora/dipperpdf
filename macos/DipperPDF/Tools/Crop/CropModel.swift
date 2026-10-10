import SwiftUI

@MainActor
final class CropModel: ToolModel {
    @Published private(set) var settings = CropSettings()

    var canCrop: Bool {
        guard let file = files.first else { return false }
        return settings.isValid(pageCount: file.pageCount)
    }

    func update(_ settings: CropSettings) {
        guard !busy else { return }
        self.settings = settings
        result = nil
        error = nil
    }

    override func inputsChanged() async throws {
        settings = CropSettings(lastPage: files.first?.pageCount ?? 1)
        result = nil
    }

    func prepare() {
        guard !busy, canCrop, let file = files.first else { return }
        let settings = settings
        result = nil
        run {
            let output = try await PDFEngine.shared.crop(file, settings: settings) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }

}
