import SwiftUI
import AppKit

struct ExtractView: View {
    @StateObject private var model: ExtractModel
    init(model: ExtractModel = ExtractModel()) { _model = StateObject(wrappedValue: model) }

    @State private var editingRange = false
    var body: some View {
        ToolWorkspace(tool: .extract, model: model, canPrepare: model.canExtract, prepare: model.prepare) {
            if let file = model.files.first {
                PageSelectionEditor(file: file, thumbnails: model.thumbnails, selection: model.selection,
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
