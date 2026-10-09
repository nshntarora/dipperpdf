import SwiftUI

struct UnlockView: View {
    @StateObject private var model: UnlockModel

    init(model: UnlockModel = UnlockModel()) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ToolHeader(title: "Unlock PDF", detail: "Remove password protection and save a new PDF that opens without a password.")
                FileDropZone(compact: !model.files.isEmpty, disabled: model.busy) { model.add($0, multiple: false) }
                if let file = model.files.first {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.doc").font(.title2).foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(file.name).font(.headline).lineLimit(1).help(file.name)
                            Text("Encrypted PDF · \(file.size)").font(.callout).foregroundStyle(DipperTheme.secondary)
                        }
                        Spacer()
                    }.padding(18).toolSurface()
                    VStack(alignment: .leading, spacing: 14) {
                        Label("PDF password", systemImage: "key").font(.headline)
                        SecureField("Enter the current password", text: Binding(
                            get: { model.password }, set: model.updatePassword
                        ))
                        .textFieldStyle(.roundedBorder).frame(maxWidth: 400)
                        .accessibilityLabel("PDF password")
                        Text("If the PDF opens without a password, leave this blank. PDFs that restrict copying or page assembly need the owner password.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                        Text("Your original stays encrypted and unchanged.")
                            .font(.callout).foregroundStyle(DipperTheme.secondary)
                    }.padding(24).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
                        .disabled(model.busy)
                    Button(action: model.prepareAndSave) {
                        Label("Save Unlocked PDF…", systemImage: "lock.open")
                    }
                    .buttonStyle(ToolActionStyle()).keyboardShortcut("s").disabled(model.busy)
                }
                ToolStatus(model: model)
                PrivacyNote()
            }.padding(32).frame(maxWidth: 900, alignment: .leading).frame(maxWidth: .infinity)
        }.onDisappear {
            model.cancel()
            if !model.busy { model.updatePassword("") }
        }
    }
}
