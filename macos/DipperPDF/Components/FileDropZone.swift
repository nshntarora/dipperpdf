import SwiftUI
import UniformTypeIdentifiers

struct FileDropZone: View {
    var multiple = false
    var compact = false
    var disabled = false
    let receive: ([URL]) -> Void
    @State private var targeted = false
    @State private var readingDrop = false

    var body: some View {
        Button {
            receive(FilePanels.open(multiple: multiple))
        } label: {
            Group {
                if compact {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(.tint)
                        Text(multiple ? "Add PDFs…" : "Replace PDF…").font(.callout.weight(.medium))
                        Spacer()
                        Text("Drop here or browse").font(.caption).foregroundStyle(DipperTheme.secondary)
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(DipperTheme.secondary)
                    }
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "doc.badge.plus").font(.system(size: 40, weight: .light)).foregroundStyle(.tint)
                        Text(multiple ? "Drop PDFs here" : "Drop a PDF here").font(.title3.weight(.semibold))
                        Text(multiple ? "Choose PDFs…" : "Choose PDF…").font(.callout).foregroundStyle(DipperTheme.secondary)
                        Text("PDF files · Processed on your Mac").font(.caption).foregroundStyle(DipperTheme.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity).padding(compact ? 18 : 36)
            .background(targeted ? DipperTheme.selection : DipperTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: DipperTheme.controlRadius))
            .overlay(RoundedRectangle(cornerRadius: DipperTheme.controlRadius).strokeBorder(targeted ? DipperTheme.accent : DipperTheme.border, style: StrokeStyle(lineWidth: targeted ? 2 : 1, dash: [6])))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut("o")
        .disabled(disabled || readingDrop)
        .accessibilityLabel(multiple ? "Add PDF files" : "Choose a PDF file")
        .onDrop(of: [.fileURL], isTargeted: $targeted) { providers in
            guard !disabled, !readingDrop else { return false }
            readingDrop = true
            Task { @MainActor in
                var urls: [URL] = []
                for provider in providers {
                    let url: URL? = await withCheckedContinuation { continuation in
                        _ = provider.loadObject(ofClass: NSURL.self) { object, _ in
                            continuation.resume(returning: object as? URL)
                        }
                    }
                    if let url, url.isFileURL { urls.append(url) }
                }
                readingDrop = false
                if !urls.isEmpty { receive(urls) }
            }
            return true
        }
    }
}
