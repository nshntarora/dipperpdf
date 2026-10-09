# DipperPDF agent guidance

Applies to this project. Keep these instructions concise and update them when commands or architectural boundaries change. Use `README.md` for the supported tools list and development setup. Keep its Tools section to tool names only; do not add tool descriptions, usage instructions, shortcuts, implementation details, or per-tool limitations in future PRs unless explicitly requested. Put those details in the PR description.

## Project context

DipperPDF is a native, offline macOS PDF utility with Compress, Merge, Rotate, Remove Pages, Extract Pages, Split PDF, Add Page Numbers, Reverse Pages, Edit PDF Metadata, Extract Text, Add Watermark, and Crop PDF tools. It uses Swift 6, SwiftUI, AppKit, PDFKit, and Quartz, targets macOS 14+, and requires full Xcode 16+ selected as the developer toolchain. There are no external packages or services. Local builds use ad hoc signing; no developer account is required.

## Where to work

- `DipperPDF/App/`: app entry, navigation, commands, and `ToolCatalog.swift` tool registration.
- `DipperPDF/Core/`: immutable file/result values, native file panels, and shared `ToolModel` job lifecycle.
- `DipperPDF/PDFEngine/PDFEngine.swift`: actor-isolated loading, validation, processing, thumbnails, and saving.
- `DipperPDF/Tools/{Compress,Merge,Rotate,Remove,Extract,Split,Number,Reverse,Metadata,Text,Watermark,Crop}/`: each tool's workflow model and SwiftUI view.
- `DipperPDF/Components/`: shared UI and `DipperBrand.swift` colors, bird artwork, and app icon rendering.
- `DipperPDFTests/`: primary XCTest suite; `Support/PDFTestCase.swift` supplies generated fixtures.
- `Tests/EngineChecks.swift`: legacy standalone smoke checks.
- `DipperPDF.xcodeproj/`: explicit source membership, build settings, and shared scheme.
- `scripts/` and `.github/workflows/tests.yml`: local commands and macOS CI.

Search source directories rather than generated `build/` or `.build/` trees. Keep build products, result bundles, module caches, and Xcode user state out of source changes.

## Architecture and behavior to preserve

- Keep PDF operations in `PDFEngine`. Mutable `PDFDocument` and `PDFPage` objects stay inside its actor; exchange immutable `PDFFile`, `PDFResult`, `Data`, and `@Sendable` callbacks across the boundary. Keep PDF processing off the main UI actor.
- Workflow models use `@MainActor`. Reuse `ToolModel` for import, job exclusion, progress, cancellation, errors, and saving when its lifecycle fits. Views render state and issue model commands.
- Check cancellation between processing units and before publishing results. Quartz/PDFKit synchronous calls cannot be interrupted mid-call; compression progress represents stages.
- Preserve in-memory input snapshots, balanced security-scoped resource access, atomic saves, and rejection of source overwrite through direct paths, symbolic links, or hard links. Tools must leave source files unchanged.
- Keep core tools usable offline and preserve the app sandbox's user-selected file access. Do not introduce networking, analytics, accounts, or external PDF services as incidental implementation changes.
- Compression uses Quartz image recompression/downsampling, preserves searchable text, and returns original bytes when output would be larger. Do not rasterize whole pages. Presets are Light 250 dpi/85%, Balanced 150 dpi/65%, and Strong 96 dpi/40%.
- Merge preserves the chosen file/page order. Rotate changes existing page rotation metadata and preserves Command/Shift selection behavior. Invalidate stale results when inputs or processing settings change.
- Reject encrypted PDFs, including those that open without a password. Do not promise preservation of signatures or advanced document features; rewriting PDFs can invalidate signatures and alter bookmarks, tags, or forms.
- Follow existing Swift naming, formatting, native controls, keyboard conventions, and shared light/dark brand styling. Prefer focused changes within existing boundaries over new layers or dependencies.

