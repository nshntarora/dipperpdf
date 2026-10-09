import SwiftUI

struct SplitView: View {
    @StateObject private var model: SplitModel

    init(model: SplitModel = SplitModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Split PDF", detail: "Divide your PDF into files with the same number of pages. The last file keeps any remaining pages.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    VStack(alignment: .leading, spacing: 16) {
                        Stepper("Pages per file: \(model.pagesPerFile)",
                            value: Binding(get: { model.pagesPerFile }, set: { model.setPagesPerFile($0) }),
                            in: 1...file.pageCount)
                        Text("\(model.outputCount) PDF \(model.outputCount == 1 ? "file" : "files") · Original page order preserved")
                            .foregroundStyle(DipperTheme.secondary)
                        Text("Choose a destination folder. Your PDFs will be saved together in a new subfolder without replacing existing files.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).toolSurface().disabled(model.busy)
                    Button(action: model.splitAndSave) {
                        Label("Split and Save PDFs…", systemImage: "square.and.arrow.down")
                    }.buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                    if !model.outputNames.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Your split PDFs are saved", systemImage: "checkmark.circle.fill").font(.headline)
                            ForEach(model.outputNames, id: \.self) { name in
                                Label(name, systemImage: "doc")
                            }
                        }.padding(24).toolSurface()
                    }
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }
}
