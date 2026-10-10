# DipperPDF monorepo guidance

This repository contains two independently deployable projects:

- `macos/` contains the native DipperPDF app. Follow `macos/AGENTS.md` for its architecture, Xcode membership, and test rules.
- `website/` contains the static Next.js marketing site. Keep it compatible with Cloudflare Pages: no server-only Next.js features, and preserve `output: "export"` in its config.

Run native app commands from `macos/` and Node/pnpm commands from the repository root. Keep macOS build outputs and website dependencies/build outputs out of source control.
