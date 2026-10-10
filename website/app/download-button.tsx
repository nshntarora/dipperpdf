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
      className={`${className} download-button`}
      href={href}
      onClick={() => {
        analytics.capture(AnalyticsEvents.DOWNLOAD_MAC_APP_CLICK, {
          href,
          location,
          method: "click",
        });
      }}
    >
      <svg
        aria-hidden="true"
        className="download-button-icon"
        fill="currentColor"
        viewBox="0 0 24 24"
      >
        <path d="M17.05 12.536c-.02-2.218 1.81-3.305 1.893-3.355-1.02-1.49-2.604-1.694-3.17-1.71-1.335-.14-2.63.8-3.31.8-.693 0-1.74-.786-2.868-.763-1.467.022-2.838.872-3.59 2.18-1.55 2.684-.394 6.63 1.09 8.8.743 1.063 1.61 2.248 2.744 2.206 1.11-.046 1.525-.708 2.865-.708 1.326 0 1.716.708 2.875.681 1.19-.019 1.94-1.067 2.657-2.14.859-1.219 1.204-2.42 1.218-2.48-.028-.01-2.42-.924-2.444-3.531ZM14.94 6.103c.598-.748 1.007-1.766.894-2.797-.866.038-1.949.6-2.573 1.33-.552.642-1.044 1.7-.917 2.692.974.074 1.98-.493 2.596-1.225Z" />
      </svg>
      <span className="download-button-content">{children}</span>
    </a>
  );
}
