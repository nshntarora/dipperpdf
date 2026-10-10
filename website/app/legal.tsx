import type { Metadata } from "next";
import type { ReactNode } from "react";

export const legalContactEmail = "support@arterylabs.com";

const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://dipperpdf.pages.dev";

export function legalMetadata(
  title: string,
  description: string,
  path: "/terms" | "/privacy" | "/cookies",
): Metadata {
  return {
    title,
    description,
    alternates: { canonical: path },
    openGraph: {
      type: "article",
      title,
      description,
      url: path,
      siteName: "DipperPDF",
    },
  };
}

function Brand() {
  return (
    <a className="brand" href="/" aria-label="DipperPDF home">
      <img src="/app-icon.png" width="42" height="42" alt="" />
      <span>
        Dipper<span className="brand-pdf">PDF</span>
        <span className="brand-dot">.</span>
      </span>
    </a>
  );
}

export function LegalPage({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <div className="site-shell legal-shell">
      <header className="site-header legal-header">
        <Brand />
        <a href="/">Back to home <span aria-hidden="true">←</span></a>
      </header>
      <main className="legal-page">
        <article>
          <p className="eyebrow">DIPPERPDF LEGAL</p>
          <h1>{title}</h1>
          <p className="legal-meta">
            Last updated: October 10, 2026 &nbsp;·&nbsp; Artery Ventures, LLP
          </p>
          <div className="legal-content">{children}</div>
        </article>
      </main>
      <LegalFooter />
    </div>
  );
}

export function LegalFooter() {
  return (
    <footer className="site-footer legal-footer">
      <span>© {new Date().getFullYear()} DipperPDF</span>
      <a href="/privacy">Privacy</a>
      <a href="/terms">Terms</a>
      <a href="/cookies">Cookies</a>
      <a href="/docs">Documentation</a>
    </footer>
  );
}

export function ContactDetails() {
  return (
    <address className="legal-contact">
      <strong>Artery Ventures, LLP</strong>
      <br />
      FO-02, 4th Floor, 28/A, 80 Feet Rd
      <br />
      Indiranagar, Bengaluru, Karnataka 560038
      <br />
      India
      <br />
      <br />
      Email: <a href={`mailto:${legalContactEmail}`}>{legalContactEmail}</a>
      <br />
      Website: <a href={siteUrl}>{siteUrl}</a>
    </address>
  );
}
