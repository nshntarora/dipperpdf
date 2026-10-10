import Link from "next/link";
import { DOCS_PAGES } from "../../config/docs";
import { DocsNavigation } from "../../components/docs/DocsNavigation";
import { DownloadButton } from "../download-button";
import "./docs.css";

export default function DocsLayout({ children }: { children: React.ReactNode }) {
  return <>
    <a className="skip-link" href="#docs-main">Skip to content</a>
    <div className="site-shell">
      <header className="site-header docs-header">
        <Link className="brand" href="/" aria-label="DipperPDF home">
          <img src="/app-icon.png" width="42" height="42" alt="" />
          <span>Dipper<span className="brand-pdf">PDF</span><span className="brand-dot">.</span></span>
        </Link>
        <nav aria-label="Main navigation"><Link href="/docs" aria-current="true">Docs</Link><a href="https://github.com/nshntarora/dipperpdf">GitHub ↗</a></nav>
        <DownloadButton className="header-cta" href="https://github.com/nshntarora/dipperpdf/releases/latest/download/DipperPDF.dmg" location="header">Download Mac app <span aria-hidden="true">↓</span></DownloadButton>
      </header>
      <div className="docs-layout">
        <DocsNavigation pages={DOCS_PAGES.map(({slug, title, section}) => ({slug, title, section}))} />
        <main id="docs-main" className="docs-main" tabIndex={-1}>{children}</main>
      </div>
      <footer className="docs-footer">
        <Link href="/">DipperPDF</Link>
        <span>Your PDFs stay on your Mac.</span>
        <Link href="/docs/privacy-and-data">Privacy &amp; data</Link>
        <Link href="/privacy">Privacy</Link>
        <Link href="/terms">Terms</Link>
        <Link href="/cookies">Cookies</Link>
      </footer>
    </div>
  </>;
}
