import SwiftUI
import AppKit

@MainActor
enum DipperToolArtwork {
    static let redactIcon: NSImage = {
        let image = NSImage(size: NSSize(width: 20, height: 16), flipped: false) { _ in
            NSColor.black.setStroke()
            let outline = NSBezierPath(roundedRect: NSRect(x: 1, y: 1, width: 18, height: 14),
                                       xRadius: 2, yRadius: 2)
            outline.lineWidth = 1.5
            outline.stroke()

            let asterisks = NSBezierPath()
            asterisks.lineWidth = 1.2
            asterisks.lineCapStyle = .round
            for centerX: CGFloat in [6.5, 13.5] {
                for angle in [CGFloat(0), .pi / 3, 2 * .pi / 3] {
                    let dx = cos(angle) * 2.5
                    let dy = sin(angle) * 2.5
                    asterisks.move(to: NSPoint(x: centerX - dx, y: 8 - dy))
                    asterisks.line(to: NSPoint(x: centerX + dx, y: 8 + dy))
                }
            }
            asterisks.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }()
}

enum DipperTheme {
    static let titleFont = Font.largeTitle.bold()
    static let headingFont = Font.headline
    static let bodyFont = Font.callout
    static let captionFont = Font.caption
    static let actionFont = Font.system(size: 15, weight: .semibold)
    static let controlSize = ControlSize.large
    static let warning = adaptive(light: 0x8A4C1E, dark: 0xE2B175)
    static let success = accent
    static let workspacePadding: CGFloat = 28
    static let surfacePadding: CGFloat = 22
    static let sectionSpacing: CGFloat = 24
    static let radius: CGFloat = 16
    static let controlRadius: CGFloat = 12

    static let plumage = Color(red: 0.28, green: 0.18, blue: 0.13)
    static let wing = Color(red: 0.39, green: 0.27, blue: 0.20)
    static let white = Color(red: 0.99, green: 0.98, blue: 0.95)
    static let accent = adaptive(light: 0x704A34, dark: 0xD9AE8C)
    static let background = adaptive(light: 0xF8F5EF, dark: 0x211B17)
    static let surface = adaptive(light: 0xFFFDFA, dark: 0x302720)
    static let sidebar = adaptive(light: 0xEFE7DC, dark: 0x282019)
    static let ink = adaptive(light: 0x39291F, dark: 0xF7EFE5)
    static let secondary = adaptive(light: 0x796555, dark: 0xC2AE9B)
    static let border = adaptive(light: 0xDBCCBC, dark: 0x594638)
    static let selection = adaptive(light: 0xEDE0D1, dark: 0x493628)

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let value = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: CGFloat((value >> 16) & 255) / 255,
                           green: CGFloat((value >> 8) & 255) / 255,
                           blue: CGFloat(value & 255) / 255, alpha: 1)
        })
    }
}

/// A compact dipper silhouette: short tail, rounded head, and a white throat and bib.
/// The same vector artwork is used in the interface and rendered into the app icon.
struct DipperMark: View {
    var body: some View {
        ZStack {
            DipperPart(part: .feet).stroke(DipperTheme.plumage, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            DipperPart(part: .body).fill(DipperTheme.plumage)
            DipperPart(part: .bib).fill(DipperTheme.white)
            DipperPart(part: .wing).fill(DipperTheme.wing)
            DipperPart(part: .eye).fill(DipperTheme.white)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

private struct DipperPart: Shape {
    enum Part { case body, bib, wing, eye, feet, feathers }
    let part: Part

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch part {
        case .body:
            path.move(to: CGPoint(x: 18, y: 63))
            path.addLine(to: CGPoint(x: 8, y: 49))
            path.addQuadCurve(to: CGPoint(x: 28, y: 48), control: CGPoint(x: 18, y: 48))
            path.addCurve(to: CGPoint(x: 56, y: 30), control1: CGPoint(x: 35, y: 36), control2: CGPoint(x: 54, y: 40))
            path.addCurve(to: CGPoint(x: 81, y: 35), control1: CGPoint(x: 57, y: 15), control2: CGPoint(x: 81, y: 17))
            path.addCurve(to: CGPoint(x: 89, y: 39), control1: CGPoint(x: 83, y: 37), control2: CGPoint(x: 87, y: 38))
            path.addQuadCurve(to: CGPoint(x: 89, y: 41), control: CGPoint(x: 91, y: 40))
            path.addQuadCurve(to: CGPoint(x: 81, y: 44), control: CGPoint(x: 85, y: 43))
            path.addCurve(to: CGPoint(x: 57, y: 78), control1: CGPoint(x: 83, y: 66), control2: CGPoint(x: 77, y: 78))
            path.addCurve(to: CGPoint(x: 18, y: 63), control1: CGPoint(x: 40, y: 80), control2: CGPoint(x: 24, y: 74))
            path.closeSubpath()
        case .bib:
            path.move(to: CGPoint(x: 76, y: 46))
            path.addCurve(to: CGPoint(x: 58, y: 45), control1: CGPoint(x: 73, y: 43), control2: CGPoint(x: 64, y: 48))
            path.addCurve(to: CGPoint(x: 51, y: 68), control1: CGPoint(x: 50, y: 49), control2: CGPoint(x: 46, y: 62))
            path.addCurve(to: CGPoint(x: 74, y: 67), control1: CGPoint(x: 58, y: 76), control2: CGPoint(x: 69, y: 75))
            path.addCurve(to: CGPoint(x: 76, y: 46), control1: CGPoint(x: 80, y: 60), control2: CGPoint(x: 80, y: 50))
            path.closeSubpath()
        case .wing:
            path.move(to: CGPoint(x: 27, y: 55))
            path.addCurve(to: CGPoint(x: 58, y: 50), control1: CGPoint(x: 36, y: 42), control2: CGPoint(x: 59, y: 42))
            path.addQuadCurve(to: CGPoint(x: 37, y: 68), control: CGPoint(x: 56, y: 65))
            path.addQuadCurve(to: CGPoint(x: 27, y: 55), control: CGPoint(x: 26, y: 66))
            path.closeSubpath()
        case .eye:
            path.addEllipse(in: CGRect(x: 71, y: 30, width: 3.5, height: 3.5))
        case .feet:
            path.move(to: CGPoint(x: 45, y: 76))
            path.addLine(to: CGPoint(x: 43, y: 84))
            path.addLine(to: CGPoint(x: 36, y: 84))
            path.move(to: CGPoint(x: 62, y: 76))
            path.addLine(to: CGPoint(x: 65, y: 84))
            path.addLine(to: CGPoint(x: 72, y: 84))
        case .feathers:
            path.move(to: CGPoint(x: 32, y: 57))
            path.addQuadCurve(to: CGPoint(x: 52, y: 51), control: CGPoint(x: 40, y: 49))
            path.move(to: CGPoint(x: 33, y: 61))
            path.addQuadCurve(to: CGPoint(x: 50, y: 56), control: CGPoint(x: 42, y: 60))
            path.move(to: CGPoint(x: 36, y: 65))
            path.addQuadCurve(to: CGPoint(x: 46, y: 61), control: CGPoint(x: 42, y: 64))
        }
        return path.applying(CGAffineTransform(scaleX: rect.width / 100, y: rect.height / 100)
            .concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY)))
    }
}

struct DipperAppIcon: View {
    var size: CGFloat = 256
    private let tile = RoundedRectangle(cornerRadius: 52, style: .continuous)

