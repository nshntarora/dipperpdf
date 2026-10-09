import SwiftUI

/// Register each tool's identity and destination here; processing stays in its module.
enum PDFTool: String, CaseIterable, Identifiable {
    case compress, merge, rotate
    var id: String { rawValue }
    var title: String { switch self { case .compress: "Compress PDF"; case .merge: "Merge PDFs"; case .rotate: "Rotate PDF" } }
    var symbol: String { switch self { case .compress: "arrow.down.right.and.arrow.up.left"; case .merge: "doc.on.doc"; case .rotate: "rotate.right" } }
    var subtitle: String { switch self { case .compress: "Smaller files, sharper sharing."; case .merge: "Bring your documents together."; case .rotate: "Put every page the right way up." } }
    @MainActor @ViewBuilder var destination: some View {
        switch self { case .compress: CompressView(); case .merge: MergeView(); case .rotate: RotateView() }
    }
}
