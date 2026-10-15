import type { MetadataRoute } from "next";
import { siteUrlBase } from "./site-url";

export const dynamic = "force-static";

export default function robots(): MetadataRoute.Robots {
  return { rules: { userAgent: "*", allow: "/" }, sitemap: new URL("/sitemap.xml", siteUrlBase).href };
}
