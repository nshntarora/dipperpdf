import type { MetadataRoute } from "next";
import { contentLastModified } from "../config/content-last-modified";
import { DOCS_PAGES, docsPath } from "../config/docs";
import { SEARCH_PAGES, searchPath } from "../config/search-pages";
import { siteUrlBase } from "./site-url";

export const dynamic = "force-static";

type SitemapEntry = MetadataRoute.Sitemap[number];

export default function sitemap(): MetadataRoute.Sitemap {
  const searchLastModified = contentLastModified(
    "config/search-pages.ts",
    "components/search/SearchPage.tsx",
  );

  return [
    {
      url: new URL("/", siteUrlBase).href,
      lastModified: contentLastModified("app/page.tsx"),
      changeFrequency: "weekly",
      priority: 1,
    },
    ...["/privacy", "/terms", "/cookies"].map<SitemapEntry>(path => ({
      url: new URL(path, siteUrlBase).href,
      lastModified: contentLastModified(`app${path}/page.tsx`, "app/legal.tsx"),
      changeFrequency: "yearly",
      priority: 0.3,
    })),
    ...DOCS_PAGES.map<SitemapEntry>(page => ({
      url: new URL(docsPath(page.slug), siteUrlBase).href,
      lastModified: contentLastModified(`content/help/${page.slug || "index"}.mdx`),
      changeFrequency: "monthly",
      priority: page.slug ? 0.7 : 0.8,
    })),
    ...SEARCH_PAGES.map<SitemapEntry>(page => ({
      url: new URL(searchPath(page), siteUrlBase).href,
      lastModified: searchLastModified,
      changeFrequency: "monthly",
      priority: page.kind === "tools" ? 0.8 : 0.7,
    })),
  ];
}
