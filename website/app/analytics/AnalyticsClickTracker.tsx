"use client";

import { useEffect } from "react";
import { AnalyticsEvents } from "../analytics";
import { useAnalytics } from "./AnalyticsProvider";

function linkLabel(link: HTMLAnchorElement): string {
  return (link.getAttribute("aria-label") || link.textContent || "")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 100);
}

/** Captures only links deliberately marked as CTAs and links in semantic navs. */
export function AnalyticsClickTracker() {
  const analytics = useAnalytics();

  useEffect(() => {
    function trackClick(event: MouseEvent) {
      if (!(event.target instanceof Element)) return;

      const link = event.target.closest<HTMLAnchorElement>("a[href]");
      if (!link) return;

      const cta = link.closest<HTMLElement>("[data-analytics-cta]");
      if (cta) {
        analytics.capture(AnalyticsEvents.CTA_CLICKED, {
          cta_name: cta.dataset.analyticsCta,
          location: cta.dataset.analyticsLocation,
          destination: link.href,
        });
        return;
      }

      const navigation = link.closest<HTMLElement>(
        "[data-analytics-navigation], nav[aria-label]",
      );
      if (!navigation) return;

      analytics.capture(AnalyticsEvents.NAVIGATION_LINK_CLICKED, {
        location:
          navigation.dataset.analyticsNavigation ||
          navigation.getAttribute("aria-label"),
        label: linkLabel(link),
        destination: link.href,
      });
    }

    document.addEventListener("click", trackClick);
    return () => document.removeEventListener("click", trackClick);
  }, [analytics]);

  return null;
}
