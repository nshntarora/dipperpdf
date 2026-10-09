import Foundation
import AppKit
import PDFKit
import CoreText

struct CheckFailure: Error, CustomStringConvertible { let description: String }
func check(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() { throw CheckFailure(description: message) }
}

@main
struct EngineChecks {
    static func main() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("DipperPDF-checks-\(UUID())", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let firstURL = folder.appendingPathComponent("first.pdf")
        let secondURL = folder.appendingPathComponent("second.pdf")
        let original = fixture(image: true, size: CGSize(width: 612, height: 792), label: "FIRST searchable text")
        try original.write(to: firstURL)
        let secondData = fixture(image: false, size: CGSize(width: 800, height: 400), label: "SECOND searchable text")
        let secondDoc = PDFDocument(data: secondData)!
        secondDoc.page(at: 0)!.rotation = 90
        secondDoc.page(at: 0)!.setBounds(CGRect(x: 20, y: 10, width: 760, height: 380), for: .cropBox)
        let annotation = PDFAnnotation(bounds: CGRect(x: 60, y: 60, width: 80, height: 30), forType: .text, withProperties: nil)
        annotation.contents = "Keep this annotation"
        secondDoc.page(at: 0)!.addAnnotation(annotation)
        try secondDoc.dataRepresentation()!.write(to: secondURL)
        let engine = PDFEngine.shared
        let first = try await engine.load(firstURL)
        let second = try await engine.load(secondURL)
        try check(first.pageCount == 1 && second.pageCount == 1, "Loading page counts")
        for level in CompressionLevel.allCases {
            let compressed = try await engine.compress(first, level: level, progress: { _ in })
            let doc = PDFDocument(data: compressed.data)!
            try check(compressed.data.count < original.count / 2, "Meaningful image compression: \(level)")
            try check(doc.string?.contains("FIRST searchable text") == true, "Compression retained searchable text")
            try check(doc.page(at: 0)!.bounds(for: .mediaBox).size == CGSize(width: 612, height: 792), "Compression retained page size")
            print("PASS compression \(level.rawValue): \(original.count) → \(compressed.data.count) bytes; text retained")
        }
        let merged = try await engine.merge([second, first], progress: { _ in })
        let mergedDoc = PDFDocument(data: merged.data)!
        try check(mergedDoc.pageCount == 2, "Merge page count")
        try check(mergedDoc.page(at: 0)!.string?.contains("SECOND") == true, "Merge order")
        try check(mergedDoc.page(at: 1)!.string?.contains("FIRST") == true, "Merge order second page")
        try check(mergedDoc.page(at: 0)!.bounds(for: .mediaBox).size == CGSize(width: 800, height: 400), "Merge dimensions")
        try check(mergedDoc.page(at: 0)!.rotation == 90, "Merge orientation")
        try check(mergedDoc.page(at: 0)!.bounds(for: .cropBox) == CGRect(x: 20, y: 10, width: 760, height: 380), "Merge crop box")
        try check(mergedDoc.page(at: 0)!.annotations.contains { $0.contents == "Keep this annotation" }, "Merge annotations")
        print("PASS merge: order, text, dimensions, rotation, crop boxes, annotations")
        let mergedURL = folder.appendingPathComponent("merged.pdf")
        try await engine.save(merged, to: mergedURL, sources: [firstURL, secondURL])
        let mergedInput = try await engine.load(mergedURL)
        let rotated = try await engine.rotate(mergedInput, rotations: [0: -90, 1: 90], progress: { _ in })
        let rotatedDoc = PDFDocument(data: rotated.data)!
        try check(rotatedDoc.page(at: 0)!.rotation == 0 && rotatedDoc.page(at: 1)!.rotation == 90, "Selected rotations")
        try check(rotatedDoc.page(at: 1)!.string?.contains("FIRST") == true, "Rotate text retained")
        let unchanged = try await engine.rotate(mergedInput, rotations: [1: -90], progress: { _ in })
        try check(PDFDocument(data: unchanged.data)!.page(at: 0)!.rotation == 90, "Unselected page unchanged")
        try check(PDFDocument(data: unchanged.data)!.page(at: 1)!.rotation == 270, "Negative angle normalized")
        print("PASS rotate: selected pages, existing rotation, negative angles, unselected pages, text")
        let thumbnailCount = Counter()
        try await engine.thumbnails(mergedInput) { _, data in
            await thumbnailCount.record(data)
        }
        let count = await thumbnailCount.count
        try check(count == 2, "Thumbnail count")
        print("PASS thumbnail generation")
        do {
            try await engine.save(rotated, to: firstURL, sources: [firstURL]); throw CheckFailure(description: "Allowed source overwrite")
        } catch PDFError.sourceOverwrite { }
        let alias = folder.appendingPathComponent("alias.pdf")
        try FileManager.default.createSymbolicLink(at: alias, withDestinationURL: firstURL)
        do {
            try await engine.save(rotated, to: alias, sources: [firstURL]); throw CheckFailure(description: "Allowed symlink overwrite")
        } catch PDFError.sourceOverwrite { }
        let hardlink = folder.appendingPathComponent("hardlink.pdf")
        try FileManager.default.linkItem(at: firstURL, to: hardlink)
        do {
            try await engine.save(rotated, to: hardlink, sources: [firstURL]); throw CheckFailure(description: "Allowed hardlink overwrite")
        } catch PDFError.sourceOverwrite { }
        let sourceAfter = try Data(contentsOf: firstURL)
        try check(sourceAfter == original, "Original changed")
        print("PASS source protection: original path, symbolic links, hard links")
        let invalid = folder.appendingPathComponent("invalid.pdf")
        try Data("not a PDF".utf8).write(to: invalid)
        do { _ = try await engine.load(invalid); throw CheckFailure(description: "Accepted invalid PDF") }
        catch PDFError.invalid { }
        do { _ = try await engine.load(folder.appendingPathComponent("missing.pdf")); throw CheckFailure(description: "Accepted missing file") }
        catch PDFError.permission { }
        let locked = folder.appendingPathComponent("locked.pdf")
        try check(secondDoc.write(to: locked, withOptions: [.userPasswordOption: "password", .ownerPasswordOption: "owner"]), "Encrypted fixture write")
        do { _ = try await engine.load(locked); throw CheckFailure(description: "Accepted encrypted file") }
        catch PDFError.encrypted { }
        do { try await engine.save(rotated, to: folder.appendingPathComponent("missing/target.pdf"), sources: []); throw CheckFailure(description: "Accepted unwritable destination") }
        catch PDFError.save { }
        print("PASS invalid, missing, encrypted PDFs and failed save")
        let cancelled = Task {
            try Task.checkCancellation()
            return try await engine.merge([first, second], progress: { _ in })
        }
        cancelled.cancel()
        do { _ = try await cancelled.value; throw CheckFailure(description: "Cancellation failed") }
        catch is CancellationError { }
        print("PASS cancellation")
        try checkModels(first, second, result: merged)
        print("All PDF engine and workflow checks passed.")
    }

