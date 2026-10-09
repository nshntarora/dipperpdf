import SwiftUI
import AppKit

struct SelectAllPagesKey: FocusedValueKey { typealias Value = () -> Void }
extension FocusedValues {
    var selectAllPages: (() -> Void)? {
        get { self[SelectAllPagesKey.self] }
        set { self[SelectAllPagesKey.self] = newValue }
    }
}

struct RotateView: View {
    @StateObject private var model = RotateModel()
    private var selectAllAction: (() -> Void)? {
        guard !model.busy, !model.files.isEmpty else { return nil }
        return { model.selectAll() }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ToolHeader(title: "Rotate PDF", detail: "Select pages, then rotate them. Command-click adds pages; Shift-click selects a range.")
            FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
            if let file = model.files.first {
                FileSummary(file: file)
                rotationControls
                pageGrid(file)
                Button(action: model.prepareAndSave) { Label("Save Rotated PDF…", systemImage: "square.and.arrow.down") }
                    .buttonStyle(ToolActionStyle())
                    .keyboardShortcut("s").disabled(model.busy || !model.hasChanges)
            } else { Spacer() }
            ToolStatus(model: model)
            PrivacyNote()
        }.padding(32).frame(maxWidth: 1100).frame(maxWidth: .infinity)
            .focusedSceneValue(\.selectAllPages, selectAllAction)
            .onDisappear { model.cancel() }
    }
    private var rotationControls: some View {
        HStack {
            Button { model.rotate(by: -90) } label: { Label("Rotate left 90°", systemImage: "rotate.left") }
                .keyboardShortcut("l", modifiers: [.command, .shift]).disabled(model.selection.isEmpty)
            Button { model.rotate(by: 90) } label: { Label("Rotate right 90°", systemImage: "rotate.right") }
                .keyboardShortcut("r", modifiers: [.command, .shift]).disabled(model.selection.isEmpty)
            Spacer()
            Text("\(model.selection.count) selected").foregroundStyle(DipperTheme.secondary)
            Button("Select All", action: model.selectAll)
        }.controlSize(.large).disabled(model.busy)
    }
    private func pageGrid(_ file: PDFFile) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(0..<file.pageCount, id: \.self) { index in
                    pageButton(index)
                }
            }.padding(4)
        }.disabled(model.busy)
    }
    private func pageButton(_ index: Int) -> some View {
        Button { model.select(index, modifiers: NSEvent.modifierFlags) } label: {
            PageThumbnail(image: model.thumbnails[index], index: index,
                          rotation: model.rotations[index, default: 0],
                          selected: model.selection.contains(index))
        }.buttonStyle(.plain)
            .accessibilityLabel("Page \(index + 1)")
            .accessibilityValue(model.selection.contains(index) ? "Selected" : "Not selected")
    }
}
