import SwiftUI

struct RedactView: View {
    @StateObject private var model: RedactModel
    init(model: RedactModel = RedactModel()) { _model = StateObject(wrappedValue: model) }

    var body: some View {
        ToolWorkspace(tool: .redact, model: model, canPrepare: model.canPrepare,
                      resultDetail: "\(model.matchCount) text matches redacted · Image-only PDF at 144 dpi. Review every page before sharing.",
                      prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Find and redact", detail: "Finds selectable text within each page. Scanned images need OCR first. Matches are covered in black; review every page before sharing.") {
                    PageRangeFields(count: file.pageCount, first: binding(\.firstPage), last: binding(\.lastPage))
                    ToolFieldRow(label: "Text to find") {
                        TextField("Word or phrase (optional with patterns)", text: binding(\.text))
                            .accessibilityLabel("Text to find and redact")
                    }
                    Toggle("Match case", isOn: binding(\.matchCase))
                    Toggle("Redact email addresses", isOn: binding(\.emails))
                    Toggle("Redact phone numbers", isOn: binding(\.phones))
                    Toggle("Redact credit card numbers", isOn: binding(\.creditCards))
                    Text("Patterns find common email formats, phone numbers with 7–15 digits, and card numbers with 13–19 digits. They can miss unusual formats or match unrelated numbers. Card expiry dates, security codes, and names are not detected by these patterns.")
                        .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
                    if !model.canPrepare {
                        Label(PDFError.redactionSettings.localizedDescription, systemImage: "exclamationmark.triangle")
                            .font(DipperTheme.captionFont).foregroundStyle(DipperTheme.warning)
                    }
                }
                ToolSettingsSection(title: "Output", detail: "Every page becomes an image at 144 dpi. Covered pixels are removed before creating a new PDF. Selectable text, links, annotations, forms, bookmarks, attachments, and source metadata are removed from the entire output; only the current visible page area is retained. File size may increase.") {
                    Label("Permanent redaction in a separate copy", systemImage: "rectangle.fill")
                        .font(DipperTheme.bodyFont)
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<RedactionSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
