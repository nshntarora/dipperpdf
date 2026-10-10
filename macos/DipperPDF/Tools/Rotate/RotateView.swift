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
    @StateObject private var model: RotateModel
    init(model: RotateModel = RotateModel()) { _model = StateObject(wrappedValue: model) }

    @State private var editingRange = false
    var body: some View {
        ToolWorkspace(tool: .rotate, model: model, canPrepare: model.hasChanges, prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Rotation") {
                    HStack {
                        Button { model.rotate(by: -90) } label: { Label("Rotate left 90°", systemImage: "rotate.left") }
                            .keyboardShortcut("l", modifiers: [.command, .shift])
                        Button { model.rotate(by: 90) } label: { Label("Rotate right 90°", systemImage: "rotate.right") }
                            .keyboardShortcut("r", modifiers: [.command, .shift])
                    }.disabled(model.selection.isEmpty)
                }
                PageSelectionEditor(file: file, thumbnails: model.thumbnails, selection: model.selection,
                                    rotations: model.rotations,
                                    select: model.select, setSelection: model.setSelection,
                                    editingChanged: { editingRange = $0 })
            }
        }
        .focusedSceneValue(\.selectAllPages, selectAllAction)
    }

    private var selectAllAction: (() -> Void)? {
        guard !model.busy, !editingRange, !model.files.isEmpty else { return nil }
        return { model.selectAll() }
    }
}
