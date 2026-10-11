import SwiftUI

struct RepairView: View {
    @StateObject private var model: RepairModel
    init(model: RepairModel = RepairModel()) { _model = StateObject(wrappedValue: model) }

    var body: some View {
        ToolWorkspace(tool: .repair, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "Rebuild a readable copy") {
                Text("Rebuild the document from its readable pages to help resolve PDF structure problems. Page order, text, and artwork are kept.")
                Text("Recovery depends on what macOS can read. Missing or unreadable content cannot be restored. Review the prepared copy before saving.")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
                Text("Bookmarks, forms, and other document features may change. Digital signatures will no longer be valid.")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
