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

struct PDFMetadata: Equatable, Sendable {
    var title = ""
    var author = ""
    var subject = ""
    var keywords: [String] = []
}

enum PDFError: LocalizedError {
    case invalid, encrypted, permission, processing, save, sourceOverwrite, pageSelection, extractionSelection, splitCount, numberingSettings, noText, watermarkSettings, croppingSettings
    var errorDescription: String? {
        switch self {
        case .noText: return "This PDF has no selectable text. Scanned documents need OCR before text can be extracted."
        case .invalid: return "This file could not be opened as a PDF. It may be damaged or contain no pages."
        case .encrypted: return "This PDF is encrypted. Save an unlocked copy in Preview, then try again."
        case .permission: return "DipperPDF could not read this file. Check its permissions or choose it again using Open."
        case .processing: return "The PDF could not be processed. Try another file or a different compression level."
        case .save: return "The result could not be saved. Choose a writable folder and check available disk space."
        case .splitCount: return "Choose a page count between 1 and the number of pages in this PDF."
        case .watermarkSettings: return "Enter up to 200 characters on one line, a valid page range, a font size from 12 to 96 points, opacity from 10% to 100%, and an angle from −90° to 90°."
        case .croppingSettings: return "Choose a valid page range and finite, nonnegative margins that leave a visible area on every selected page."
        case .numberingSettings: return "Choose a valid page range, a positive starting number, and a font size from 8 to 32 points."
        case .extractionSelection: return "Select at least one page from this PDF to extract."
        case .pageSelection: return "Select pages to remove and keep at least one page in the PDF."
        case .sourceOverwrite: return "Choose a different filename. DipperPDF keeps your original PDFs safe."
        }
    }
}

enum PageNumberPosition: String, CaseIterable, Sendable {
    case left = "Bottom left", center = "Bottom center", right = "Bottom right"
}

struct PageNumberSettings: Sendable {
    var firstPage = 1
    var lastPage = 1
    var startingNumber = 1
    var fontSize = 12
    var position: PageNumberPosition = .center

    func isValid(pageCount: Int) -> Bool {
        firstPage >= 1 && lastPage >= firstPage && lastPage <= pageCount &&
        startingNumber > 0 && startingNumber <= Int.max - (lastPage - firstPage) &&
        (8...32).contains(fontSize)
    }
}

enum CompressionLevel: String, CaseIterable, Sendable {
    case light = "Light", balanced = "Balanced", strong = "Strong"
    var dpi: Int { switch self { case .light: 250; case .balanced: 150; case .strong: 96 } }
    var quality: Double { switch self { case .light: 0.85; case .balanced: 0.65; case .strong: 0.4 } }
    var detail: String { "Images up to \(dpi) dpi. " + (self == .strong ? "Best for screen reading; fine image detail may be lost." : "Text and vector artwork stay sharp.") }
}

struct CropSettings: Sendable {
    var firstPage = 1
    var lastPage = 1
    var top = 18.0
    var bottom = 18.0
    var left = 18.0
    var right = 18.0

    func isValid(pageCount: Int) -> Bool {
        firstPage >= 1 && lastPage >= firstPage && lastPage <= pageCount &&
        [top, bottom, left, right].allSatisfy { $0.isFinite && $0 >= 0 }
    }
}

enum WatermarkPosition: String, CaseIterable, Sendable {
    case top = "Top", center = "Center", bottom = "Bottom"
}

struct WatermarkSettings: Sendable {
    var text = "DRAFT"
    var firstPage = 1
    var lastPage = 1
    var fontSize = 48
    var opacity = 0.25
    var angle = 45
    var position: WatermarkPosition = .center

    var label: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    func isValid(pageCount: Int) -> Bool {
        !label.isEmpty && text.count <= 200 &&
        text.rangeOfCharacter(from: .newlines.union(.controlCharacters)) == nil &&
        firstPage >= 1 && lastPage >= firstPage && lastPage <= pageCount &&
        (12...96).contains(fontSize) && opacity.isFinite && (0.1...1).contains(opacity) &&
        (-90...90).contains(angle)
    }
}
