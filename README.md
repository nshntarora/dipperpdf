# DipperPDF

![DipperPDF app logo: a brown dipper bird with a white bib](DipperPDF/Assets.xcassets/AppIcon.appiconset/icon-128.png)

A native, offline macOS app for everyday PDF tasks. Your documents stay on your Mac, and every tool saves a separate output file so your originals remain unchanged.

Built with Swift 6, SwiftUI, AppKit, PDFKit, and Quartz. Requires **macOS 14+** to run and full **Xcode 16+** to build. No external packages, accounts, analytics, or PDF services.

## Tools

- **Compress PDF**
- **Merge PDFs**
- **Rotate PDF**
- **Remove Pages**
- **Extract Pages**
- **Split PDF**
- **Add Page Numbers**
- **Reverse Pages**
- **Extract Text**

## Meet the dipper

The app's brown-and-white bird artwork takes its cue from the dipper. These little songbirds hunt underwater in fast-flowing streams for insect larvae and freshwater shrimps. Their name comes from the bobbing, or “dipping,” motion they make on land. The white-throated dipper sports a bright white throat and chest against its dark plumage—the same distinctive bib you'll see in the app's logo. Learn more from the [RSPB's dipper guide](https://www.rspb.org.uk/birds-and-wildlife/dipper).

## Build and run

1. Open `DipperPDF.xcodeproj` in Xcode.
2. Select the shared **DipperPDF** scheme and **My Mac**.
3. Press **Command+R**.

Local builds use **Sign to Run Locally** (ad hoc signing), so no developer account is required. For distribution, choose your own bundle identifier and signing team, then configure Developer ID signing and notarization.

To build and launch from Terminal, with full Xcode selected as the developer toolchain:

```sh
xcodebuild -project DipperPDF.xcodeproj -scheme DipperPDF \
  -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/DipperPDF.app
```

## Development

```text
DipperPDF/
  App/                 App entry, navigation, commands, and tool registration
  Core/                Immutable file/result values, panels, shared job lifecycle
  PDFEngine/           Actor-isolated PDF operations, thumbnails, and saving
  Components/          Shared controls, brand colors, and bird artwork
  Tools/
    Compress/          Compression model and view
    Merge/             Ordered merge model and view
    Rotate/            Page selection and rotation model and view
    Remove/            Page removal model and view
    Extract/           Selected-page extraction model and view
    Split/             Fixed-page-count splitting model and view
    Number/            Page numbering model and view
    Reverse/           Page reversal model and view
    Text/              Text extraction model and view
  Assets.xcassets/      Native app icon
DipperPDFTests/         Primary XCTest suite and generated fixtures
Tests/                 Legacy standalone smoke checks
scripts/               Test and icon generation commands
```

`PDFEngine` owns PDF processing off the main UI actor. Mutable `PDFDocument` and `PDFPage` objects stay inside its actor; immutable `PDFFile`, `PDFResult`, byte data, and sendable callbacks cross the boundary. Workflow models run on `@MainActor` and use `ToolModel` for imports, job exclusion, progress, cancellation, errors, and saving. Views render state and issue model commands.

Inputs are held as in-memory snapshots after balanced security-scoped access. Saving uses a native panel and atomic writes, and rejects source overwrite through direct paths, symbolic links, or hard links. The app sandbox permits user-selected file access; the app has no network entitlements.

### Add a tool

1. Add its workflow model and SwiftUI view under `DipperPDF/Tools/`. Reuse `ToolModel` when its lifecycle fits.
2. Implement processing in `PDFEngine`, keeping PDFKit objects inside the actor. Accept progress callbacks and check cancellation between processing units and before publishing results.
3. Register the tool in `DipperPDF/App/ToolCatalog.swift`.
4. Add every new Swift file to the appropriate target's file references and Compile Sources in `DipperPDF.xcodeproj`. Add relevant tests in `DipperPDFTests/`.
5. Add the tool name to the Tools list in this README. Keep tool behavior, shortcuts, implementation details, and limitations in the PR description; do not add them to the README.

## Testing

In Xcode, select **DipperPDF** and **My Mac**, then press **Command+U**. From the project root:

```sh
# Primary XCTest suite with coverage
./scripts/test.sh

# Focused suite; other xcodebuild arguments also pass through
./scripts/test.sh -only-testing:DipperPDFTests/RotateModelTests

# Optional legacy engine/workflow smoke checks
./scripts/check-engine.sh
```

The test script writes a unique `.xcresult` bundle under `build/TestResults/`. Open it in Xcode to inspect results and coverage. To choose a result path, use a path that does not already exist:

```sh
DIPPER_TEST_RESULTS=build/TestResults/local.xcresult ./scripts/test.sh
xcrun xccov view --report build/TestResults/local.xcresult
```

The app-hosted XCTest bundle imports the real app target with `@testable import DipperPDF`. The shared scheme disables parallel execution. Tests cover PDF loading and validation, compression and searchable text, merge ordering, rotation, page removal, extraction, thumbnails, cancellation, atomic saving, source protection, workflow state, and tool registration. `.github/workflows/tests.yml` runs the primary suite on macOS, exports coverage, and uploads result bundles.

Use `DipperPDFTests/Support/PDFTestCase.swift` for generated fixtures and isolated temporary directories, or `XCTestCase` for pure values. Assert PDF semantics and relative sizes rather than exact serialized bytes or compressed sizes; exact bytes are appropriate for original preservation and direct saves. Mark workflow tests `@MainActor`, await operations and `waitForCompletion()`, and inject save destinations to avoid native dialogs. Add new test files to the test target's Compile Sources.

In restricted environments, Swift macro subprocesses may need the build-command-only override `OTHER_SWIFT_FLAGS='$(inherited) -Xfrontend -disable-sandbox'`. Do not persist it in project settings; it does not disable the application's sandbox.

Native dialogs, drag/drop, keyboard focus, VoiceOver, rendering, and window behavior require UI tests or a hands-on Mac pass. Unit tests do not validate the complete interface.
