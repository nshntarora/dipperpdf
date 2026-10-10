import SwiftUI

struct SplitView: View {
    @StateObject private var model: SplitModel
    init(model: SplitModel = SplitModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .split, model: model, prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Split into groups", detail: "The last file keeps any remaining pages. Save all results together in a new subfolder without replacing existing files.") {
                    ToolFieldRow(label: "Pages per file") {
                        Stepper("\(model.pagesPerFile)", value: Binding(get: { model.pagesPerFile }, set: model.setPagesPerFile), in: 1...file.pageCount)
                    }
                    Label("\(model.outputCount) PDF \(model.outputCount == 1 ? "file" : "files") · Original page order preserved", systemImage: "rectangle.split.2x1")
                        .foregroundStyle(DipperTheme.secondary)
                    // A bounded sample illustrates the grouping even for very long documents.
                    HStack(spacing: 12) {
                        ForEach(0..<min(model.outputCount, 4), id: \.self) { index in
                            let first = index * model.pagesPerFile + 1
                            let last = min(first + model.pagesPerFile - 1, file.pageCount)
                            Label("\(first)–\(last)", systemImage: "doc").padding(12).toolSurface()
                        }
                        if model.outputCount > 4 { Text("+\(model.outputCount - 4) more").font(.caption) }
                    }
                }
            }
        }
    }
}
