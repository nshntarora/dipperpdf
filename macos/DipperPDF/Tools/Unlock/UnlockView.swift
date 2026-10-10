import SwiftUI

struct UnlockView: View {
    @StateObject private var model: UnlockModel
    init(model: UnlockModel = UnlockModel()) { _model = StateObject(wrappedValue: model) }
    var body: some View {
        ToolWorkspace(tool: .unlock, model: model, prepare: model.prepare) {
            ToolSettingsSection(title: "PDF password") {
                ToolFieldRow(label: "Password") {
                    SecureField("Enter the current password", text: Binding(
                        get: { model.password },
                        set: { model.updatePassword($0) }
                    ))
                        .accessibilityLabel("PDF password")
                }
                Text("If the PDF opens without a password, leave this blank. PDFs that restrict copying or page assembly need the owner password.")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
                Text("Your original stays encrypted and unchanged.").font(.caption).foregroundStyle(DipperTheme.secondary)
            }
        }
    }
}
