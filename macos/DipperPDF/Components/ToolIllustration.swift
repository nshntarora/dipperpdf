import SwiftUI

/// The same document vocabulary appears on Home and in every tool header.
struct ToolIllustration: View {
    let tool: PDFTool
    var compact = false

    var body: some View {
        HStack(spacing: compact ? 5 : 12) {
            document(output: false)
            Image(systemName: "arrow.right")
                .font(compact ? .caption2 : .title3.weight(.medium))
                .foregroundStyle(DipperTheme.accent)
            document(output: true)
        }
        .padding(compact ? 10 : 20)
        .background(DipperTheme.selection.opacity(0.55), in: RoundedRectangle(cornerRadius: DipperTheme.radius))
        .accessibilityHidden(true)
    }

    private func document(output: Bool) -> some View {
        ZStack {
            if tool == .merge && !output || tool == .split && output {
                sheet(output: output).offset(x: 6, y: -6).opacity(0.5)
            }
            sheet(output: output)
        }.frame(width: compact ? 32 : 72, height: compact ? 44 : 96)
    }

    private func sheet(output: Bool) -> some View {
        VStack(spacing: compact ? 3 : 7) {
            HStack {
                RoundedRectangle(cornerRadius: 2).fill(DipperTheme.accent.opacity(0.35))
                    .frame(width: compact ? 12 : 30, height: compact ? 3 : 5)
                Spacer(minLength: 0)
            }
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2).fill(DipperTheme.border)
                    .frame(height: compact ? 2 : 4)
                    .padding(.trailing, index == 2 ? (compact ? 6 : 14) : 0)
            }
            Spacer(minLength: 0)
            if !compact {
                Text(output ? outputLabel : inputLabel)
                    .font(.system(size: 9, weight: .medium)).foregroundStyle(DipperTheme.secondary)
                    .lineLimit(1).minimumScaleFactor(0.65)
            }
        }
        .padding(compact ? 5 : 10)
        .frame(width: compact ? 28 : 62, height: compact ? 38 : 84)
        .background(DipperTheme.surface, in: RoundedRectangle(cornerRadius: compact ? 3 : 6))
        .overlay(RoundedRectangle(cornerRadius: compact ? 3 : 6).strokeBorder(DipperTheme.border))
        .overlay {
            if output {
                switch tool {
                case .crop:
                    Rectangle().strokeBorder(DipperTheme.accent, style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                        .padding(compact ? 4 : 9)
                case .watermark:
                    Text("DRAFT").font(.system(size: compact ? 7 : 15, weight: .bold))
                        .foregroundStyle(DipperTheme.accent.opacity(0.65)).rotationEffect(.degrees(-30))
                case .number:
                    VStack { Spacer(); Text("1").font(.system(size: compact ? 7 : 12, weight: .semibold)) }.padding(5)
                case .text:
                    Image(systemName: "text.alignleft").foregroundStyle(DipperTheme.accent)
                case .metadata:
                    Image(systemName: "info.circle.fill").foregroundStyle(DipperTheme.accent)
                case .unlock:
                    Image(systemName: "lock.open.fill").foregroundStyle(DipperTheme.accent)
                case .remove:
                    Image(systemName: "minus.circle.fill").foregroundStyle(DipperTheme.accent)
                case .extract:
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(DipperTheme.accent)
                default: EmptyView()
                }
            } else if tool == .annotations {
                Rectangle().fill(DipperTheme.accent.opacity(0.3)).frame(height: compact ? 4 : 10)
                Image(systemName: "bubble.left").foregroundStyle(DipperTheme.accent).offset(x: 12, y: 12)
            } else if tool == .unlock {
                Image(systemName: "lock.fill").foregroundStyle(DipperTheme.accent)
            }
        }
        .rotationEffect(.degrees(tool == .rotate && !output ? -90 : 0))
        .scaleEffect(tool == .compress && output ? 0.8 : 1)
    }

    private var inputLabel: String { tool == .reverse ? "1 · 2 · 3" : "Original" }
    private var outputLabel: String {
        switch tool {
        case .reverse: "3 · 2 · 1"
        case .merge: "Combined"
        case .split: "Parts"
        case .compress: "Smaller"
        case .annotations: "Clean"
        default: "New copy"
        }
    }
}

#Preview("Tool illustrations") {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 210))]) {
        ForEach(PDFTool.allCases) { tool in
            VStack { ToolIllustration(tool: tool); Text(tool.title) }
        }
    }.padding().background(DipperTheme.background)
}

/// A schematic of settings; the prepared PDF remains the authoritative preview.
struct PagePlacementDiagram: View {
    var number: PageNumberSettings? = nil
    var watermark: WatermarkSettings? = nil
    var crop: CropSettings? = nil

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 6).fill(DipperTheme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(DipperTheme.border))
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        Rectangle().fill(DipperTheme.border.opacity(0.7)).frame(height: 3)
                            .padding(.trailing, index % 2 == 0 ? 18 : 0)
                    }
                    Spacer()
                }.padding(16)
                if let number {
                    Text("\(number.startingNumber)").font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity, maxHeight: .infinity,
                               alignment: number.position == .left ? .bottomLeading : number.position == .right ? .bottomTrailing : .bottom)
                        .padding(12)
                }
                if let watermark {
                    Text(watermark.label).font(.system(size: CGFloat(watermark.fontSize) * 0.35, weight: .semibold))
                        .lineLimit(1).minimumScaleFactor(0.1).foregroundStyle(DipperTheme.accent)
                        .opacity(watermark.opacity).rotationEffect(.degrees(Double(-watermark.angle)))
                        .frame(maxWidth: .infinity, maxHeight: .infinity,
                               alignment: watermark.position == .top ? .top : watermark.position == .bottom ? .bottom : .center)
                        .padding(12)
                }
                if let crop {
                    Rectangle().fill(DipperTheme.selection.opacity(0.35))
                        .overlay(Rectangle().strokeBorder(DipperTheme.accent, style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                        .padding(.top, inset(crop.top)).padding(.bottom, inset(crop.bottom))
                        .padding(.leading, inset(crop.left)).padding(.trailing, inset(crop.right))
                }
            }.frame(width: 120, height: 156).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(crop != nil ? "Visible area" : "Placement").font(.callout.weight(.medium))
                Text("Settings diagram\nPrepare the result to review your actual pages.")
                    .font(.caption).foregroundStyle(DipperTheme.secondary)
            }
            Spacer()
        }
    }

    private func inset(_ value: Double) -> CGFloat {
        value.isFinite ? CGFloat(min(max(value * 0.2, 0), 45)) : 0
    }
}
