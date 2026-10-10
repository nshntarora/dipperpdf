import type { NextConfig } from "next";
import createMDX from "@next/mdx";

// Development equivalent of the production Pages Function at /i/*.
// Static exports cannot include Next rewrites, so only enable these in dev.
const posthogDevRewrites =
  process.env.NODE_ENV === "development"
    ? {
        async rewrites() {
          return [
            {
              source: "/i/static/:path*",
              destination: "https://us-assets.i.posthog.com/static/:path*",
            },
            {
              source: "/i/array/:path*",
              destination: "https://us-assets.i.posthog.com/array/:path*",
            },
            {
              source: "/i/:path*",
              destination: "https://us.i.posthog.com/:path*",
            },
          ];
        },
      }
    : {};

const nextConfig: NextConfig = {
  pageExtensions: ["js", "jsx", "md", "mdx", "ts", "tsx"],
  experimental: { mdxRs: { mdxType: "gfm" } },
  output: "export",
  images: { unoptimized: true },
  ...posthogDevRewrites,
};

export default createMDX({})(nextConfig);
