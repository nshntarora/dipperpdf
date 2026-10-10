# DipperPDF

DipperPDF is an offline macOS utility for everyday PDF work, with a companion website deployed to Cloudflare Pages.

## Repository layout

- [`macos/`](macos/) — native SwiftUI macOS app, Xcode project, tests, and scripts.
- [`website/`](website/) — static Next.js marketing site for Cloudflare Pages.

## Development

### macOS app

Run native build and test commands from `macos/`. See [macos/README.md](macos/README.md) for the app's tool list and setup.

### Website

Use pnpm from the repository root:

```sh
pnpm install
pnpm dev:website
pnpm build:website
```

### Documentation

The website serves the app documentation at `/docs`, using the same MDX and
registry setup as GuidedReview. Content lives in `website/content/help/`;
`website/config/docs.ts` registers each page's title, description, section, and
literal MDX import. The registry drives static routes, navigation, index cards,
metadata, and previous/next links.

To add a guide, create an MDX file with one H1 and an exported `toc` array. Its
entries must match the H2 heading IDs generated in `website/mdx-components.tsx`.
Add a registry entry alongside the other pages in its section, and link related
guides using `/docs/<slug>`. Keep instructions aligned with the app's actual
controls and document tool limits in the guide.

Run `pnpm typecheck:website` and `pnpm build:website` from the repository root.
The build exports every registered page to `website/out` for Cloudflare Pages;
documentation needs no server or runtime content fetching.

The website is a static export. GitHub Actions deploys `website/out` and the first-party PostHog proxy in `website/functions/` to the `dipperpdf` Cloudflare Pages project after successful pushes to `main`. Configure `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets before enabling deployments; set `NEXT_PUBLIC_SITE_URL` as a repository variable when the production domain is known. Analytics is disabled by default; enable it with the `NEXT_PUBLIC_ANALYTICS_ENABLED=true` repository variable and a `NEXT_PUBLIC_ANALYTICS_KEY` repository secret. `NEXT_PUBLIC_ANALYTICS_PROXY_PATH` defaults to `/i`.

## Release the Mac app

From `macos/`, run `./scripts/release.sh 1.0.0` after committing and pushing the
source. This builds for Apple silicon and Intel, packages a DMG, and publishes
GitHub release `v1.0.0` with the app version and a SHA-256 checksum. See
[macOS distribution setup](macos/README.md#distribution) for signing and local builds.

All website download buttons point directly to
`https://github.com/nshntarora/dipperpdf/releases/latest/download/DipperPDF.dmg`.
The first release must be published before downloads work. Future releases keep
the same asset name, so the website needs no rebuild when a new app version ships.
