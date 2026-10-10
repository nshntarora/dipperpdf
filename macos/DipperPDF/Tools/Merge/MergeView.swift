import SwiftUI
import UniformTypeIdentifiers

struct MergeView: View {
    @StateObject private var model: MergeModel
    init(model: MergeModel = MergeModel()) { _model = StateObject(wrappedValue: model) }
    @State private var dragged: UUID?

    var body: some View {
        ToolWorkspace(tool: .merge, model: model, canPrepare: model.files.count >= 2,
                      resultDetail: "\(model.files.count) files · \(model.files.reduce(0) { $0 + $1.pageCount }) pages", prepare: model.merge) {
            ToolSettingsSection(title: "Document order", detail: "Drag rows or use the arrow buttons to reorder. Pages keep their order within each PDF.") {
                ForEach(Array(model.files.enumerated()), id: \.element.id) { index, file in
                    HStack(spacing: 12) {
                        Text("\(index + 1)").monospacedDigit().foregroundStyle(DipperTheme.secondary).frame(width: 24)
                        Image(systemName: "line.3.horizontal").foregroundStyle(DipperTheme.secondary)
                        PDFCover(file: file)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name).font(.headline).lineLimit(1).help(file.name)
                            Text("\(file.pageCount) pages · \(file.size)").font(.caption).foregroundStyle(DipperTheme.secondary)
                        }
                        Spacer()
                        Button { model.nudge(file.id, by: -1) } label: { Image(systemName: "arrow.up") }
                            .disabled(index == 0).accessibilityLabel("Move \(file.name) up")
                        Button { model.nudge(file.id, by: 1) } label: { Image(systemName: "arrow.down") }
                            .disabled(index == model.files.count - 1).accessibilityLabel("Move \(file.name) down")
                        Button { model.remove(file.id) } label: { Image(systemName: "minus.circle") }
                            .accessibilityLabel("Remove \(file.name)")
                    }.padding(12).toolSurface().contentShape(Rectangle())
                        .onDrag { dragged = file.id; return NSItemProvider(object: file.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: MergeReorderDelegate(target: file.id, dragged: $dragged, model: model))
                }
                if model.files.count < 2 {
                    Label("Add at least two PDFs to merge.", systemImage: "info.circle")
                        .font(.callout).foregroundStyle(DipperTheme.secondary)
                }
            }
        }
    }
}

private struct MergeReorderDelegate: DropDelegate {
    let target: UUID
    @Binding var dragged: UUID?
    let model: MergeModel
    func dropEntered(info: DropInfo) {
        guard let dragged, !model.busy else { return }
        withAnimation { model.move(dragged, over: target) }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func performDrop(info: DropInfo) -> Bool { dragged = nil; return true }
    func validateDrop(info: DropInfo) -> Bool { dragged != nil && !model.busy }
}