    @MainActor
    static func checkModels(_ first: PDFFile, _ second: PDFFile, result: PDFResult) throws {
        let rotate = RotateModel()
        // A larger selection fixture does not need to parse additional page data.
        rotate.files = [PDFFile(url: first.url, data: first.data, pageCount: 6)]
        rotate.select(1, modifiers: [])
        rotate.select(4, modifiers: .shift)
        try check(rotate.selection == Set(1...4), "Shift selection range")
        rotate.select(2, modifiers: .command)
        try check(rotate.selection == Set([1, 3, 4]), "Command-click deselection")
        rotate.select(5, modifiers: .command)
        try check(rotate.selection == Set([1, 3, 4, 5]), "Command-click addition")
        rotate.selectAll()
        try check(rotate.selection.count == 6, "Select all pages")
        rotate.rotate(by: -90)
        try check(rotate.rotations.values.allSatisfy { $0 == 270 }, "Selected left rotation")
        rotate.rotate(by: 90)
        try check(!rotate.hasChanges, "Reversing rotations returns to original")
        let merge = MergeModel()
        merge.files = [first, second]
        merge.result = result
        merge.savedURL = first.url
        merge.status = "Saved successfully"
        merge.move(first.id, before: second.id)
        try check(merge.files.map(\.id) == [second.id, first.id], "Drag reorder")
        try check(merge.result == nil, "Reorder invalidates output")
        try check(merge.savedURL == nil && merge.status == nil, "Reorder clears stale save confirmation")
        merge.nudge(first.id, by: -1)
        try check(merge.files.map(\.id) == [first.id, second.id], "Keyboard-accessible reorder")
        merge.remove(first.id)
        try check(merge.files.count == 1 && merge.files.first!.id == second.id, "Remove input")
        let compress = CompressModel()
        compress.result = result
        compress.savedURL = first.url
        compress.status = "Saved successfully"
        compress.level = .strong
        try check(compress.result == nil, "Changing compression invalidates output")
        try check(compress.savedURL == nil && compress.status == nil, "Changing compression clears stale save confirmation")
        print("PASS workflow models: Shift/Command selection, select all, reversible rotation, reorder, remove, output invalidation")
    }

    static func fixture(image: Bool, size: CGSize, label: String) -> Data {
        let data = NSMutableData()
        let consumer = CGDataConsumer(data: data)!
        var bounds = CGRect(origin: .zero, size: size)
        let context = CGContext(consumer: consumer, mediaBox: &bounds, nil)!
        context.beginPDFPage(nil)
        if image {
            let width = 2200, height = 2800
            var bytes = [UInt8](repeating: 0, count: width * height * 3)
            var rng: UInt64 = 7
            for i in bytes.indices {
                rng = rng &* 6364136223846793005 &+ 1
                bytes[i] = UInt8(truncatingIfNeeded: rng >> 32)
            }
            let provider = CGDataProvider(data: Data(bytes) as CFData)!
            let cgImage = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width * 3,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: 0), provider: provider,
                                  decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height - 60))
        }
        context.setStrokeColor(CGColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1))
        context.setLineWidth(2)
        context.stroke(CGRect(x: 15, y: 15, width: size.width - 30, height: size.height - 30))
        let string = NSAttributedString(string: label, attributes: [NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName("Helvetica" as CFString, 18, nil)])
        context.textPosition = CGPoint(x: 30, y: size.height - 35)
        CTLineDraw(CTLineCreateWithAttributedString(string), context)
        context.endPDFPage(); context.closePDF()
        return data as Data
    }
}

actor Counter {
    var count = 0
    func record(_ data: Data) { if NSImage(data: data) != nil { count += 1 } }
}
