import SwiftUI

struct CropView: View {
    @StateObject private var model: CropModel
    init(model: CropModel = CropModel()) { _model = StateObject(wrappedValue: model) }
    @State private var invalidFields: Set<String> = []
    var body: some View {
        ToolWorkspace(tool: .crop, model: model, canPrepare: model.canCrop && invalidFields.isEmpty, prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Crop margins", detail: "Margins trim current visible edges, including rotated pages. 72 points = 1 inch. Cropping hides content without deleting it and must not be used for redaction.") {
                    PageRangeFields(count: file.pageCount, first: binding(\.firstPage), last: binding(\.lastPage))
                    ToolFieldRow(label: "Top margin (pt)") {
                        ToolNumericField(label: "Top margin in points", value: binding(\.top)) { valid in
                                if valid { invalidFields.remove("top") } else { model.invalidateResult(); invalidFields.insert("top") }
                            }
                            .accessibilityLabel("Top margin in points")
                    }
                    ToolFieldRow(label: "Bottom margin (pt)") {
                        ToolNumericField(label: "Bottom margin in points", value: binding(\.bottom)) { valid in
                                if valid { invalidFields.remove("bottom") } else { model.invalidateResult(); invalidFields.insert("bottom") }
                            }
                            .accessibilityLabel("Bottom margin in points")
                    }
                    ToolFieldRow(label: "Left margin (pt)") {
                        ToolNumericField(label: "Left margin in points", value: binding(\.left)) { valid in
                                if valid { invalidFields.remove("left") } else { model.invalidateResult(); invalidFields.insert("left") }
                            }
                            .accessibilityLabel("Left margin in points")
                    }
                    ToolFieldRow(label: "Right margin (pt)") {
                        ToolNumericField(label: "Right margin in points", value: binding(\.right)) { valid in
                                if valid { invalidFields.remove("right") } else { model.invalidateResult(); invalidFields.insert("right") }
                            }
                            .accessibilityLabel("Right margin in points")
                    }
                    PagePlacementDiagram(crop: model.settings)
                    if !model.canCrop {
                        Label(PDFError.croppingSettings.localizedDescription, systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<CropSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
