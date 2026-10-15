import Foundation
import SwiftUI

enum IndiaNightEasterEgg {
    static func isEligible(regionCode: String?, date: Date, calendar: Calendar) -> Bool {
        guard regionCode?.uppercased() == "IN" else { return false }
        let hour = calendar.component(.hour, from: date)
        return hour >= 20 || hour < 6
    }

    static func isEligibleNow(at date: Date = .now) -> Bool {
        isEligible(
            regionCode: Locale.autoupdatingCurrent.region?.identifier,
            date: date,
            calendar: .autoupdatingCurrent
        )
    }
}

private struct IndiaNightEasterEggMessage: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if IndiaNightEasterEgg.isEligibleNow(at: context.date) {
                Text("You're using Dipper at night, noice!")
                    .font(DipperTheme.captionFont)
                    .foregroundStyle(DipperTheme.secondary)
                    .accessibilityLabel("You're using Dipper at night, noice!")
            }
        }
    }
}

struct AppShell: View {
    @State private var selection: String?
    @FocusState private var sidebarFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appearsActive) private var appearsActive
    private let toolDestination: (PDFTool) -> AnyView
    private let sidebarControlActiveState: ControlActiveState

    /// The production app uses each tool's standard destination. The injectable
    /// destination keeps native view-harness captures on the same app shell.
    init(initialSelection: String? = "home",
         toolDestination: @escaping (PDFTool) -> AnyView = { AnyView($0.destination) },
         sidebarControlActiveState: ControlActiveState = .active) {
        _selection = State(initialValue: initialSelection)
        self.toolDestination = toolDestination
        self.sidebarControlActiveState = sidebarControlActiveState
    }
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    DipperAppIcon(size: 42)
                    Text("DipperPDF").font(.headline).foregroundStyle(DipperTheme.ink)
                    Spacer(minLength: 0)
                }.padding(.horizontal, 16).padding(.vertical, 14)
                List(selection: $selection) {
                    Label {
                        Text("Home").foregroundStyle(sidebarForegroundColor(for: "home"))
                    } icon: {
                        Image(systemName: "house")
                            .foregroundStyle(sidebarForegroundColor(for: "home", unselected: DipperTheme.accent))
                    }.tag("home")
                    Section("PDF Tools") {
                        ForEach(PDFTool.allCases) { tool in
                            Label {
                                Text(tool.title).foregroundStyle(sidebarForegroundColor(for: tool.rawValue))
                            } icon: {
                                tool.icon.foregroundStyle(sidebarForegroundColor(for: tool.rawValue, unselected: DipperTheme.accent))
                            }
                                .tag(tool.rawValue)
                        }
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .focused($sidebarFocused)
                // Keep the selected destination legible when the sidebar is reached
                // with the keyboard, rather than falling back to AppKit's faint
                // inactive-selection treatment.
                .environment(\.controlActiveState, sidebarControlActiveState)
            }
            .background(DipperTheme.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        } detail: {
            // Bound tool layouts to the column's available space. Letting the split
            // view measure flexible stacks directly can inflate its minimum height.
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let selectedTool {
                        toolDestination(selectedTool).id(selectedTool.id)
                    } else {
                        home
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            }
            .background(DipperTheme.background)
            .navigationTitle(selectedTool?.title ?? "DipperPDF")
            .toolbarBackground(DipperTheme.background, for: .windowToolbar)
            .toolbarBackground(.visible, for: .windowToolbar)
        }
    }
    private var selectedTool: PDFTool? {
        selection.flatMap(PDFTool.init(rawValue:))
    }
    private func sidebarForegroundColor(for destination: String, unselected: Color = DipperTheme.ink) -> Color {
        guard selection == destination, sidebarFocused, appearsActive else { return unselected }
        // The dark-mode accent is light tan; its emphasized selection needs dark text and icons.
        return colorScheme == .dark ? DipperTheme.plumage : DipperTheme.white
    }
    private var home: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                DipperAppIcon(size: 132)
                VStack(alignment: .leading, spacing: 12) {
                    Text("DipperPDF").font(.system(size: 36, weight: .bold))
                    Text("Private PDF tools that run entirely on your Mac.").font(.title3).foregroundStyle(DipperTheme.secondary)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                    ForEach(PDFTool.allCases) { tool in
                        Button { selection = tool.rawValue } label: {
                            HStack(alignment: .center, spacing: 16) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tool.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text(tool.subtitle)
                                        .font(.callout)
                                        .foregroundStyle(DipperTheme.secondary)
                                        .lineLimit(2)

                                    Label("Open tool", systemImage: "arrow.right")
                                        .font(.caption)
                                        .foregroundStyle(DipperTheme.accent)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                ToolIllustration(tool: tool, compact: true)
                                    .frame(width: 104, height: 76)
                            }
                            .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .toolSurface()
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
                IndiaNightEasterEggMessage()
            }.padding(32).frame(maxWidth: 1000).frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
