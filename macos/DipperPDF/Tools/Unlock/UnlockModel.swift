import SwiftUI

@MainActor
final class UnlockModel: ToolModel {
    @Published private(set) var password = ""

    override func loadFile(_ url: URL) async throws -> PDFFile {
        try await PDFEngine.shared.loadForUnlock(url)
    }

    override func inputsChanged() async throws {
        password = ""
        result = nil
    }

    func updatePassword(_ value: String) {
        guard !busy else { return }
        password = value
        result = nil
        error = nil
    }

    override func cancel() {
        super.cancel()
        password = ""
    }

    func prepare() {
        guard !busy, let file = files.first else { return }
        let password = self.password
        result = nil
        run {
            let output = try await PDFEngine.shared.unlock(file, password: password) { value in
                await self.report(value)
            }
            try Task.checkCancellation()
            self.password = ""
            self.result = output
        }
    }
}