## Adding files or tools

The Xcode project uses explicit file references and Compile Sources entries. Add every new app or test Swift file to its corresponding target in `DipperPDF.xcodeproj/project.pbxproj`; creating a file alone does not compile it.

For a new tool, add its model/view under `DipperPDF/Tools/`, implement processing in the engine, register it in `App/ToolCatalog.swift`, and cover the relevant behavior in `DipperPDFTests/`. Add only the tool name to the README Tools list. Update setup instructions when necessary; describe tool behavior, shortcuts, implementation, and limitations in the PR description.

For icon changes, edit the artwork in `Components/DipperBrand.swift` and use the icon regeneration command in `README.md` with `scripts/generate-icons.swift`; keep generated icon sizes consistent.

## Build and validation

Run commands from the project root. In Xcode, use the shared **DipperPDF** scheme with **My Mac**; Command+R runs the app and Command+U runs tests.

```sh
# Debug build
xcodebuild -project DipperPDF.xcodeproj -scheme DipperPDF \
  -configuration Debug -derivedDataPath build build

# Primary XCTest suite, with coverage and a unique result bundle
./scripts/test.sh

# Focused suite example; other xcodebuild arguments also pass through
./scripts/test.sh -only-testing:DipperPDFTests/RotateModelTests

# Optional legacy engine/workflow smoke checks
./scripts/check-engine.sh
```

The test script writes results under `build/TestResults/`. `DIPPER_TEST_RESULTS` can select a custom `.xcresult` path, which must not already exist. CI runs the primary suite and exports coverage on macOS.

For code changes, run affected tests; use the full suite for shared engine/lifecycle or project configuration changes. For UI changes, build and check the affected flow on a Mac when available. Documentation-only edits need command/path and content review, without rebuilding the app. Report checks actually run and any environment or UI validation gaps.

If a restricted environment blocks Swift macro subprocesses, `README.md` documents the build-command-only override `OTHER_SWIFT_FLAGS='$(inherited) -Xfrontend -disable-sandbox'`. Do not persist it in project settings or disable the application's sandbox to make checks pass.

## Test conventions

- Tests use XCTest and `@testable import DipperPDF` against the real app target. The test bundle is app-hosted; retain the shared scheme's disabled parallel execution.
- Use `PDFTestCase` for generated PDF fixtures and isolated temporary directories; use `XCTestCase` for pure values. Tests must not depend on user documents, network access, or checked-in large PDFs.
- Mark workflow tests `@MainActor`, await operations and `waitForCompletion()`, and inject save destinations so tests do not display native panels. Avoid sleeps and polling.
- Assert PDF semantics and relative sizes rather than exact serialized bytes or compressed sizes that vary across OS versions. Exact bytes are appropriate for original preservation and direct saving. Use `XCTUnwrap` for fallible fixtures.
- Cover observable behavior, error paths, cancellation, state invalidation, and source protection when affected. Unit tests do not validate dialog delivery, drag/drop, keyboard focus, VoiceOver, rendering, or window behavior; those need UI tests or a hands-on pass.

## Pull request descriptions

Keep descriptions short and write them for a reviewer who has not seen the conversation:

1. One paragraph explaining what the tool or change does, including the resulting user behavior.
2. One paragraph explaining how it is implemented, focusing on the relevant architecture and safeguards.
3. A few verification bullets naming checks actually run, their results, CI status, and any material UI validation gaps.

For UI changes, include representative screenshots below the verification bullets in a collapsible `UI screenshots` section. Upload images as PR attachments; do not commit screenshots to the repository. If attachment upload is unavailable, keep captures locally and report that limitation. Capture the actual native UI with generated fixtures; briefly identify view-harness captures or injected destinations when used. Do not present screenshots or unit tests as proof of dialog, drag/drop, keyboard, or accessibility interaction coverage. Omit work logs, abandoned approaches, and repeated implementation details.
