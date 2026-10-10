import SwiftUI

@MainActor
final class NumberModel: ToolModel {
    @Published private(set) var settings = PageNumberSettings()

    var canNumber: Bool {
        guard let file = files.first else { return false }
        return settings.isValid(pageCount: file.pageCount)
    }

    func update(_ settings: PageNumberSettings) {
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
        guard !busy, canNumber, let file = files.first else { return }
        let settings = settings
        result = nil
        run {
            let output = try await PDFEngine.shared.addPageNumbers(file, settings: settings) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.result = output
        }
    }

}
