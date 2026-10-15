/** Marketing-site analytics event names. */
export const AnalyticsEvents = {
  CTA_CLICKED: "cta_clicked",
  NAVIGATION_LINK_CLICKED: "navigation_link_clicked",
} as const;

export type CtaLocation = "header" | "hero" | "pricing" | "get_app" | "search";
