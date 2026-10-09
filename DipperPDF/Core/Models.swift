import Foundation

struct PDFFile: Identifiable, Sendable {
    let id = UUID()
    let url: URL
    let data: Data
    let pageCount: Int
    var name: String { url.lastPathComponent }
    var size: String { ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file) }
}

struct PDFResult: Sendable {
    let data: Data
    let suggestedName: String
}

enum PDFError: LocalizedError {
    case invalid, encrypted, permission, processing, save, sourceOverwrite, pageSelection
    var errorDescription: String? {
        switch self {
        case .invalid: return "This file could not be opened as a PDF. It may be damaged or contain no pages."
        case .encrypted: return "This PDF is encrypted. Save an unlocked copy in Preview, then try again."
        case .permission: return "DipperPDF could not read this file. Check its permissions or choose it again using Open."
        case .processing: return "The PDF could not be processed. Try another file or a different compression level."
        case .save: return "The result could not be saved. Choose a writable folder and check available disk space."
        case .pageSelection: return "Select pages to remove and keep at least one page in the PDF."
        case .sourceOverwrite: return "Choose a different filename. DipperPDF keeps your original PDFs safe."
        }
    }
}

enum CompressionLevel: String, CaseIterable, Sendable {
    case light = "Light", balanced = "Balanced", strong = "Strong"
    var dpi: Int { switch self { case .light: 250; case .balanced: 150; case .strong: 96 } }
    var quality: Double { switch self { case .light: 0.85; case .balanced: 0.65; case .strong: 0.4 } }
    var detail: String { "Images up to \(dpi) dpi. " + (self == .strong ? "Best for screen reading; fine image detail may be lost." : "Text and vector artwork stay sharp.") }
}
