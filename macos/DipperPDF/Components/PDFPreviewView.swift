import SwiftUI
import AppKit

/// Loads one page at a time, retaining at most eight rendered pages per document.
struct PDFPreviewView: View {
    let data: Data
    @State private var page = 0
    @State private var count = 1
    @State private var images: [Int: Data] = [:]
    @State private var failure: String?
    @State private var retry = 0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: DipperTheme.controlRadius).fill(DipperTheme.background)
                if let bytes = images[page], let image = NSImage(data: bytes) {
                    Image(nsImage: image).resizable().scaledToFit().padding(16)
                } else if let failure {
                    VStack(spacing: 12) {
                        Label("Preview unavailable", systemImage: "doc.questionmark")
                        Text(failure).font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
                        Button("Retry preview") { retry += 1 }
                    }.padding()
                } else { ProgressView("Loading preview…") }
            }.frame(height: 340)
            HStack {
                Button { page -= 1 } label: { Image(systemName: "chevron.left") }
                    .disabled(page == 0).accessibilityLabel("Previous preview page")
                Text("Page \(page + 1) of \(count)").monospacedDigit().font(DipperTheme.bodyFont)
                Button { page += 1 } label: { Image(systemName: "chevron.right") }
                    .disabled(page + 1 >= count).accessibilityLabel("Next preview page")
                Spacer()
                Text("Output preview").font(DipperTheme.captionFont).foregroundStyle(DipperTheme.secondary)
            }.controlSize(DipperTheme.controlSize)
        }
        .task(id: Request(page: page, retry: retry)) {
            guard images[page] == nil else { return }
            let requestedPage = page
            failure = nil
            do {
                let preview = try await PDFEngine.shared.preview(data, page: requestedPage)
                try Task.checkCancellation()
                count = preview.pageCount
                if images.count >= 8 { images = [:] }
                images[requestedPage] = preview.imageData
            } catch is CancellationError { }
            catch { if !Task.isCancelled { failure = error.localizedDescription } }
        }
    }

    private struct Request: Equatable { let page: Int; let retry: Int }
}

struct PDFCover: View {
    let file: PDFFile
    var locked = false
    @State private var image: NSImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5).fill(DipperTheme.background)
            if let image {
                Image(nsImage: image).resizable().scaledToFit().padding(3)
            } else {
                Image(systemName: locked ? "lock.doc" : "doc.richtext").font(.title2).foregroundStyle(DipperTheme.accent)
            }
        }.frame(width: 44, height: 58)
        .accessibilityHidden(true)
        .task(id: file.id) {
            image = nil
            guard !locked else { return }
            do {
                let preview = try await PDFEngine.shared.preview(file.data, page: 0, width: 100)
                try Task.checkCancellation()
                image = NSImage(data: preview.imageData)
            } catch { /* A cover is supplementary; import errors are handled by the model. */ }
        }
    }
}
