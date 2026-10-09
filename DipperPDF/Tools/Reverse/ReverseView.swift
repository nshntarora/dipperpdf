import SwiftUI

struct ReverseView: View {
    @StateObject private var model: ReverseModel

    init(model: ReverseModel = ReverseModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Reverse Pages", detail: "Save a new PDF with every page in reverse order, from last to first.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    VStack(alignment: .leading, spacing: 14) {
                        Label("New page order", systemImage: "arrow.up.arrow.down").font(.headline)
                        Text(file.pageCount == 1 ? "This PDF has one page. Its page order will stay the same." :
                             "Page \(file.pageCount) becomes the first page. Page 1 becomes the last.")
                            .foregroundStyle(DipperTheme.secondary)
                        Text("Page content and rotation stay the same. Your original stays unchanged.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
                    Button(action: model.prepareAndSave) {
                        Label("Save Reversed PDF…", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }
}
