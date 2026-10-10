# DipperPDF website

The DipperPDF website is a static Next.js marketing and documentation site for the native macOS app. It provides the product page, download links, legal pages, and help at `/docs`. The site never accepts or processes PDF files.

It is intentionally compatible with Cloudflare Pages: `next.config.ts` preserves `output: "export"`, images are unoptimized for static export, and the site uses no server-only Next.js runtime features.

## Requirements

- Node.js 22 or later
- pnpm 11 or later

Run all pnpm commands from the repository root, where the workspace configuration and lockfile live.

## Local development

```sh
# From the repository root
pnpm install
pnpm dev:website
```

The development server runs from `website/`. Check types and create the static production output with:

```sh
pnpm typecheck:website
pnpm build:website
```

The build writes the deployable site to `website/out/`, which is ignored by Git. To serve a production build locally, run `pnpm --dir website start` after building.

## Architecture

```text
website/
├── app/                    App Router routes, page components, styles, metadata, and analytics
│   ├── docs/               Documentation index, dynamic MDX routes, and docs layout
│   ├── analytics/          Optional PostHog browser integration
│   └── opengraph-image.tsx Build-time generated social image
├── components/docs/        Documentation navigation and MDX page wrapper
├── content/help/           MDX help articles
├── config/docs.ts          Typed registry driving docs routes, navigation, metadata, and links
├── functions/i/            Cloudflare Pages Function proxy for optional PostHog traffic
├── public/                 Fonts, app icon, and static response headers
├── mdx-components.tsx      Shared MDX element rendering
├── next.config.ts          MDX setup and static-export configuration
└── wrangler.jsonc          Cloudflare Pages project and output configuration
```

The marketing homepage lives in `app/page.tsx`. Legal routes live under `app/privacy`, `app/terms`, and `app/cookies`; shared legal copy is in `app/legal.tsx`. `app/site-url.ts` normalizes `NEXT_PUBLIC_SITE_URL` for metadata and the generated social image.

## Documentation content

Help content lives in `content/help/` and is rendered through MDX. The docs registry in `config/docs.ts` is the single source of truth for static routes, navigation, index cards, page metadata, and previous/next links.

To add a guide:

1. Create `content/help/<slug>.mdx` with one H1 and an exported `toc` array.
2. Ensure each `toc` entry matches an H2 heading ID produced by `mdx-components.tsx`.
3. Add a literal MDX import and metadata entry to `DOCS_PAGES` in `config/docs.ts`, keeping it next to related pages.
4. Link related pages using `/docs/<slug>`.
5. Run `pnpm typecheck:website` and `pnpm build:website`.

Keep the instructions consistent with the app’s actual controls and place tool limitations in the appropriate guide.

## Analytics and privacy

Analytics is optional and applies only to the website. It does not enable analytics in the native app or send PDFs anywhere.

| Variable                           | Purpose                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------- |
| `NEXT_PUBLIC_SITE_URL`             | Canonical production site URL; falls back to `https://dipperpdf.pages.dev`. |
| `NEXT_PUBLIC_ANALYTICS_ENABLED`    | Set to `true` to enable PostHog browser analytics.                          |
| `NEXT_PUBLIC_ANALYTICS_KEY`        | PostHog project key, required when analytics is enabled.                    |
| `NEXT_PUBLIC_ANALYTICS_PROXY_PATH` | Optional proxy path; defaults to `/i`.                                      |

`functions/i/[[path]].ts` is a first-party Cloudflare Pages Function that proxies the PostHog SDK and event requests. Development rewrites in `next.config.ts` mirror that behavior because static exports cannot include Next.js rewrites in production.

## Deployment

GitHub Actions builds and deploys the site after successful pushes to `main`; pull requests run the install, typecheck, and build checks only. The workflow is in `.github/workflows/website.yml`.

Configure these repository values before enabling production deployment:

| GitHub configuration               | Used for                                    |
| ---------------------------------- | ------------------------------------------- |
| Secret `CLOUDFLARE_API_TOKEN`      | Cloudflare Pages deployment authentication. |
| Secret `CLOUDFLARE_ACCOUNT_ID`     | Target Cloudflare account.                  |
| Variable `NEXT_PUBLIC_SITE_URL`    | Production URL during static build.         |
| Secret `NEXT_PUBLIC_ANALYTICS_KEY` | Optional PostHog key supplied to CI builds. |

The workflow currently enables analytics for its builds. For a manual Cloudflare deploy, after configuring Wrangler authentication, run:

```sh
pnpm deploy:website
```

To create a Cloudflare preview branch deployment instead:

```sh
pnpm --dir website preview:cf
```

Both commands build first and deploy `website/out` to the `dipperpdf` Cloudflare Pages project.

## Verification

Before opening a website change for review, run:

```sh
pnpm typecheck:website
pnpm build:website
```

Also manually inspect changed marketing pages and documentation routes in a browser, including their small-screen layout and links. Do not commit `website/out/`, `website/.next/`, `website/node_modules/`, or `website/tsconfig.tsbuildinfo`.
