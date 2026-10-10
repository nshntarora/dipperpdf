import SwiftUI

struct CompressView: View {
    @StateObject private var model = CompressModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Compress PDF", detail: "A smaller file, ready to share. Choose how much image detail to keep.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    compressionSettings
                    HStack {
                        Button(action: model.compress) {
                            Label(model.busy ? "Processing…" : "Compress PDF", systemImage: "arrow.down.right.and.arrow.up.left")
                        }
                        .buttonStyle(ToolActionStyle(prominent: model.result == nil))
                        .keyboardShortcut(.return, modifiers: .command).disabled(model.busy)
                        Spacer()
                    }
                    if let result = model.result {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Your PDF is ready", systemImage: "checkmark.circle.fill")
                                .font(.headline).foregroundStyle(.tint)
                            HStack(spacing: 24) {
                                metric("Original size", file.size)
                                Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                                metric("Compressed size", ByteCountFormatter.string(fromByteCount: Int64(result.data.count), countStyle: .file))
                                Spacer(minLength: 0)
                                metric("Space saved", model.savings)
                            }
                            if result.data.count == file.data.count {
                                Text("This PDF is already compact at this level. Your result keeps the original quality and size.")
                                    .font(.callout).foregroundStyle(DipperTheme.secondary)
                            }
                            Divider()
                            HStack(spacing: 16) {
                                Button(action: model.save) { Label("Save PDF…", systemImage: "square.and.arrow.down") }
                                    .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                                Text("Save a new copy. Your original stays unchanged.")
                                    .font(.callout).foregroundStyle(DipperTheme.secondary)
                            }
                        }.padding(24).toolSurface()
                    }
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }

    private var compressionSettings: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Compression level").font(.headline)
                Spacer()
                Text("Balanced is a good place to start").font(.caption).foregroundStyle(DipperTheme.secondary)
            }
            HStack(alignment: .top, spacing: 12) {
                ForEach(CompressionLevel.allCases, id: \.self) { level in
                    compressionOption(level)
                }
            }
            Label("Image compression is lossy. Already optimized PDFs may show no savings.", systemImage: "info.circle")
                .font(.caption).foregroundStyle(DipperTheme.secondary)
        }.padding(22).toolSurface().disabled(model.busy)
    }

    private func compressionOption(_ level: CompressionLevel) -> some View {
        let selected = model.level == level
        return Button { model.level = level } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(level.rawValue).font(.headline)
                    Spacer(minLength: 4)
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected ? DipperTheme.accent : DipperTheme.secondary)
                }
                Text(optionTitle(level)).font(.callout.weight(.medium))
                Text(optionDetail(level)).font(.caption).foregroundStyle(DipperTheme.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(level.dpi) dpi · \(Int((level.quality * 100).rounded()))% image quality")
                    .font(.caption2).foregroundStyle(DipperTheme.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading).padding(16)
            .background(selected ? DipperTheme.selection : DipperTheme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(selected ? DipperTheme.accent : DipperTheme.border, lineWidth: selected ? 2 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }.buttonStyle(.plain)
            .accessibilityLabel("\(level.rawValue) compression")
            .accessibilityValue(selected ? "Selected" : "Not selected")
            .accessibilityHint("\(optionTitle(level)). \(optionDetail(level))")
            .accessibilityAddTraits(selected ? .isSelected : [])
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
    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(DipperTheme.secondary)
            Text(value).font(.title2.weight(.semibold)).monospacedDigit()
        }
    }
}
