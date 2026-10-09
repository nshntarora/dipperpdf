import SwiftUI

@MainActor
class ToolModel: ObservableObject {
    @Published var files: [PDFFile] = []
    @Published var result: PDFResult? {
        didSet {
            if result == nil { savedURL = nil; status = nil }
        }
    }
    @Published var savedURL: URL?
    @Published var busy = false
    @Published var progress = 0.0
    @Published var error: String?
    @Published var status: String?
    private var job: Task<Void, Never>?
    let saveDestination: @MainActor (String) -> URL?

    init(saveDestination: @escaping @MainActor (String) -> URL? = { FilePanels.save(name: $0) }) {
        self.saveDestination = saveDestination
    }

    /// Await the current operation without polling observable state.
    func waitForCompletion() async { await job?.value }

    func run(_ operation: @escaping @MainActor () async throws -> Void) {
        guard !busy else { return }
        busy = true
        progress = 0
        error = nil
        status = nil
        savedURL = nil
        job = Task {
            defer { busy = false; job = nil }
            do { try await operation() }
            catch is CancellationError { status = "Cancelled. Your originals are unchanged." }
            catch { self.error = error.localizedDescription }
        }
    }

    func cancel() { job?.cancel() }

    func add(_ urls: [URL], multiple: Bool) {
        run {
            var loaded: [PDFFile] = []
            var failures: [String] = []
            for url in multiple ? urls : Array(urls.prefix(1)) {
                do { loaded.append(try await PDFEngine.shared.load(url)) }
                catch is CancellationError { throw CancellationError() }
                catch { failures.append("\(url.lastPathComponent): \(error.localizedDescription)") }
            }
            try Task.checkCancellation()
            if !loaded.isEmpty {
                self.files = multiple ? self.files + loaded : loaded
                self.result = nil
                try await self.inputsChanged()
            }
            if !failures.isEmpty { self.error = failures.joined(separator: "\n\n") }
        }
    }

    func inputsChanged() async throws { }

    func report(_ value: Double) { progress = value }

    func save() {
        guard !busy, let result, let url = saveDestination(result.suggestedName) else { return }
        let sources = files.map(\.url)
        run {
            try await PDFEngine.shared.save(result, to: url, sources: sources)
            self.savedURL = url
            self.status = "Saved \(url.lastPathComponent)."
        }
    }
}
