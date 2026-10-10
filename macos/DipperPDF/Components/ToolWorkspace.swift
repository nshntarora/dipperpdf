import SwiftUI

struct ToolWorkspace<Content: View>: View {
    let tool: PDFTool
    @ObservedObject var model: ToolModel
    var canPrepare = true
    var resultDetail: String? = nil
    let prepare: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: DipperTheme.sectionSpacing) {
                    HStack(alignment: .center, spacing: 24) {
                        ToolHeader(title: tool.title, detail: tool.subtitle)
                        ToolIllustration(tool: tool)
                    }
                    PDFInputSection(model: model, multiple: tool == .merge, locked: tool == .unlock)
                    if !model.files.isEmpty {
                        content().id(model.files.first?.id).disabled(model.busy)
                        if !model.preparedOutputs.isEmpty {
                            ToolResultSection(tool: tool, model: model, detail: resultDetail).id("prepared-result")
                        }
                    }
                    ToolStatus(model: model).id("tool-status")
                    PrivacyNote()
                }
                .padding(DipperTheme.workspacePadding)
                .frame(maxWidth: 1000, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: model.preparedOutputs.isEmpty) { _, empty in
                if !empty { reader.scrollTo("prepared-result", anchor: .top) }
            }
            .onAppear {
                if !model.preparedOutputs.isEmpty { reader.scrollTo("prepared-result", anchor: .top) }
            }
            .onChange(of: model.savedURL) { _, url in
                if url != nil { reader.scrollTo("tool-status", anchor: .bottom) }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: 16) {
                if model.busy {
                    ProgressView(value: model.progress).frame(width: 120)
                    Text(model.stage).font(DipperTheme.bodyFont).foregroundStyle(DipperTheme.secondary)
                    Spacer()
                    Button("Cancel", action: model.cancel).keyboardShortcut(.cancelAction)
                } else {
                    Button(action: prepare) {
                        Label(model.preparedOutputs.isEmpty ? tool.title : "Prepare Again", systemImage: tool.symbol)
                    }
                    .buttonStyle(ToolActionStyle(prominent: model.preparedOutputs.isEmpty))
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(model.files.isEmpty || !canPrepare)
                    Spacer()
                    if !model.preparedOutputs.isEmpty {
                        Button(action: model.save) { Label(saveTitle, systemImage: "square.and.arrow.down") }
                            .buttonStyle(ToolActionStyle()).keyboardShortcut("s")
                    }
                }
            }
            .padding(.horizontal, DipperTheme.workspacePadding).padding(.vertical, 16)
            .background(DipperTheme.surface)
            .overlay(alignment: .top) { Rectangle().fill(DipperTheme.border).frame(height: 1) }
        }
        .onDisappear { model.cancel() }
    }

    private var saveTitle: String {
        tool == .split ? "Save PDFs…" : tool == .text ? "Save Text…" : "Save PDF…"
    }
}

struct PDFInputSection: View {
    @ObservedObject var model: ToolModel
    var multiple = false
    var locked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("PDF input", systemImage: "doc").font(DipperTheme.headingFont)
            if !multiple, let file = model.files.first { FileSummary(file: file, locked: locked) }
            FileDropZone(multiple: multiple, compact: !model.files.isEmpty, disabled: model.busy) {
                model.add($0, multiple: multiple)
            }
        }
    }
}

struct ToolSettingsSection<Content: View>: View {
    let title: String
    var detail: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(DipperTheme.headingFont)
            content()
            if let detail { Text(detail).font(DipperTheme.bodyFont).foregroundStyle(DipperTheme.secondary) }
        }.controlSize(DipperTheme.controlSize).textFieldStyle(.roundedBorder)
            .padding(DipperTheme.surfacePadding).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
    }
}

struct ToolFieldRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(label).frame(width: 140, alignment: .leading)
            content().frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PageRangeFields: View {
    let count: Int
    @Binding var first: Int
    @Binding var last: Int
    var body: some View {
        ToolFieldRow(label: "Page range") {
            HStack {
                Stepper("From \(first)", value: $first, in: 1...count)
                Stepper("To \(last)", value: $last, in: 1...count)
            }
        }
        if first > last {
            Label("The last page must follow the first page.", systemImage: "exclamationmark.triangle")
                .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.warning)
        }
    }
}

struct ToolResultSection: View {
    let tool: PDFTool
    @ObservedObject var model: ToolModel
    var detail: String?
    @State private var selectedOutput = 0

