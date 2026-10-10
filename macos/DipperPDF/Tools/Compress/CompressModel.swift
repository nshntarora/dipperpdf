import SwiftUI

@MainActor
final class CompressModel: ToolModel {
    @Published var level: CompressionLevel = .balanced {
        didSet { result = nil; status = nil }
    }
    func compress() {
        guard let file = files.first else { return }
        let level = level
        run {
            self.result = try await PDFEngine.shared.compress(file, level: level) { value in
                await self.report(value)
            }
        }
    }
    var savings: String {
        guard let file = files.first, let result else { return "" }
        let percentage = 100 * (1 - Double(result.data.count) / Double(file.data.count))
        return String(format: "%.1f%% saved", percentage)
    }
}
