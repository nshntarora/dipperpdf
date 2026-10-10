import Link from "next/link";
import type { Metadata } from "next";
import { DOCS_PAGES, docsPath, type DocsPage } from "../../config/docs";

export function docsPageMetadata(page: DocsPage): Metadata {
  const title = `${page.title} · DipperPDF Docs`;
  return { title, description: page.description, alternates: { canonical: docsPath(page.slug) },
    openGraph: { title, description: page.description, type: "article", url: docsPath(page.slug) },
    twitter: { title, description: page.description, card: "summary_large_image" } };
}

export async function DocsContentPage({ page }: { page: DocsPage }) {
  const { default: Content, toc } = await page.load();
  const index = DOCS_PAGES.indexOf(page);
  const previous = DOCS_PAGES[index - 1];
  const next = DOCS_PAGES[index + 1];
  return <>
    <nav className="docs-breadcrumbs" aria-label="Breadcrumb">
      <Link href="/docs">Docs</Link><span aria-hidden="true"> / </span>
      <span>{page.section}</span><span aria-hidden="true"> / </span><span aria-current="page">{page.title}</span>
    </nav>
    {toc?.length > 0 && <nav className="docs-toc" aria-label="On this page">
      <p>On this page</p><ul>{toc.map(entry => <li key={entry.id}><a href={`#${entry.id}`}>{entry.label}</a></li>)}</ul>
    </nav>}
    <article className="docs-content"><Content /></article>
    {page.slug === "" && <div className="docs-index">{Array.from(new Set(DOCS_PAGES.map(entry => entry.section))).map(section =>
      <section key={section}><h2>{section}</h2><ul>{DOCS_PAGES.filter(entry => entry.section === section && entry.slug).map(entry =>
        <li key={entry.slug}><Link href={docsPath(entry.slug)}><strong>{entry.title} →</strong><span>{entry.description}</span></Link></li>
      )}</ul></section>
    )}</div>}
    <nav className="docs-pager" aria-label="Previous and next pages">
      {previous ? <Link href={docsPath(previous.slug)}><span>← Previous</span>{previous.title}</Link> : <div />}
      {next && <Link href={docsPath(next.slug)}><span>Next →</span>{next.title}</Link>}
    </nav>
  </>;
}
