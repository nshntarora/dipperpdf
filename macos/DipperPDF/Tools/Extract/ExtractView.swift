import SwiftUI
import AppKit

struct ExtractView: View {
    @StateObject private var model: ExtractModel

    init(model: ExtractModel = ExtractModel()) {
        _model = StateObject(wrappedValue: model)
    }

    private var selectAllAction: (() -> Void)? {
        guard !model.busy, !model.files.isEmpty else { return nil }
        return { model.selectAll() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ToolHeader(title: "Extract Pages", detail: "Select pages to export into one PDF, in their original order. Command-click adds pages; Shift-click selects a range.")
            FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
            if let file = model.files.first {
                FileSummary(file: file)
                HStack {
                    Text("\(model.selection.count) of \(file.pageCount) pages to extract")
                        .foregroundStyle(DipperTheme.secondary)
                    Spacer()
                    Button("Select All", action: model.selectAll)
                    Button("Clear Selection", action: model.clearSelection).disabled(model.selection.isEmpty)
                }.controlSize(.large).disabled(model.busy)
                pageGrid(file)
                Button(action: model.prepareAndSave) {
                    Label("Save Selected Pages…", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(ToolActionStyle()).keyboardShortcut("s")
                .disabled(model.busy || !model.canExtract)
            } else { Spacer() }
            ToolStatus(model: model)
            PrivacyNote()
        }.padding(32).frame(maxWidth: 1100).frame(maxWidth: .infinity)
            .focusedSceneValue(\.selectAllPages, selectAllAction)
            .onDisappear { model.cancel() }
    }

    private func pageGrid(_ file: PDFFile) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(0..<file.pageCount, id: \.self) { index in
                    Button { model.select(index, modifiers: NSEvent.modifierFlags) } label: {
                        PageThumbnail(image: model.thumbnails[index], index: index,
                                      rotation: 0, selected: model.selection.contains(index))
                            .overlay(alignment: .topTrailing) {
                                if model.selection.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2).foregroundStyle(DipperTheme.accent)
                                        .padding(12)
                                }
                            }
                    }.buttonStyle(.plain)
                        .accessibilityLabel("Page \(index + 1)")
                        .accessibilityValue(model.selection.contains(index) ? "Selected for extraction" : "Not selected")
                }
            }.padding(4)
        }.disabled(model.busy)
    }
}
