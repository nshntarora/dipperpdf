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

    func prepareAndSave() {
        guard !busy, let file = files.first else { return }
        if result != nil {
            save()
            return
        }
        let name = file.url.deletingPathExtension().lastPathComponent + "-unlocked.pdf"
        guard let destination = saveDestination(name) else { return }
        let password = self.password
        result = nil
        run {
            let output = try await PDFEngine.shared.unlock(file, password: password) { value in
                await self.report(value)
            }
            try await PDFEngine.shared.save(output, to: destination, sources: [file.url])
            self.password = ""
            self.result = output
            self.savedURL = destination
            self.status = "Saved \(destination.lastPathComponent)."
        }
    }
}
