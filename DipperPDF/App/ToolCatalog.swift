import SwiftUI

/// Register each tool's identity and destination here; processing stays in its module.
enum PDFTool: String, CaseIterable, Identifiable {
    case compress, merge, rotate, remove, extract
    var id: String { rawValue }
    var title: String { switch self { case .compress: "Compress PDF"; case .merge: "Merge PDFs"; case .rotate: "Rotate PDF"; case .remove: "Remove Pages"; case .extract: "Extract Pages" } }
    var symbol: String { switch self { case .compress: "arrow.down.right.and.arrow.up.left"; case .merge: "doc.on.doc"; case .rotate: "rotate.right"; case .remove: "doc.badge.minus"; case .extract: "doc.on.doc.fill" } }
    var subtitle: String { switch self { case .compress: "Smaller files, sharper sharing."; case .merge: "Bring your documents together."; case .rotate: "Put every page the right way up."; case .remove: "Keep the pages you need."; case .extract: "Save chosen pages as a new PDF." } }
    @MainActor @ViewBuilder var destination: some View {
        switch self { case .compress: CompressView(); case .merge: MergeView(); case .rotate: RotateView(); case .remove: RemoveView(); case .extract: ExtractView() }
    }
}
