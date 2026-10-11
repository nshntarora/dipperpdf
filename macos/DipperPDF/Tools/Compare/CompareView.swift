import SwiftUI

struct CompareView: View {
    @StateObject private var model: CompareModel
    init(model: CompareModel = CompareModel()) { _model = StateObject(wrappedValue: model) }

    var body: some View {
        ToolWorkspace(tool: .compare, model: model, canPrepare: model.canPrepare,
                      resultDetail: model.comparison?.summary, prepare: model.prepare) {
            ToolSettingsSection(title: "Original and revised PDFs",
                                detail: "Pages are paired by number. The report marks removed lines with − and added lines with +. Text order and line breaks follow the PDF’s selectable text; images, formatting, and metadata are not compared.") {
                ForEach(Array(model.files.enumerated()), id: \.element.id) { index, file in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(index == 0 ? "Original" : "Revised").font(.headline)
                            Spacer()
                            Button { model.remove(file.id) } label: { Image(systemName: "minus.circle") }
                                .accessibilityLabel("Remove \(index == 0 ? "original" : "revised") PDF, \(file.name)")
                        }
                        FileSummary(file: file)
                    }
                }
                if model.files.count == 2 {
                    Button("Swap original and revised", action: model.swap)
                } else {
                    Label("Add two PDFs: original first, revised second.", systemImage: "info.circle")
                        .foregroundStyle(DipperTheme.secondary)
                }
                Text("Pages without selectable text are flagged for review. Scanned pages need OCR before their text can be compared.")
                    .foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
