import SwiftUI
import UniformTypeIdentifiers

struct MergeView: View {
    @StateObject private var model = MergeModel()
    @State private var dragged: UUID?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ToolHeader(title: "Merge PDFs", detail: "Combine PDFs in the order below. Drag rows to reorder them.")
            FileDropZone(multiple: true, compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: true) }
            if !model.files.isEmpty {
                List {
                    ForEach(Array(model.files.enumerated()), id: \.element.id) { index, file in
                        HStack(spacing: 12) {
                            Text("\(index + 1)").monospacedDigit().foregroundStyle(DipperTheme.secondary).frame(width: 25)
                            Image(systemName: "line.3.horizontal").foregroundStyle(.tertiary)
                            FileSummary(file: file)
                            Button { model.remove(file.id) } label: { Image(systemName: "minus.circle") }
                                .buttonStyle(.borderless).help("Remove \(file.name)").accessibilityLabel("Remove \(file.name)")
                        }
                        .listRowBackground(DipperTheme.background)
                        .contentShape(Rectangle())
                        .onDrag { dragged = file.id; return NSItemProvider(object: file.id.uuidString as NSString) }
                        .onDrop(of: [.text], delegate: MergeReorderDelegate(target: file.id, dragged: $dragged, model: model))
                        .contextMenu {
                            Button("Move Up") { model.nudge(file.id, by: -1) }.disabled(index == 0)
                            Button("Move Down") { model.nudge(file.id, by: 1) }.disabled(index == model.files.count - 1)
                            Button("Remove") { model.remove(file.id) }
                        }
                    }
                    .onMove { offsets, destination in
                        model.files.move(fromOffsets: offsets, toOffset: destination); model.result = nil
                    }
                }.listStyle(.inset).scrollContentBackground(.hidden).disabled(model.busy)
                Text("\(model.files.count) files · \(model.files.reduce(0) { $0 + $1.pageCount }) pages")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
            } else { Spacer() }
            if !model.files.isEmpty {
                HStack {
                    Button(action: model.merge) { Label("Merge PDFs", systemImage: "doc.on.doc") }
                        .buttonStyle(ToolActionStyle(prominent: model.result == nil))
                        .keyboardShortcut(.return, modifiers: .command).disabled(model.files.count < 2 || model.busy)
                    if model.result != nil {
                        Button(action: model.save) { Label("Save PDF…", systemImage: "square.and.arrow.down") }
                            .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                    }
                }
            }
            ToolStatus(model: model)
            PrivacyNote()
        }.padding(32).frame(maxWidth: 1000).frame(maxWidth: .infinity).onDisappear { model.cancel() }
    }
}

private struct MergeReorderDelegate: DropDelegate {
    let target: UUID
    @Binding var dragged: UUID?
    let model: MergeModel
    func dropEntered(info: DropInfo) {
        guard let dragged, !model.busy else { return }
        withAnimation { model.move(dragged, before: target) }
    }
    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }
    func performDrop(info: DropInfo) -> Bool { dragged = nil; return true }
    func validateDrop(info: DropInfo) -> Bool { dragged != nil && !model.busy }
}
