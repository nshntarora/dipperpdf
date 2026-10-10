import SwiftUI
import AppKit

struct FileSummary: View {
    let file: PDFFile
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.richtext").font(.title2).foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name).font(.headline).lineLimit(1).help(file.name)
                Text("\(file.pageCount) \(file.pageCount == 1 ? "page" : "pages") · \(file.size)")
                    .font(.callout).foregroundStyle(DipperTheme.secondary)
            }
            Spacer()
        }.padding(18).toolSurface()
    }
}

struct ToolHeader: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.largeTitle.bold())
            Text(detail).font(.title3).foregroundStyle(DipperTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToolStatus: View {
    @ObservedObject var model: ToolModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if model.busy {
                HStack {
                    ProgressView(value: model.progress).frame(maxWidth: 240)
                    Text("Working locally…").foregroundStyle(DipperTheme.secondary)
                    Spacer()
                    Button("Cancel", action: model.cancel).keyboardShortcut(.cancelAction)
                }
            }
            if let url = model.savedURL {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2).foregroundStyle(DipperTheme.accent)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Saved successfully").font(.headline)
                        Text(url.lastPathComponent).font(.callout.weight(.medium))
                            .textSelection(.enabled)
                        Text(url.path).font(.caption).foregroundStyle(DipperTheme.secondary)
                            .textSelection(.enabled).fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([url])
                    }.controlSize(.large)
                }.padding(20).frame(maxWidth: .infinity, alignment: .leading).toolSurface()
                    .accessibilityAddTraits(.updatesFrequently)
            } else if let status = model.status {
                Label(status, systemImage: "checkmark.circle").foregroundStyle(DipperTheme.secondary)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .alert("Unable to complete this step", isPresented: Binding(get: { model.error != nil }, set: { if !$0 { model.error = nil } })) {
            Button("OK") { model.error = nil }
        } message: { Text(model.error ?? "") }
    }
}

struct PrivacyNote: View {
    var body: some View {
        Label("Processed locally on this Mac. Your files never leave your computer.", systemImage: "lock.shield")
            .font(.caption).foregroundStyle(DipperTheme.secondary).fixedSize(horizontal: false, vertical: true)
    }
}


// A shared surface keeps file summaries, settings, and results visually related.
extension View {
    func toolSurface() -> some View {
        self.background(DipperTheme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(DipperTheme.border, lineWidth: 1))
    }
}

struct ToolActionStyle: ButtonStyle {
    var prominent = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 24)
            .frame(minWidth: 170, minHeight: 48)
            .foregroundStyle(prominent ? DipperTheme.white : DipperTheme.ink)
            .background(prominent ? DipperTheme.plumage : DipperTheme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(prominent ? DipperTheme.accent : DipperTheme.border, lineWidth: 1))
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
