import SwiftUI

struct AnnotationsView: View {
    @StateObject private var model: AnnotationsModel

    init(model: AnnotationsModel = AnnotationsModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Remove Annotations", detail: "Remove review markup from every page and save a separate PDF.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Remove review markup", systemImage: "eraser").font(.headline)
                        Text("Comments, highlights, text boxes, drawings, and stamps will be removed from every page.")
                            .foregroundStyle(DipperTheme.secondary)
                        Text("Links and form fields are kept. Marks already flattened into page content cannot be removed.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                        Text("Your original stays unchanged.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
                    Button(action: model.prepareAndSave) {
                        Label("Save Without Annotations…", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }
}
