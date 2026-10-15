import type { MetadataRoute } from "next";
import { DOCS_PAGES, docsPath } from "../config/docs";
import { SEARCH_PAGES, searchPath } from "../config/search-pages";
import { siteUrlBase } from "./site-url";

export const dynamic = "force-static";

export default function sitemap(): MetadataRoute.Sitemap {
  const paths = ["/", "/privacy", "/terms", "/cookies", ...DOCS_PAGES.map(page => docsPath(page.slug)), ...SEARCH_PAGES.map(searchPath)];
  return paths.map(path => ({ url: new URL(path, siteUrlBase).href }));
}