    var body: some View {
        ZStack {
            tile
                .fill(LinearGradient(colors: [Color(red: 0.99, green: 0.98, blue: 0.95),
                                              Color(red: 0.89, green: 0.84, blue: 0.76)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: DipperTheme.plumage.opacity(0.16), radius: 4, x: 0, y: 4)

            ZStack {
                Ellipse().fill(.white.opacity(0.85))
                    .frame(width: 220, height: 145).blur(radius: 22).offset(x: -45, y: -76)
                Ellipse().fill(Color(red: 0.75, green: 0.61, blue: 0.46).opacity(0.15))
                    .frame(width: 170, height: 100).blur(radius: 28).offset(x: 70, y: 90)
                tile.fill(.white.opacity(0.18))
                // Enlarge the bird out of the lower-left corner, with the
                // head and beak reaching toward the upper-right of the tile.
                DipperCeramicMark()
                    .frame(width: 340, height: 340)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -58, y: 45)
                tile.strokeBorder(LinearGradient(colors: [.white.opacity(0.95), .white.opacity(0.2),
                                                          DipperTheme.plumage.opacity(0.06)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                tile.inset(by: 2.5).strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
            }
            .frame(width: 224, height: 224)
            .clipShape(tile)
        }
        .frame(width: 224, height: 224)
        .frame(width: 256, height: 256)
        .scaleEffect(size / 256)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// Explicit highlights and shaded fills keep the exported PNG deterministic,
/// without depending on a window's backdrop or the system material renderer.
private struct DipperCeramicMark: View {
    private let bronze = Color(red: 0.58, green: 0.39, blue: 0.26)
    private let edge = LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.04),
                                              DipperTheme.plumage.opacity(0.12)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            DipperPart(part: .body)
                .fill(RadialGradient(colors: [Color(red: 0.67, green: 0.49, blue: 0.36),
                                              bronze, DipperTheme.plumage],
                                     center: UnitPoint(x: 0.55, y: 0.22), startRadius: 0, endRadius: 210))
                .overlay(DipperPart(part: .body).stroke(edge, lineWidth: 1))
                .shadow(color: DipperTheme.plumage.opacity(0.28), radius: 5, x: 1, y: 6)
                .shadow(color: DipperTheme.plumage.opacity(0.15), radius: 1, x: 0, y: 1)

            DipperPart(part: .bib)
                .fill(LinearGradient(colors: [.white, DipperTheme.white,
                                              Color(red: 0.85, green: 0.80, blue: 0.71)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(DipperPart(part: .bib).stroke(edge, lineWidth: 0.8))
                .shadow(color: DipperTheme.plumage.opacity(0.18), radius: 2, x: 0, y: 2)

            DipperPart(part: .wing)
                .fill(LinearGradient(colors: [Color(red: 0.72, green: 0.55, blue: 0.40).opacity(0.95),
                                              bronze, DipperTheme.wing],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(DipperPart(part: .wing).stroke(edge, lineWidth: 0.9))
                .shadow(color: DipperTheme.plumage.opacity(0.26), radius: 3, x: 0, y: 3)

            DipperPart(part: .feathers)
                .stroke(DipperTheme.plumage.opacity(0.22), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                .overlay(DipperPart(part: .feathers)
                    .stroke(.white.opacity(0.2), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .offset(y: -1))

            DipperPart(part: .eye)
                .fill(Color(red: 0.13, green: 0.09, blue: 0.07))
                .overlay(DipperPart(part: .eye).stroke(bronze.opacity(0.6), lineWidth: 1))
                .overlay {
                    GeometryReader { geometry in
                        Circle().fill(.white.opacity(0.9))
                            .frame(width: geometry.size.width * 0.009, height: geometry.size.height * 0.009)
                            .position(x: geometry.size.width * 0.721, y: geometry.size.height * 0.309)
                    }
                }
        }
    }
}
