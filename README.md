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

The website is a static export. GitHub Actions deploys `website/out` to the `dipperpdf` Cloudflare Pages project after successful pushes to `main`. Configure `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets before enabling deployments; set `NEXT_PUBLIC_SITE_URL` as a repository variable when the production domain is known.
