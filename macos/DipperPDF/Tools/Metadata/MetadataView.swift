import SwiftUI

struct MetadataView: View {
    @StateObject private var model: MetadataModel

    init(model: MetadataModel = MetadataModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Edit PDF Metadata", detail: "Update your document’s details and save a new copy.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Document details").font(.headline)
                        Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 16) {
                            GridRow {
                                Text("Title")
                                TextField("Title", text: $model.metadata.title)
                            }
                            GridRow {
                                Text("Author")
                                TextField("Author", text: $model.metadata.author)
                            }
                            GridRow {
                                Text("Subject")
                                TextField("Subject", text: $model.metadata.subject)
                            }
                            GridRow {
                                Text("Keywords")
                                TextField("Keywords", text: $model.keywords)
                            }
                        }.textFieldStyle(.roundedBorder).controlSize(.large)
                        Text("Separate keywords with commas. Leave a field empty to remove that detail.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).toolSurface().disabled(model.busy)
                    Button(action: model.prepareAndSave) {
                        Label("Save PDF Copy…", systemImage: "square.and.arrow.down")
                    }.buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                    Text("These fields describe the document; clearing them does not remove personal information from its pages or other embedded data.")
                        .font(.caption).foregroundStyle(DipperTheme.secondary)
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }
}
