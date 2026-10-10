import SwiftUI

struct ReverseView: View {
    @StateObject private var model: ReverseModel
    init(model: ReverseModel = ReverseModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .reverse, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "New page order") {
                if let file = model.files.first {
                    HStack(spacing: 16) {
                        Text("1 → \(file.pageCount)").font(.title2.monospacedDigit())
                        Image(systemName: "arrow.right").foregroundStyle(DipperTheme.accent)
                        Text("\(file.pageCount) → 1").font(.title2.monospacedDigit())
                    }
                    Text(file.pageCount == 1 ? "This PDF has one page. Its order stays the same." : "The last page becomes the first. Page content and rotation stay the same.")
                        .foregroundStyle(DipperTheme.secondary)
                }
            }
        }
    }
}
