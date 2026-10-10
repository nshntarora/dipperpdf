import SwiftUI

struct AppShell: View {
    @State private var selection: String? = "home"
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    DipperAppIcon(size: 42)
                    Text("DipperPDF").font(.headline).foregroundStyle(DipperTheme.ink)
                    Spacer(minLength: 0)
                }.padding(.horizontal, 16).padding(.vertical, 14)
                List(selection: $selection) {
                    Label("Home", systemImage: "house").tag("home")
                    Section("PDF Tools") {
                        ForEach(PDFTool.allCases) { tool in Label(tool.title, systemImage: tool.symbol).tag(tool.rawValue) }
                    }
                }.listStyle(.sidebar).scrollContentBackground(.hidden)
                Label("Entirely offline", systemImage: "lock.shield")
                    .font(.caption).foregroundStyle(DipperTheme.secondary).padding()
            }
            .background(DipperTheme.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        } detail: {
            // Bound tool layouts to the column's available space. Letting the split
            // view measure flexible stacks directly can inflate its minimum height.
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let selectedTool {
                        selectedTool.destination.id(selectedTool.id)
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
    private var home: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                DipperAppIcon(size: 132)
                VStack(alignment: .leading, spacing: 12) {
                    Text("DipperPDF").font(.system(size: 36, weight: .bold))
                    Text("Private PDF tools that run entirely on your Mac.").font(.title3).foregroundStyle(DipperTheme.secondary)
                }
                VStack(spacing: 12) {
                    ForEach(PDFTool.allCases) { tool in
                        Button { selection = tool.rawValue } label: {
                            HStack(spacing: 18) {
                                Image(systemName: tool.symbol).font(.title2).foregroundStyle(DipperTheme.accent)
                                    .frame(width: 48, height: 48)
                                    .background(DipperTheme.selection, in: RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(tool.title).font(.headline)
                                    Text(tool.subtitle).font(.callout).foregroundStyle(DipperTheme.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                            }.padding(24).toolSurface()
                            .contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
                PrivacyNote()
            }.padding(48).frame(maxWidth: 740).frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
