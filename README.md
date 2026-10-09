# DipperPDF

A native, offline macOS PDF utility built with Swift 6, SwiftUI, PDFKit, and Quartz. Includes **Compress PDF**, **Merge PDFs**, and **Rotate PDF pages**. Requires macOS 14 or later and Xcode 16 or later (validated with Xcode 27).

## Run

1. Open `DipperPDF.xcodeproj` in Xcode.
2. Select the **DipperPDF** scheme and **My Mac**.
3. Press **Command+R**.

The project uses **Sign to Run Locally** (ad hoc signing), so no developer account is required for local use. For distribution, select your own bundle identifier and signing team, then configure Developer ID signing and notarization.

Command-line build:

```sh
xcodebuild -project DipperPDF.xcodeproj -scheme DipperPDF \
  -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/DipperPDF.app
```

## Use

- **Compress:** Choose or drop one PDF, select Light/Balanced/Strong, compress, review the size comparison, and save a new file. Changing the level clears the previous result. If compression would enlarge the PDF, DipperPDF offers the original bytes instead.
- **Merge:** Add multiple PDFs, drag rows into the desired order, and merge. The row context menu also provides Move Up, Move Down, and Remove. Add more files with the drop area. Save the merged result separately.
- **Rotate:** Choose a PDF, click page thumbnails, and rotate selected pages. Command-click toggles selection; Shift-click selects a range; Command+Shift-click adds a range. Command+A selects all pages. Rotation appears immediately; Save Rotated PDF writes the changes to a new file.

Shortcuts: **Command+O** opens PDFs, **Command+S** saves the current result, **Command+Return** starts compress/merge, **Command+Shift+L/R** rotates left/right, and **Escape** cancels active processing. Standard window and sidebar commands remain available.

## Architecture

```text
DipperPDF/
  App/                 App entry, native navigation, tool catalog
  Core/                Immutable file/result models, panels, shared job lifecycle
  PDFEngine/           Actor-isolated reading, validation, PDF operations, saving
  Components/          File drop/picker, file summary, progress, privacy message
  Tools/
    Compress/          Compression workflow model and view
    Merge/             Ordered input workflow model and view
    Rotate/            Selection/rotation workflow model and thumbnail view
  Assets.xcassets/      Native app icon
DipperPDFTests/         XCTest unit and PDF integration tests
Tests/                 Legacy standalone smoke checks
scripts/               Local build and test commands
```

The interface uses a dipper-inspired brown and warm-white palette, with coordinated light and dark appearances. `Components/DipperBrand.swift` defines the shared colors and vector bird logo, including its white bib. `DipperAppIcon` supplies both the macOS app icon and the sidebar and home screen artwork, with a frosted glass tile, translucent bronze plumage, feather details, beveled highlights, and soft shadows. Its glass effects render directly into the image without depending on a window backdrop. To regenerate all macOS icon sizes after changing the artwork:

```sh
xcrun swiftc -swift-version 6 -parse-as-library -module-cache-path .build/ModuleCache \
  DipperPDF/Components/DipperBrand.swift scripts/generate-icons.swift -o .build/generate-icons
.build/generate-icons
```

`PDFEngine.swift` owns every PDF operation. Its actor keeps PDFKit documents away from the main UI thread and never sends mutable PDFKit objects between actors. The public boundary consists of immutable `PDFFile`, `PDFResult`, byte data, and progress callbacks. Each operation checks cancellation at useful boundaries. `ToolModel` owns the shared task, busy/progress state, errors, import, and save lifecycle; individual tool models own their workflow state. Views render state and issue model commands.

Compression uses Apple's native Quartz filter with JPEG image recompression and downsampling: Light **250 dpi / 85% quality**, Balanced **150 dpi / 65%**, Strong **96 dpi / 40%**. It does not rasterize entire pages. Merge copies PDFKit pages in the chosen order. Rotation changes each selected page's existing rotation metadata rather than redrawing content.

Files are read under temporary security-scoped access and retained as in-memory snapshots. Save uses a native panel, checks that the destination is not any source (including symbolic/hard-link aliases), and writes atomically. Input files are never changed by a tool. The app sandbox grants only user-selected file read/write access; there are no network entitlements, dependencies, analytics, accounts, or external services. Core tools need no internet connection.

## Add a tool

1. Add a folder under `Tools/` with a workflow model and SwiftUI view. Inherit `ToolModel` when its file/job lifecycle fits.
2. Add the PDF operation to `PDFEngine`, or a focused extension in `PDFEngine/`. Exchange immutable inputs/results and keep PDFKit objects inside the actor. Accept progress callbacks and check cancellation between processing units.
3. Register the title, SF Symbol, description, and destination in `App/ToolCatalog.swift`.
4. Add new Swift files to the DipperPDF target in Xcode. Add relevant XCTest cases in `DipperPDFTests/` and include new test files in the DipperPDFTests target.

A future batch coordinator can call the same engine operations and aggregate their progress; no batch feature is included in v1.

## Testing

