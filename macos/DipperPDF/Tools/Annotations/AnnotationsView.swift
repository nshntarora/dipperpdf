import SwiftUI

struct AnnotationsView: View {
    @StateObject private var model: AnnotationsModel
    init(model: AnnotationsModel = AnnotationsModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .annotations, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "Remove review markup") {
                Text("Comments, highlights, text boxes, drawings, and stamps will be removed from every page.")
                Text("Links and form fields are kept. Marks flattened into page content cannot be removed.")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
