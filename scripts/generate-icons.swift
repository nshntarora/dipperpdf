import SwiftUI
import AppKit

// Compile with DipperPDF/Components/DipperBrand.swift to share the icon's palette and bird geometry with the UI.
@main
struct GenerateIcons {
    @MainActor
    static func main() throws {
        let output = URL(fileURLWithPath: CommandLine.arguments.count > 1
            ? CommandLine.arguments[1] : "DipperPDF/Assets.xcassets/AppIcon.appiconset")
        for size in [16, 32, 64, 128, 256, 512, 1024] {
            let renderer = ImageRenderer(content: DipperAppIcon())
            renderer.scale = CGFloat(size) / 256
            guard let image = renderer.cgImage,
                  let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
                throw NSError(domain: "DipperPDF.Icon", code: 1)
            }
            try data.write(to: output.appendingPathComponent("icon-\(size).png"))
        }
    }
}
