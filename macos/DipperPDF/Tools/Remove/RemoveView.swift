import SwiftUI
import AppKit

struct RemoveView: View {
    @StateObject private var model: RemoveModel
    init(model: RemoveModel = RemoveModel()) { _model = StateObject(wrappedValue: model) }

    @State private var editingRange = false
    var body: some View {
        ToolWorkspace(tool: .remove, model: model, canPrepare: model.canRemove, prepare: model.prepare) {
            if let file = model.files.first {
                if model.remainingCount == 0 {
                    Label("Keep at least one page. Deselect a page or clear the selection.", systemImage: "exclamationmark.triangle")
                        .font(.callout).foregroundStyle(DipperTheme.secondary)
                }
                PageSelectionEditor(file: file, thumbnails: model.thumbnails, selection: model.selection,
                                    removing: true,
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
