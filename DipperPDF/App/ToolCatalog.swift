import SwiftUI

/// Register each tool's identity and destination here; processing stays in its module.
enum PDFTool: String, CaseIterable, Identifiable {
    case compress, merge, rotate, remove, extract, split, number, reverse, metadata
    var id: String { rawValue }
    var title: String { switch self { case .compress: "Compress PDF"; case .merge: "Merge PDFs"; case .rotate: "Rotate PDF"; case .remove: "Remove Pages"; case .split: "Split PDF"; case .extract: "Extract Pages"; case .number: "Add Page Numbers"; case .reverse: "Reverse Pages"; case .metadata: "Edit PDF Metadata" } }
    var symbol: String { switch self { case .compress: "arrow.down.right.and.arrow.up.left"; case .merge: "doc.on.doc"; case .rotate: "rotate.right"; case .remove: "doc.badge.minus"; case .split: "rectangle.split.2x1"; case .extract: "doc.on.doc.fill"; case .number: "number"; case .reverse: "arrow.up.arrow.down"; case .metadata: "info.circle" } }
    var subtitle: String { switch self { case .compress: "Smaller files, sharper sharing."; case .merge: "Bring your documents together."; case .rotate: "Put every page the right way up."; case .remove: "Keep the pages you need."; case .split: "Divide a document into smaller PDFs."; case .extract: "Save chosen pages as a new PDF."; case .number: "Give every page a number."; case .reverse: "Put the last page first."; case .metadata: "Update your document’s details." } }
    @MainActor @ViewBuilder var destination: some View {
        switch self { case .compress: CompressView(); case .merge: MergeView(); case .rotate: RotateView(); case .remove: RemoveView(); case .split: SplitView(); case .extract: ExtractView(); case .number: NumberView(); case .reverse: ReverseView(); case .metadata: MetadataView() }
    }
}
