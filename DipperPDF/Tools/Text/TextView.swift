import SwiftUI

struct TextView: View {
    @StateObject private var model: TextModel

    init(model: TextModel = TextModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Extract Text", detail: "Save selectable text from your PDF as a plain text file.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Plain text output", systemImage: "doc.text").font(.headline)
                        Text("Text is saved in page order, with a blank line between pages.")
                            .foregroundStyle(DipperTheme.secondary)
                        Text("Text inside scanned images needs OCR and is not extracted. Layout and formatting are not preserved; reading order within a page may vary.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                        Text("Your original PDF stays unchanged.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
                    Button(action: model.prepareAndSave) {
                        Label("Save Text…", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }
}
