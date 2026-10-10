import SwiftUI

struct WatermarkView: View {
    @StateObject private var model: WatermarkModel
    init(model: WatermarkModel = WatermarkModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .watermark, model: model, canPrepare: model.canWatermark, prepare: model.prepare) {
            if let file = model.files.first {
                ToolSettingsSection(title: "Watermark", detail: "Black text overlays the selected pages. Long text shrinks to fit within 24-point margins. Review the result for overlap with existing content.") {
                    ToolFieldRow(label: "Watermark text") { TextField("DRAFT", text: binding(\.text)) }
                    ToolFieldRow(label: "Position") {
                        Picker("Position", selection: binding(\.position)) {
                            ForEach(WatermarkPosition.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.labelsHidden().accessibilityLabel("Position")
                    }
                    PageRangeFields(count: file.pageCount, first: binding(\.firstPage), last: binding(\.lastPage))
                    ToolFieldRow(label: "Font size") { Stepper("\(model.settings.fontSize) pt", value: binding(\.fontSize), in: 12...96) }
                    ToolFieldRow(label: "Opacity") {
                        HStack {
                            Slider(value: binding(\.opacity), in: 0.1...1, step: 0.05).accessibilityLabel("Watermark opacity")
                            Text("\(Int((model.settings.opacity * 100).rounded()))%").monospacedDigit().frame(width: 50)
                        }
                    }
                    ToolFieldRow(label: "Angle") { Stepper("\(model.settings.angle)°", value: binding(\.angle), in: -90...90, step: 15) }
                    PagePlacementDiagram(watermark: model.settings)
                    if !model.canWatermark {
                        Label(PDFError.watermarkSettings.localizedDescription, systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }
                }
            }
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<WatermarkSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
