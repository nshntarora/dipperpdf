import SwiftUI
import AppKit

struct NumberView: View {
    @StateObject private var model: NumberModel

    init(model: NumberModel = NumberModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Add Page Numbers", detail: "Number a page range, then preview and save a new copy.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    FileSummary(file: file)
                    Form {
                        Picker("Position", selection: binding(\.position)) {
                            ForEach(PageNumberPosition.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        Stepper("First page: \(model.settings.firstPage)", value: binding(\.firstPage), in: 1...file.pageCount)
                        Stepper("Last page: \(model.settings.lastPage)", value: binding(\.lastPage), in: 1...file.pageCount)
                        TextField("Starting number", value: binding(\.startingNumber), format: .number.grouping(.never))
                        Stepper("Font size: \(model.settings.fontSize) pt", value: binding(\.fontSize), in: 8...32)
                        Text("Numbering starts at the first page in the range. Other pages stay unnumbered. Black numbers sit 24 points from the visible bottom edge and may overlap existing content.")
                            .font(.caption).foregroundStyle(DipperTheme.secondary)
                    }.formStyle(.grouped).fixedSize(horizontal: false, vertical: true).disabled(model.busy)
                    if !model.canNumber {
                        Label(PDFError.numberingSettings.localizedDescription, systemImage: "info.circle")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }
                    Button(action: model.prepare) { Label("Preview Numbered PDF", systemImage: "number") }
                        .buttonStyle(ToolActionStyle(prominent: model.result == nil))
                        .keyboardShortcut(.return, modifiers: .command).disabled(model.busy || !model.canNumber)
                    if model.result != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Your numbered PDF is ready", systemImage: "checkmark.circle.fill").font(.headline)
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

    private func binding<Value>(_ keyPath: WritableKeyPath<PageNumberSettings, Value>) -> Binding<Value> {
        Binding(get: { model.settings[keyPath: keyPath] }, set: { value in
            var settings = model.settings
            settings[keyPath: keyPath] = value
            model.update(settings)
        })
    }
}
