import Foundation

struct RedactionSettings: Sendable {
    var firstPage = 1
    var lastPage = 1
    var text = ""
    var matchCase = false
    var emails = false
    var phones = false
    var creditCards = false

    var query: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    func isValid(pageCount: Int) -> Bool {
        firstPage >= 1 && lastPage >= firstPage && lastPage <= pageCount &&
        (!query.isEmpty || emails || phones || creditCards)
    }

    /// Literal search is escaped; user text is never interpreted as a regular expression.
    func matches(in text: String) throws -> [NSRange] {
        var patterns: [(pattern: String, phone: Bool, literal: Bool)] = []
        if !query.isEmpty { patterns.append((query.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            .map(NSRegularExpression.escapedPattern(for:)).joined(separator: #"\s+"#), false, true)) }
        if emails { patterns.append((#"(?<![\w.%+\-])[A-Z0-9.!#$%&'*+/=?^_`{|}~\-]+@[A-Z0-9](?:[A-Z0-9\-]*[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9\-]*[A-Z0-9])?)+"#, false, false)) }
        // Avoid line breaks and stop before letters so nearby text is not swallowed.
        if phones { patterns.append((#"(?<![\w])\+?(?:\([0-9]{1,4}\)|[0-9])(?:[0-9().\-\u00A0 ]*[0-9])?(?![\w])"#, true, false)) }
        if creditCards { patterns.append((#"(?<![0-9])(?<![0-9][ \u00A0\-])[0-9](?:[ \u00A0\-]?[0-9]){12,18}(?![ \u00A0\-]?[0-9])"#, false, false)) }
        var ranges: [NSRange] = []
        for entry in patterns {
            try Task.checkCancellation()
            let options: NSRegularExpression.Options = entry.literal && matchCase ? [] : [.caseInsensitive]
            let regex = try NSRegularExpression(pattern: entry.pattern, options: options)
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                try Task.checkCancellation()
                if entry.phone {
                    let value = (text as NSString).substring(with: match.range)
                    let digits = value.filter { $0.isASCII && $0.isNumber }.count
                    guard (7...15).contains(digits) else { continue }
                }
                ranges.append(match.range)
            }
        }
        // Collapse overlaps (e.g. the same number matching both phone and card patterns).
        var merged: [NSRange] = []
        for range in ranges.sorted(by: { $0.location < $1.location }) {
            if let last = merged.last, range.location < NSMaxRange(last) {
                merged[merged.count - 1] = NSUnionRange(last, range)
            } else { merged.append(range) }
        }
        return merged
    }
}

struct RedactionResult: Sendable {
    let pdf: PDFResult
    let matchCount: Int
}
