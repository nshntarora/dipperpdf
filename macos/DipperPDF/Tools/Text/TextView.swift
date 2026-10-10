import SwiftUI

struct TextView: View {
    @StateObject private var model: TextModel
    init(model: TextModel = TextModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .text, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "Plain text output") {
                Text("Text is extracted in page order, with a blank line between pages.")
                Text("Scanned images need OCR. Layout and formatting are not preserved; reading order within a page may vary.")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
