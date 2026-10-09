import AppKit
import PDFKit
import Quartz

/// PDFKit objects never cross this actor boundary. Callers exchange immutable data.
actor PDFEngine {
    static let shared = PDFEngine()
    typealias Progress = @Sendable (Double) async -> Void

    func load(_ url: URL) throws -> PDFFile {
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }
        let data: Data
        do { data = try Data(contentsOf: url) } catch { throw PDFError.permission }
        let doc = try document(data)
        return PDFFile(url: url, data: data, pageCount: doc.pageCount)
    }

    private func document(_ data: Data) throws -> PDFDocument {
        try Task.checkCancellation()
        guard let doc = PDFDocument(data: data) else { throw PDFError.invalid }
        guard !doc.isEncrypted else { throw PDFError.encrypted }
        guard doc.pageCount > 0 else { throw PDFError.invalid }
        for index in 0..<doc.pageCount {
            try Task.checkCancellation()
            guard doc.page(at: index)?.pageRef != nil else { throw PDFError.invalid }
        }
        return doc
    }

    func compress(_ file: PDFFile, level: CompressionLevel, progress: Progress) async throws -> PDFResult {
        let doc = try document(file.data)
        await progress(0.1)
        // These settings mirror Apple's installed Reduce File Size Quartz filter.
        let properties: [String: Any] = [
            "Domains": ["Applications": true], "FilterType": 1, "Name": "DipperPDF \(level.rawValue)",
            "FilterData": ["ColorSettings": ["ImageSettings": [
                "Compression Quality": level.quality, "ImageCompression": "ImageJPEGCompress",
                "ImageScaleSettings": ["ImageResolution": level.dpi, "ImageScaleInterpolate": true,
                                       "ImageSizeMax": level.dpi * 20, "ImageSizeMin": 0]
            ]]]
        ]
        guard let filter = QuartzFilter(properties: properties),
              let output = doc.dataRepresentation(options: [PDFDocumentWriteOption(rawValue: "QuartzFilter"): filter]) else {
            throw PDFError.processing
        }
        try Task.checkCancellation()
        let validated = try document(output)
        guard validated.pageCount == file.pageCount else { throw PDFError.processing }
        await progress(1)
        try Task.checkCancellation()
        // Never offer a larger file when the source is already optimized.
        return PDFResult(data: output.count < file.data.count ? output : file.data,
                         suggestedName: file.url.deletingPathExtension().lastPathComponent + "-compressed.pdf")
    }

    func merge(_ files: [PDFFile], progress: Progress) async throws -> PDFResult {
        guard files.count >= 2 else { throw PDFError.processing }
        let output = PDFDocument()
        let total = files.reduce(0) { $0 + $1.pageCount }
        for file in files {
            let input = try document(file.data)
            for index in 0..<input.pageCount {
                try Task.checkCancellation()
                guard let page = input.page(at: index)?.copy() as? PDFPage else { throw PDFError.processing }
                output.insert(page, at: output.pageCount)
                await progress(Double(output.pageCount) / Double(total))
            }
        }
        return try result(output, name: "Merged.pdf")
    }

    func rotate(_ file: PDFFile, rotations: [Int: Int], progress: Progress) async throws -> PDFResult {
        let doc = try document(file.data)
        for index in 0..<doc.pageCount {
            try Task.checkCancellation()
            guard let page = doc.page(at: index) else { throw PDFError.processing }
            page.rotation = ((page.rotation + rotations[index, default: 0]) % 360 + 360) % 360
            await progress(Double(index + 1) / Double(doc.pageCount))
        }
        return try result(doc, name: file.url.deletingPathExtension().lastPathComponent + "-rotated.pdf")
    }

    func removePages(_ file: PDFFile, removing indices: Set<Int>, progress: Progress) async throws -> PDFResult {
        let input = try document(file.data)
        guard !indices.isEmpty, indices.count < input.pageCount,
              indices.allSatisfy({ (0..<input.pageCount).contains($0) }) else {
            throw PDFError.pageSelection
        }
        let output = PDFDocument()
        for index in 0..<input.pageCount {
            try Task.checkCancellation()
            if !indices.contains(index) {
                guard let page = input.page(at: index)?.copy() as? PDFPage else { throw PDFError.processing }
                output.insert(page, at: output.pageCount)
            }
            await progress(Double(index + 1) / Double(input.pageCount))
        }
        return try result(output, name: file.url.deletingPathExtension().lastPathComponent + "-removed.pdf")
    }

    func extractPages(_ file: PDFFile, selecting indices: Set<Int>, progress: Progress) async throws -> PDFResult {
        let input = try document(file.data)
        guard !indices.isEmpty, indices.allSatisfy({ (0..<input.pageCount).contains($0) }) else {
            throw PDFError.extractionSelection
        }
        let output = PDFDocument()
        // Selection order never changes the original page order.
        for index in indices.sorted() {
            try Task.checkCancellation()
            guard let page = input.page(at: index)?.copy() as? PDFPage else { throw PDFError.processing }
            output.insert(page, at: output.pageCount)
            await progress(Double(output.pageCount) / Double(indices.count))
        }
        return try result(output, name: file.url.deletingPathExtension().lastPathComponent + "-extracted.pdf")
    }

    func thumbnails(_ file: PDFFile, receive: @Sendable (Int, Data) async -> Void) async throws {
        let doc = try document(file.data)
        for index in 0..<doc.pageCount {
            try Task.checkCancellation()
            let png: Data? = autoreleasepool {
                guard let page = doc.page(at: index),
                      let tiff = page.thumbnail(of: NSSize(width: 140, height: 180), for: .cropBox).tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiff) else { return nil }
                return bitmap.representation(using: .png, properties: [:])
            }
            guard let png else { throw PDFError.processing }
            await receive(index, png)
        }
    }

    private func result(_ doc: PDFDocument, name: String) throws -> PDFResult {
        try Task.checkCancellation()
        guard let data = doc.dataRepresentation() else { throw PDFError.processing }
        _ = try document(data)
        return PDFResult(data: data, suggestedName: name)
    }

    func save(_ result: PDFResult, to destination: URL, sources: [URL]) throws {
        try Task.checkCancellation()
        let access = destination.startAccessingSecurityScopedResource()
        defer { if access { destination.stopAccessingSecurityScopedResource() } }
        let target = destination.resolvingSymlinksInPath().standardizedFileURL
        for source in sources {
            let original = source.resolvingSymlinksInPath().standardizedFileURL
            let sourceID = try? source.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
            let targetID = try? destination.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier
            if target == original || (sourceID != nil && targetID != nil && (sourceID! as AnyObject).isEqual(targetID!)) {
                throw PDFError.sourceOverwrite
            }
        }
        do { try result.data.write(to: destination, options: .atomic) } catch { throw PDFError.save }
    }
}
