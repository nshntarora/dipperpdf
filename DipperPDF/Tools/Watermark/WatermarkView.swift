import SwiftUI
import AppKit

struct WatermarkView: View {
    @StateObject private var model: WatermarkModel

    init(model: WatermarkModel = WatermarkModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Add Watermark", detail: "Add a text watermark, then preview and save a new copy.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    Form {
                        TextField("Watermark text", text: binding(\.text))
                        Picker("Position", selection: binding(\.position)) {
                            ForEach(WatermarkPosition.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        Stepper("First page: \(model.settings.firstPage)", value: binding(\.firstPage), in: 1...file.pageCount)
                        Stepper("Last page: \(model.settings.lastPage)", value: binding(\.lastPage), in: 1...file.pageCount)
                        Stepper("Font size: \(model.settings.fontSize) pt", value: binding(\.fontSize), in: 12...96)
                        HStack {
                            Text("Opacity: \(Int((model.settings.opacity * 100).rounded()))%")
                            Slider(value: binding(\.opacity), in: 0.1...1, step: 0.05)
                                .accessibilityLabel("Watermark opacity")
                        }
                        Stepper("Angle: \(model.settings.angle)°", value: binding(\.angle), in: -90...90, step: 15)
                        Text("Black text overlays the selected pages. Long text shrinks to fit within 24-point margins. Other pages stay unchanged. Review the preview for overlap with existing content.")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }.formStyle(.grouped).fixedSize(horizontal: false, vertical: true).disabled(model.busy)
                    if !model.canWatermark {
                        Label(PDFError.watermarkSettings.localizedDescription, systemImage: "info.circle")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }
                    Button(action: model.prepare) { Label("Preview Watermarked PDF", systemImage: "text.badge.plus") }
                        .buttonStyle(ToolActionStyle(prominent: model.result == nil))
                        .keyboardShortcut(.return, modifiers: .command).disabled(model.busy || !model.canWatermark)
                    if model.result != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Your watermarked PDF is ready", systemImage: "checkmark.circle.fill").font(.headline)
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 16) {
                                    ForEach(0..<file.pageCount, id: \.self) { index in
                                        VStack(spacing: 8) {
                                            if let data = model.previews[index], let image = NSImage(data: data) {
                                                Image(nsImage: image).resizable().scaledToFit().frame(width: 140, height: 180)
                                            }
                                            Text("Page \(index + 1)").font(.caption)
                                        }
                                    }
                                }
                            }
                            Button(action: model.save) { Label("Save PDF…", systemImage: "square.and.arrow.down") }
                                .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                        }.padding(24).toolSurface()
                    }
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear { model.cancel() }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<WatermarkSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
