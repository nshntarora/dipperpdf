import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DipperPDF — PDFs stay on your Mac",
  description:
    "Less fuss. More done. Fourteen focused PDF tools for macOS. Compress, merge, split, and more, with no uploads and your originals untouched.",
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
      <body>{children}</body>
    </html>
  );
}
