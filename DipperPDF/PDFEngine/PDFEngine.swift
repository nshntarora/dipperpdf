import AppKit
import PDFKit
import Quartz
import CoreText

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

    func metadata(_ file: PDFFile) throws -> PDFMetadata {
        let attributes = try document(file.data).documentAttributes ?? [:]
        return PDFMetadata(title: attributes[PDFDocumentAttribute.titleAttribute] as? String ?? "",
                           author: attributes[PDFDocumentAttribute.authorAttribute] as? String ?? "",
                           subject: attributes[PDFDocumentAttribute.subjectAttribute] as? String ?? "",
                           keywords: attributes[PDFDocumentAttribute.keywordsAttribute] as? [String] ?? [])
    }

    func editMetadata(_ file: PDFFile, metadata: PDFMetadata, progress: Progress) async throws -> PDFResult {
        let doc = try document(file.data)
        var attributes = doc.documentAttributes ?? [:]
        // Retain attributes outside the four editable fields, including creation metadata.
        for (key, value) in [(PDFDocumentAttribute.titleAttribute, metadata.title),
                             (.authorAttribute, metadata.author), (.subjectAttribute, metadata.subject)] {
            if value.isEmpty { attributes.removeValue(forKey: key) }
            else { attributes[key] = value }
        }
        if metadata.keywords.isEmpty { attributes.removeValue(forKey: PDFDocumentAttribute.keywordsAttribute) }
        else { attributes[PDFDocumentAttribute.keywordsAttribute] = metadata.keywords }
        doc.documentAttributes = attributes
        await progress(0.5)
        let output = try result(doc, name: file.url.deletingPathExtension().lastPathComponent + "-metadata.pdf")
        await progress(1)
        try Task.checkCancellation()
        return output
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

    func addPageNumbers(_ file: PDFFile, settings: PageNumberSettings, progress: Progress) async throws -> PDFResult {
        let doc = try document(file.data)
        guard settings.isValid(pageCount: doc.pageCount) else { throw PDFError.numberingSettings }
        let count = settings.lastPage - settings.firstPage + 1
        for index in (settings.firstPage - 1)..<settings.lastPage {
            try Task.checkCancellation()
            guard let page = doc.page(at: index), let reference = page.pageRef else { throw PDFError.processing }
            let crop = reference.getBoxRect(.cropBox)
            let rotated = ((page.rotation % 360) + 360) % 360
            let size = rotated == 90 || rotated == 270 ? CGSize(width: crop.height, height: crop.width) : crop.size
            let displayed = CGRect(origin: .zero, size: size)
            let transform = reference.getDrawingTransform(.cropBox, rect: displayed, rotate: 0, preserveAspectRatio: true)
            let label = String(settings.startingNumber + (index - (settings.firstPage - 1)))
            let layout = PageNumberLayout(label: label, settings: settings, displayed: displayed)
            guard displayed.insetBy(dx: 8, dy: 8).contains(layout.labelBounds) else {
                throw PDFError.numberingSettings
            }
            let data = NSMutableData()
            var media = reference.getBoxRect(.mediaBox)
            guard let consumer = CGDataConsumer(data: data),
                  let context = CGContext(consumer: consumer, mediaBox: &media, nil) else { throw PDFError.processing }
            context.beginPDFPage(nil)
            context.drawPDFPage(reference)
            context.saveGState()
            context.concatenate(transform.inverted())
            context.textMatrix = .identity
            context.textPosition = CGPoint(x: layout.labelBounds.minX, y: layout.labelBounds.minY + 4)
            CTLineDraw(layout.line, context)
            context.restoreGState()
            context.endPDFPage()
            context.closePDF()
            guard let numbered = PDFDocument(data: data as Data)?.page(at: 0) else { throw PDFError.processing }
            numbered.rotation = page.rotation
            for box in [PDFDisplayBox.cropBox, .bleedBox, .trimBox, .artBox] {
                numbered.setBounds(page.bounds(for: box), for: box)
            }
            for existing in page.annotations {
                guard let copy = existing.copy() as? PDFAnnotation else { throw PDFError.processing }
                numbered.addAnnotation(copy)
            }
            doc.removePage(at: index)
            doc.insert(numbered, at: index)
            await progress(Double(index - settings.firstPage + 2) / Double(count))
        }
        return try result(doc, name: file.url.deletingPathExtension().lastPathComponent + "-numbered.pdf")
    }

    func addWatermark(_ file: PDFFile, settings: WatermarkSettings, progress: Progress) async throws -> PDFResult {
        let doc = try document(file.data)
        guard settings.isValid(pageCount: doc.pageCount) else { throw PDFError.watermarkSettings }
        let count = settings.lastPage - settings.firstPage + 1
        for index in (settings.firstPage - 1)..<settings.lastPage {
            try Task.checkCancellation()
            guard let page = doc.page(at: index), let reference = page.pageRef else { throw PDFError.processing }
            let crop = reference.getBoxRect(.cropBox)
            let rotated = ((page.rotation % 360) + 360) % 360
            let size = rotated == 90 || rotated == 270 ? CGSize(width: crop.height, height: crop.width) : crop.size
            let displayed = CGRect(origin: .zero, size: size)
            let layout = try WatermarkLayout(settings: settings, displayed: displayed)
            let transform = reference.getDrawingTransform(.cropBox, rect: displayed, rotate: 0, preserveAspectRatio: true)
            let data = NSMutableData()
            var media = reference.getBoxRect(.mediaBox)
            guard let consumer = CGDataConsumer(data: data),
                  let context = CGContext(consumer: consumer, mediaBox: &media, nil) else { throw PDFError.processing }
            context.beginPDFPage(nil)
            context.drawPDFPage(reference)
            context.saveGState()
            // Draw in upright visible coordinates, then map back to the original page.
            context.concatenate(transform.inverted())
            context.clip(to: displayed)
            context.translateBy(x: layout.center.x, y: layout.center.y)
            context.rotate(by: layout.radians)
            context.scaleBy(x: layout.scale, y: layout.scale)
            context.setAlpha(CGFloat(settings.opacity))
            context.textMatrix = .identity
            context.textPosition = CGPoint(x: -layout.textBounds.midX, y: -layout.textBounds.midY)
            CTLineDraw(layout.line, context)
            context.restoreGState()
            context.endPDFPage()
            context.closePDF()
            guard let stamped = PDFDocument(data: data as Data)?.page(at: 0) else { throw PDFError.processing }
            stamped.rotation = page.rotation
            for box in [PDFDisplayBox.cropBox, .bleedBox, .trimBox, .artBox] {
                stamped.setBounds(page.bounds(for: box), for: box)
            }
            for existing in page.annotations {
                guard let copy = existing.copy() as? PDFAnnotation else { throw PDFError.processing }
                stamped.addAnnotation(copy)
            }
            doc.removePage(at: index)
            doc.insert(stamped, at: index)
            await progress(Double(index - settings.firstPage + 2) / Double(count))
        }
        return try result(doc, name: file.url.deletingPathExtension().lastPathComponent + "-watermarked.pdf")
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

    func extractText(_ file: PDFFile, progress: Progress) async throws -> PDFResult {
        let input = try document(file.data)
        var pages: [String] = []
        for index in 0..<input.pageCount {
            try Task.checkCancellation()
            guard let page = input.page(at: index) else { throw PDFError.processing }
            pages.append((page.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
            await progress(Double(index + 1) / Double(input.pageCount))
        }
        try Task.checkCancellation()
        guard pages.contains(where: { !$0.isEmpty }) else { throw PDFError.noText }
        return PDFResult(data: Data((pages.joined(separator: "\n\n") + "\n").utf8),
                         suggestedName: file.url.deletingPathExtension().lastPathComponent + "-text.txt")
    }

    func reversePages(_ file: PDFFile, progress: Progress) async throws -> PDFResult {
        let input = try document(file.data)
        let output = PDFDocument()
        for index in (0..<input.pageCount).reversed() {
            try Task.checkCancellation()
            guard let page = input.page(at: index)?.copy() as? PDFPage else { throw PDFError.processing }
            output.insert(page, at: output.pageCount)
            await progress(Double(output.pageCount) / Double(input.pageCount))
        }
        return try result(output, name: file.url.deletingPathExtension().lastPathComponent + "-reversed.pdf")
    }

    func split(_ file: PDFFile, pagesPerFile: Int, progress: Progress) async throws -> [PDFResult] {
        let input = try document(file.data)
        guard pagesPerFile > 0, pagesPerFile <= input.pageCount else { throw PDFError.splitCount }
        let base = file.url.deletingPathExtension().lastPathComponent
        var outputs: [PDFResult] = []
        for start in stride(from: 0, to: input.pageCount, by: pagesPerFile) {
            let output = PDFDocument()
            let end = min(start + pagesPerFile, input.pageCount)
            for index in start..<end {
                try Task.checkCancellation()
                guard let page = input.page(at: index)?.copy() as? PDFPage else { throw PDFError.processing }
                output.insert(page, at: output.pageCount)
                await progress(Double(index + 1) / Double(input.pageCount))
            }
            outputs.append(try result(output, name: "\(base)-pages-\(start + 1)-\(end).pdf"))
        }
        try Task.checkCancellation()
        return outputs
    }

    /// Stage the entire batch, then publish a new folder. Existing files are never replaced.
    func saveSplit(_ outputs: [PDFResult], in folder: URL, name: String, sources: [URL],
                   progress: Progress) async throws -> URL {
        try Task.checkCancellation()
        guard !outputs.isEmpty, !name.isEmpty, name != ".", name != "..", !name.contains("/"),
              Set(outputs.map(\.suggestedName)).count == outputs.count,
              outputs.allSatisfy({ !$0.suggestedName.isEmpty && $0.suggestedName != "." &&
                  $0.suggestedName != ".." && !$0.suggestedName.contains("/") }) else { throw PDFError.save }
        let access = folder.startAccessingSecurityScopedResource()
        defer { if access { folder.stopAccessingSecurityScopedResource() } }
        let manager = FileManager.default
        let staging = folder.appendingPathComponent(".dipper-split-" + UUID().uuidString, isDirectory: true)
        do { try manager.createDirectory(at: staging, withIntermediateDirectories: false) }
        catch { throw PDFError.save }
        defer { try? manager.removeItem(at: staging) }
        for (index, output) in outputs.enumerated() {
            try Task.checkCancellation()
            try save(output, to: staging.appendingPathComponent(output.suggestedName), sources: sources)
            await progress(Double(index + 1) / Double(outputs.count))
        }
        try Task.checkCancellation()
        var destination = folder.appendingPathComponent(name, isDirectory: true)
        var suffix = 2
        while manager.fileExists(atPath: destination.path) {
            try Task.checkCancellation()
            destination = folder.appendingPathComponent("\(name)-\(suffix)", isDirectory: true)
            suffix += 1
        }
        // moveItem fails if a destination appears after the existence check.
        do { try manager.moveItem(at: staging, to: destination) }
        catch { throw PDFError.save }
        return destination
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

/// Text layout uses visible coordinates; the engine maps it back to the PDF page.
private struct PageNumberLayout {
    let labelBounds: CGRect
    let line: CTLine

    init(label: String, settings: PageNumberSettings, displayed: CGRect) {
        let text = NSAttributedString(string: label, attributes: [
            NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, CGFloat(settings.fontSize), nil),
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(gray: 0, alpha: 1)
        ])
        line = CTLineCreateWithAttributedString(text)
        let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        let x: CGFloat
        switch settings.position {
        case .left: x = 24
        case .center: x = (displayed.width - width) / 2
        case .right: x = displayed.width - 24 - width
        }
        labelBounds = CGRect(x: x, y: 24, width: width, height: CGFloat(settings.fontSize) + 8)
    }
}

/// Fit the rotated glyph bounds inside each visible page without clipping long labels.
private struct WatermarkLayout {
    let line: CTLine
    let textBounds: CGRect
    let radians: CGFloat
    let scale: CGFloat
    let center: CGPoint

    init(settings: WatermarkSettings, displayed: CGRect) throws {
        let text = NSAttributedString(string: settings.label, attributes: [
            NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica-Bold" as CFString, CGFloat(settings.fontSize), nil),
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(gray: 0, alpha: 1)
        ])
        line = CTLineCreateWithAttributedString(text)
        textBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        radians = CGFloat(settings.angle) * .pi / 180
        let rotated = textBounds.applying(CGAffineTransform(rotationAngle: radians))
        let available = displayed.insetBy(dx: 24, dy: 24)
        guard available.width > 0, available.height > 0, textBounds.width > 0, textBounds.height > 0 else {
            throw PDFError.watermarkSettings
        }
        scale = min(1, available.width / rotated.width, available.height / rotated.height)
        let halfHeight = rotated.height * scale / 2
        let y: CGFloat
        switch settings.position {
        case .top: y = available.maxY - halfHeight
        case .center: y = available.midY
        case .bottom: y = available.minY + halfHeight
        }
        center = CGPoint(x: available.midX, y: y)
    }
}
