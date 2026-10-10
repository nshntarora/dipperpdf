import type { Metadata } from "next";
import { AnalyticsPageView } from "./analytics/AnalyticsPageView";
import { AnalyticsProvider } from "./analytics/AnalyticsProvider";
import { siteUrlBase } from "./site-url";
import "./globals.css";

const title = "DipperPDF — Private PDF tools for your Mac";
const description =
  "Process sensitive contracts, pitch decks, and personal notes locally on your Mac. Fourteen offline PDF tools. No uploads, accounts, or in-app tracking. Read the code on GitHub.";

export const metadata: Metadata = {
  metadataBase: siteUrlBase,
  title,
  description,
  openGraph: {
    type: "website",
    siteName: "DipperPDF",
    title,
    description,
    url: "/",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title,
    description,
  },
  icons: { icon: "/app-icon.png", apple: "/app-icon.png" },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <head>
        <link
          rel="preload"
          href="/fonts/instrument-serif.ttf"
          as="font"
          type="font/ttf"
          crossOrigin="anonymous"
        />
        <link
          rel="preload"
          href="/fonts/hanken-grotesk.ttf"
          as="font"
          type="font/ttf"
          crossOrigin="anonymous"
        />
      </head>
      <body>
        <AnalyticsProvider>
          <AnalyticsPageView />
          {children}
        </AnalyticsProvider>
      </body>
    </html>
  );
}
