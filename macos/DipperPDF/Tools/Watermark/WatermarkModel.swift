import SwiftUI

@MainActor
final class WatermarkModel: ToolModel {
    @Published private(set) var settings = WatermarkSettings()

    var canWatermark: Bool {
        guard let file = files.first else { return false }
        return settings.isValid(pageCount: file.pageCount)
    }

    func update(_ settings: WatermarkSettings) {
        guard !busy else { return }
        self.settings = settings
        result = nil
        error = nil
    }

    override func inputsChanged() async throws {
        settings.firstPage = 1
        settings.lastPage = files.first?.pageCount ?? 1
        result = nil
    }

    func prepare() {
        guard !busy, canWatermark, let file = files.first else { return }
        let settings = settings
        result = nil
        run {
            let output = try await PDFEngine.shared.addWatermark(file, settings: settings) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }

}
