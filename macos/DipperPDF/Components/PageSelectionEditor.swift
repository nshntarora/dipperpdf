import SwiftUI
import AppKit

struct PageSelectionEditor: View {
    let file: PDFFile
    let thumbnails: [Int: NSImage]
    let selection: Set<Int>
    var rotations: [Int: Int] = [:]
    var removing = false
    let select: (Int, NSEvent.ModifierFlags) -> Void
    let setSelection: (Set<Int>) -> Void
    var editingChanged: (Bool) -> Void = { _ in }
    @FocusState private var editingRange: Bool
    @State private var range = ""
    @State private var validation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ToolSettingsSection(title: removing ? "Pages to remove" : "Select pages") {
                ToolFieldRow(label: "Page numbers") {
                    HStack {
                        TextField("1–3, 5", text: $range).focused($editingRange).onSubmit(applyRange)
                            .accessibilityLabel("Selected page numbers and ranges")
                        Button("Apply", action: applyRange)
                    }
                }
                if let validation {
                    Label(validation, systemImage: "exclamationmark.triangle").font(DipperTheme.captionFont)
                        .foregroundStyle(DipperTheme.secondary)
                }
                HStack {
                    Text(removing ? "\(selection.count) to remove · \(file.pageCount - selection.count) remaining" :
                         "\(selection.count) of \(file.pageCount) selected")
                        .font(DipperTheme.bodyFont).foregroundStyle(DipperTheme.secondary)
                    Spacer()
                    Button("Select All") { setSelection(Set(0..<file.pageCount)) }
                    Button("Clear") { setSelection([]) }.disabled(selection.isEmpty)
                }
                Text("Click a page to select it. Command-click adds pages; Shift-click selects a range.")
                    .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(0..<file.pageCount, id: \.self) { index in
                    Button { select(index, NSEvent.modifierFlags) } label: {
                        PageThumbnail(image: thumbnails[index], index: index,
                                      rotation: rotations[index, default: 0], selected: selection.contains(index))
                            .overlay(alignment: .topTrailing) {
                                if selection.contains(index) {
                                    Image(systemName: removing ? "minus.circle.fill" : "checkmark.circle.fill")
                                        .font(.title2).foregroundStyle(DipperTheme.accent).padding(12)
                                }
                            }
                    }.buttonStyle(.plain)
                        .accessibilityLabel("Page \(index + 1)")
                        .accessibilityValue(selection.contains(index) ? (removing ? "Selected for removal" : "Selected") : "Not selected")
                        .accessibilityAddTraits(selection.contains(index) ? .isSelected : [])
                }
            }.padding(4)
        }
        .onAppear { range = PageSelection.format(selection) }
        .onChange(of: editingRange) { _, editing in editingChanged(editing) }
        .onDisappear { editingChanged(false) }
        .onChange(of: selection) { _, newValue in
            range = PageSelection.format(newValue)
            validation = nil
        }
    }

    private func applyRange() {
        do {
            let pages = try PageSelection.parse(range, pageCount: file.pageCount)
            setSelection(pages)
            range = PageSelection.format(pages)
            validation = nil
        } catch { validation = error.localizedDescription }
    }
}
