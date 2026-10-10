import SwiftUI
import AppKit

struct PageThumbnail: View {
    let image: NSImage?
    let index: Int
    let rotation: Int
    let selected: Bool
    private var fill: Color { selected ? DipperTheme.selection : DipperTheme.surface }
    private var border: Color { selected ? DipperTheme.accent : DipperTheme.border }
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let image {
                    Image(nsImage: image).resizable().scaledToFit()
                        .frame(width: 115, height: 150)
                        .rotationEffect(.degrees(Double(rotation)))
                } else { ProgressView() }
            }.frame(width: 160, height: 180)
            Text("Page \(index + 1)").font(.callout)
        }
        .padding(8).frame(maxWidth: .infinity)
        .background(fill, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: selected ? 2 : 1))
    }
}
