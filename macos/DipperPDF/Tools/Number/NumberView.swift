import SwiftUI

struct NumberView: View {
    @StateObject private var model: NumberModel
    init(model: NumberModel = NumberModel()) { _model = StateObject(wrappedValue: model) }
    @State private var invalidFields: Set<String> = []
    var body: some View {
        ToolWorkspace(tool: .number, model: model, canPrepare: model.canNumber && invalidFields.isEmpty, prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Numbering", detail: "Numbers start at the first page in the range. Black numbers sit 24 points from the visible bottom edge and may overlap existing content. Other pages stay unchanged.") {
                    ToolFieldRow(label: "Position") {
                        Picker("Position", selection: binding(\.position)) {
                            ForEach(PageNumberPosition.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.labelsHidden().accessibilityLabel("Position")
                    }
                    PageRangeFields(count: file.pageCount, first: binding(\.firstPage), last: binding(\.lastPage))
                    ToolFieldRow(label: "Starting number") { ToolNumericField(label: "Starting number", value: binding(\.startingNumber)) { valid in
                                if valid { invalidFields.remove("startingNumber") } else { model.invalidateResult(); invalidFields.insert("startingNumber") }
                            } }
                    ToolFieldRow(label: "Font size") { Stepper("\(model.settings.fontSize) pt", value: binding(\.fontSize), in: 8...32) }
                    PagePlacementDiagram(number: model.settings)
                    if !model.canNumber {
                        Label(PDFError.numberingSettings.localizedDescription, systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<PageNumberSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