    var body: some View {
        ToolSettingsSection(title: "Result ready", detail: "Save a new copy. Your original files stay unchanged.") {
            if let detail { Text(detail).font(DipperTheme.bodyFont).foregroundStyle(DipperTheme.secondary) }
            if model.preparedOutputs.count > 1 {
                Picker("Output file", selection: $selectedOutput) {
                    ForEach(Array(model.preparedOutputs.enumerated()), id: \.offset) { index, output in
                        Text(output.suggestedName).tag(index)
                    }
                }
            }
            if tool == .split {
                Text("\(model.preparedOutputs.count) PDF \(model.preparedOutputs.count == 1 ? "file" : "files") · Saved together in a new subfolder")
                    .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
            }
            if let output = model.preparedOutputs[safe: selectedOutput] {
                HStack {
                    Label(output.suggestedName, systemImage: tool == .text ? "doc.text" : "doc.richtext")
                        .font(.callout.weight(.medium)).textSelection(.enabled)
                        .lineLimit(2).help(output.suggestedName)
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: Int64(output.data.count), countStyle: .file))
                        .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
                }
                if tool == .text {
                    ScrollView {
                        Text(String(decoding: output.data, as: UTF8.self))
                            .font(.system(.body, design: .monospaced)).textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(16)
                    }.frame(height: 340).background(DipperTheme.background, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    PDFPreviewView(data: output.data).id(selectedOutput)
                }
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

struct ToolChoiceCard<Content: View>: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title).font(DipperTheme.headingFont)
                    Spacer(minLength: 4)
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selected ? DipperTheme.accent : DipperTheme.secondary)
                }
                content()
            }
            .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading).padding(16)
            .background(selected ? DipperTheme.selection : DipperTheme.surface, in: RoundedRectangle(cornerRadius: DipperTheme.controlRadius))
            .overlay(RoundedRectangle(cornerRadius: DipperTheme.controlRadius)
                .strokeBorder(selected ? DipperTheme.accent : DipperTheme.border, lineWidth: selected ? 2 : 1))
            .contentShape(RoundedRectangle(cornerRadius: DipperTheme.controlRadius))
        }.buttonStyle(.plain)
            .accessibilityLabel(title).accessibilityValue(selected ? "Selected" : "Not selected")
            .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Keep invalid text visible rather than silently using the last valid numeric value.
struct ToolNumericField<Value: LosslessStringConvertible & Equatable>: View {
    let label: String
    @Binding var value: Value
    let validityChanged: (Bool) -> Void
    @State private var text = ""
    @State private var valid = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(label, text: $text).accessibilityLabel(label)
            if !valid {
                Label("Enter a valid number.", systemImage: "exclamationmark.triangle")
                    .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.warning)
            }
        }
        .onAppear { text = String(value) }
        .onChange(of: text) { _, newValue in
            if let number = Value(newValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                valid = true
                if value != number { value = number }
            } else { valid = false }
            validityChanged(valid)
        }
        .onChange(of: value) { _, newValue in
            if Value(text) != newValue { text = String(newValue) }
        }
    }
}

#if DEBUG
/// In-memory fixtures for Xcode previews; no files or destination dialogs are needed.
@MainActor
private enum ToolPreviewFixtures {
    static func file() -> PDFFile {
        let bytes = NSMutableData()
        var bounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let consumer = CGDataConsumer(data: bytes as CFMutableData)!
        let context = CGContext(consumer: consumer, mediaBox: &bounds, nil)!
        for _ in 0..<3 {
            context.beginPDFPage(nil)
            context.setFillColor(NSColor.systemBrown.cgColor)
            context.fill(CGRect(x: 48, y: 640, width: 280, height: 24))
            for line in 0..<8 { context.fill(CGRect(x: 48, y: 600 - line * 28, width: 440, height: 6)) }
            context.endPDFPage()
        }
        context.closePDF()
        return PDFFile(url: URL(fileURLWithPath: "/tmp/Example document.pdf"), data: bytes as Data, pageCount: 3)
    }
}

#Preview("Numbering · generated fixture") {
    let model = NumberModel()
    model.files = [ToolPreviewFixtures.file()]
    return NumberView(model: model).frame(width: 740, height: 650)
        .background(DipperTheme.background).tint(DipperTheme.accent).foregroundStyle(DipperTheme.ink)
}

#Preview("Split · generated fixture") {
    let model = SplitModel()
    model.files = [ToolPreviewFixtures.file()]
    return SplitView(model: model).frame(width: 740, height: 650)
        .background(DipperTheme.background).tint(DipperTheme.accent).foregroundStyle(DipperTheme.ink)
}
#endif
