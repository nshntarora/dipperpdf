import SwiftUI
import AppKit

struct CropView: View {
    @StateObject private var model: CropModel

    init(model: CropModel = CropModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Crop PDF", detail: "Trim visible margins, then preview and save a new copy.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    Form {
                        TextField("Top margin (pt)", value: binding(\.top), format: .number.grouping(.never))
                        TextField("Bottom margin (pt)", value: binding(\.bottom), format: .number.grouping(.never))
                        TextField("Left margin (pt)", value: binding(\.left), format: .number.grouping(.never))
                        TextField("Right margin (pt)", value: binding(\.right), format: .number.grouping(.never))
                        Stepper("First page: \(model.settings.firstPage)", value: binding(\.firstPage), in: 1...file.pageCount)
                        Stepper("Last page: \(model.settings.lastPage)", value: binding(\.lastPage), in: 1...file.pageCount)
                        Text("Margins trim the current visible edges, including on rotated pages. The range initially includes all pages; pages outside it stay unchanged. 72 points = 1 inch. Cropping hides content without deleting it and must not be used for redaction.")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }.formStyle(.grouped).fixedSize(horizontal: false, vertical: true).disabled(model.busy)
                    if !model.canCrop {
                        Label(PDFError.croppingSettings.localizedDescription, systemImage: "info.circle")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }
                    Button(action: model.prepare) { Label("Preview Cropped PDF", systemImage: "crop") }
                        .buttonStyle(ToolActionStyle(prominent: model.result == nil))
                        .keyboardShortcut(.return, modifiers: .command).disabled(model.busy || !model.canCrop)
                    if model.result != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Your cropped PDF is ready", systemImage: "checkmark.circle.fill").font(.headline)
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

    private func binding<Value>(_ keyPath: WritableKeyPath<CropSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
