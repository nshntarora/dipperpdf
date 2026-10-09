#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
mkdir -p .build
xcrun swiftc -swift-version 6 -parse-as-library -module-cache-path .build/ModuleCache \
  DipperPDF/Core/Models.swift DipperPDF/Core/FilePanels.swift DipperPDF/Core/ToolModel.swift \
  DipperPDF/Tools/Compress/CompressModel.swift DipperPDF/Tools/Merge/MergeModel.swift \
  DipperPDF/Tools/Rotate/RotateModel.swift DipperPDF/PDFEngine/PDFEngine.swift Tests/EngineChecks.swift \
  -o .build/engine-checks
.build/engine-checks
