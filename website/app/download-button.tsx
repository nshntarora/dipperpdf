"use client";

import type { ReactNode } from "react";
import { AnalyticsEvents, type CtaLocation } from "./analytics";
import { useAnalytics } from "./analytics/AnalyticsProvider";

type DownloadButtonProps = {
  className: string;
  href: string;
  location: CtaLocation;
  children: ReactNode;
};

export function DownloadButton({
  className,
  href,
  location,
  children,
}: DownloadButtonProps) {
  const analytics = useAnalytics();

  return (
    <a
      className={className}
      href={href}
      onClick={() => {
        analytics.capture(AnalyticsEvents.DOWNLOAD_MAC_APP_CLICK, {
          href,
          location,
          method: "click",
        });
      }}
    >
      {children}
    </a>
  );
}
