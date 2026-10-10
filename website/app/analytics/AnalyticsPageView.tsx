"use client";

import { Suspense, useEffect } from "react";
import { usePathname, useSearchParams } from "next/navigation";
import { useAnalytics } from "./AnalyticsProvider";

function AnalyticsPageViewInner() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const analytics = useAnalytics();

  useEffect(() => {
    const search = searchParams.toString();
    const url = search
      ? `${window.location.origin}${pathname}?${search}`
      : window.location.href;

    analytics.capturePageview(url);
  }, [analytics, pathname, searchParams]);

  return null;
}

export function AnalyticsPageView() {
  return (
    <Suspense fallback={null}>
      <AnalyticsPageViewInner />
    </Suspense>
  );
}
