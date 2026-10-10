import SwiftUI

struct CompressView: View {
    @StateObject private var model: CompressModel
    init(model: CompressModel = CompressModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .compress, model: model, resultDetail: summary, prepare: model.compress) {
            compressionSettings
        }
    }

    private var summary: String? {
        guard let file = model.files.first, let result = model.result else { return nil }
        let size = ByteCountFormatter.string(fromByteCount: Int64(result.data.count), countStyle: .file)
        return "Original: \(file.size) · Compressed: \(size) · \(model.savings)" +
            (result.data.count == file.data.count ? "\nThis PDF is already compact at this level. The result keeps its original quality and size." : "")
    }

    private var compressionSettings: some View {
        ToolSettingsSection(title: "Compression level", detail: "Balanced is a good place to start. Image compression is lossy; already optimized PDFs may show no savings.") {
            HStack(alignment: .top, spacing: 12) {
                ForEach(CompressionLevel.allCases, id: \.self) { level in
                    compressionOption(level)
                }
            }
        }
    }

    private func compressionOption(_ level: CompressionLevel) -> some View {
        ToolChoiceCard(title: level.rawValue, selected: model.level == level, action: { model.level = level }) {
            Text(optionTitle(level)).font(.callout.weight(.medium))
            Text(optionDetail(level)).font(.caption).foregroundStyle(DipperTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(level.dpi) dpi · \(Int((level.quality * 100).rounded()))% image quality")
                .font(.caption2).foregroundStyle(DipperTheme.secondary)
        }.accessibilityHint("\(optionTitle(level)). \(optionDetail(level))")
    }
    private func optionTitle(_ level: CompressionLevel) -> String {
        switch level {
        case .light: "Keep more detail"
        case .balanced: "Quality meets size"
        case .strong: "Prioritize smaller files"
        }
    }
    private func optionDetail(_ level: CompressionLevel) -> String {
        switch level {
        case .light: "Gentle compression for detailed images."
        case .balanced: "A practical balance for everyday sharing."
        case .strong: "Best for screens. Fine image detail may be lost."
        }
    }
}