The shared **DipperPDF** scheme includes a macOS **DipperPDFTests** XCTest target. In Xcode, choose **My Mac** and press **Command+U**. No packages, accounts, network access, or external services are needed. Debug builds enable `@testable import DipperPDF`; tests import the actual app module rather than compiling a separate copy of its sources. The bundle is hosted by the app so SwiftUI/AppKit behavior runs in the macOS application environment with the app sandbox intact.

Run the same suite from Terminal with full Xcode 16 or later selected:

```sh
./scripts/test.sh
```

The script enables code coverage and writes a uniquely named `.xcresult` bundle under `build/TestResults/`. Open the bundle in Xcode to inspect failures, durations, and coverage. To choose a result path (it must not already exist):

```sh
DIPPER_TEST_RESULTS=build/TestResults/local.xcresult ./scripts/test.sh
xcrun xccov view --report build/TestResults/local.xcresult
```

Additional `xcodebuild` arguments pass through the script, including focused runs:

```sh
./scripts/test.sh -only-testing:DipperPDFTests/RotateModelTests
```

Coverage is collected for the app target. Treat it as a way to find untested decisions; it is not a guarantee of correctness or a requirement to test every declarative view. The suite covers:

- **PDF engine integration:** loading and byte snapshots; malformed, empty, missing and encrypted files; all compression levels, size savings and searchable text; merge ordering, page geometry, rotation and annotations; selected page rotation; PNG thumbnails; progress; cancellation; atomic save results and original/symlink/hard-link overwrite protection.
- **Workflow units:** compress result/savings/error state; merge drag order, nudge and removal; macOS Command/Shift selection, reversible rotation, input reset and rotated save; shared job exclusion, retry, cancellation, imports, save confirmation and stale result invalidation.
- **App/domain units:** tool registration, file identities/display values, compression presets and error descriptions.

`DipperPDFTests/Support/PDFTestCase.swift` creates a unique temporary directory and a fresh engine for each test, then removes fixtures during teardown. Fixtures use Core Graphics and Core Text; deterministic raster noise exercises compression without storing large binary PDFs. Assert document semantics and relative sizes instead of PDF byte snapshots or exact compressed sizes, which can vary with macOS/PDFKit versions. Exact byte comparisons are appropriate for source preservation and direct saves.

Workflow tests run on `@MainActor`. Async tests await operations and `waitForCompletion()` rather than sleeping or polling. Save workflows inject a destination closure through the model initializer; normal app behavior still uses `NSSavePanel`. Tests never display a dialog. The scheme disables parallel execution of the test bundle because AppKit/PDFKit and the hosted application share process state, and it limits individual test duration to prevent hanging jobs.

To add a test, place a focused `*Tests.swift` file in `DipperPDFTests/` and add it to the **DipperPDFTests** target's Compile Sources in Xcode. Use `PDFTestCase` for fixture-backed tests, `XCTestCase` for pure values, and `@MainActor` on workflow methods. For example, `CompressModelTests.testCompressionProducesResultProgressAndSavings` arranges a generated file, starts the workflow, awaits completion, and asserts the observable result and progress. Test behavior, errors, and boundaries; avoid assertions about private implementation or arbitrary timing. Tests use `XCTUnwrap` so bad fixtures fail with a useful location instead of crashing.

`.github/workflows/tests.yml` runs this suite on a macOS runner for pushes and pull requests, prints coverage, and uploads the result bundle even when tests fail. The workflow becomes active when the project is placed in a GitHub repository.

The older standalone smoke checks remain available:

```sh
./scripts/check-engine.sh
```

In a restricted agent environment, Swift macro subprocesses may require the **build-command-only** override `OTHER_SWIFT_FLAGS='$(inherited) -Xfrontend -disable-sandbox'`. This is not a project setting and does not disable the application's sandbox.

Unit tests cover the app's testable logic and real PDF operations. Native dialogs, drag/drop delivery, shortcuts/focus, rendering, accessibility, and window behavior require UI tests or a hands-on Mac pass; they are not validated by constructing SwiftUI views in unit tests.

## Known limitations

- Image compression is lossy, particularly Strong. Savings depend on the input; text-only or already compressed PDFs may not shrink. Review output before sharing.
- Encrypted PDFs are rejected, including ones that open without a password. Unlock/export them in Preview first. Password entry is outside v1.
- Native PDF serialization/filtering can alter document-level bookmarks, interactive forms, links, metadata, tags, and other advanced PDF features. Existing digital signatures are not preserved as valid signatures. Use originals for archival or signed documents.
- Quartz compression and PDFKit serialization are synchronous native calls on the engine actor. The UI remains responsive, but cancellation takes effect when those calls finish. Compression progress reports stages rather than exact per-page work.
- Input/output bytes and thumbnails are held in memory. Very large PDFs may require substantial memory; streaming and batch optimization are future work.
- Drag/drop, dialogs, keyboard focus, VoiceOver, and visual appearance still need a hands-on UI pass on a Mac. Automated checks cover the engine and workflow models, not the complete UI.
