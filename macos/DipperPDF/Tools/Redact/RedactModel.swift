import SwiftUI

@MainActor
final class RedactModel: ToolModel {
    @Published private(set) var settings = RedactionSettings()
    @Published private(set) var matchCount = 0

    var canPrepare: Bool {
        guard let file = files.first else { return false }
        return settings.isValid(pageCount: file.pageCount)
    }

    func update(_ settings: RedactionSettings) {
        guard !busy else { return }
        self.settings = settings
        matchCount = 0
        invalidateResult()
        error = nil
    }

    override func inputsChanged() async throws {
        settings = RedactionSettings(lastPage: files.first?.pageCount ?? 1)
        matchCount = 0
        invalidateResult()
    }

    func prepare() {
        guard !busy, canPrepare, let file = files.first else { return }
        let settings = settings
        matchCount = 0
        invalidateResult()
        run(stage: "Finding and redacting text…") {
            let output = try await PDFEngine.shared.redact(file, settings: settings) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.matchCount = output.matchCount
            self.result = output.pdf
        }
    }
}
