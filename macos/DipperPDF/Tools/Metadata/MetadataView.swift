import SwiftUI

struct MetadataView: View {
    @StateObject private var model: MetadataModel
    init(model: MetadataModel = MetadataModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .metadata, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "Document details", detail: "Separate keywords with commas. Leave a field empty to remove that detail.") {
                ToolFieldRow(label: "Title") { TextField("Title", text: $model.metadata.title) }
                ToolFieldRow(label: "Author") { TextField("Author", text: $model.metadata.author) }
                ToolFieldRow(label: "Subject") { TextField("Subject", text: $model.metadata.subject) }
                ToolFieldRow(label: "Keywords") { TextField("Keywords", text: $model.keywords) }
                Text("Clearing metadata does not remove personal information from pages or other embedded data.")
                    .font(.caption).foregroundStyle(DipperTheme.secondary)
            }
            if model.result != nil {
                ToolSettingsSection(title: "Metadata changes") {
                    comparison("Title", model.originalMetadata.title, model.outputMetadata.title)
                    comparison("Author", model.originalMetadata.author, model.outputMetadata.author)
                    comparison("Subject", model.originalMetadata.subject, model.outputMetadata.subject)
                    comparison("Keywords", model.originalMetadata.keywords.joined(separator: ", "), model.outputMetadata.keywords.joined(separator: ", "))
                }
            }
        }
    }

    private func comparison(_ label: String, _ original: String, _ updated: String) -> some View {
        ToolFieldRow(label: label) {
            HStack(alignment: .top, spacing: 12) {
                Text(original.isEmpty ? "Empty" : original).foregroundStyle(DipperTheme.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.right").foregroundStyle(DipperTheme.accent)
                Text(updated.isEmpty ? "Empty" : updated).frame(maxWidth: .infinity, alignment: .leading)
            }.font(.callout).textSelection(.enabled)
        }
    }
}
