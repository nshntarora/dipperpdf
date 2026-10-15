import type { Metadata } from "next";
import Link from "next/link";
import { TOOL_PAGES, DOWNLOAD_URL, REPOSITORY_URL, searchPath, type SearchPage } from "../../config/search-pages";
import { siteUrlBase } from "../../app/site-url";
import "../../app/search.css";

export function searchPageMetadata(page: SearchPage): Metadata {
  const path = searchPath(page);
  return {
    title: page.title,
    description: page.description,
    alternates: { canonical: path },
    robots: { index: true, follow: true },
    openGraph: {
      title: page.title, description: page.description, type: "article", url: path,
      images: [{ url: "/opengraph-image", width: 1200, height: 630, alt: "DipperPDF — private PDF tools for Mac" }],
    },
    twitter: { card: "summary_large_image", title: page.title, description: page.description, images: ["/opengraph-image"] },
  };
}

function jsonLd(value: unknown) {
  return JSON.stringify(value).replace(/</g, "\\u003c");
}

export function SearchContentPage({ page }: { page: SearchPage }) {
  const related = TOOL_PAGES.find(tool => tool.slug === page.related)!;
  const path = searchPath(page);
  const breadcrumbs = {
    "@context": "https://schema.org", "@type": "BreadcrumbList",
    itemListElement: [
      { "@type": "ListItem", position: 1, name: "DipperPDF", item: new URL("/", siteUrlBase).href },
      { "@type": "ListItem", position: 2, name: page.h1, item: new URL(path, siteUrlBase).href },
    ],
  };
  const faq = page.faq && {
    "@context": "https://schema.org", "@type": "FAQPage",
    mainEntity: page.faq.map(({ q, a }) => ({
      "@type": "Question", name: q,
      acceptedAnswer: { "@type": "Answer", text: a },
    })),
  };
  return <>
    <a className="skip-link" href="#search-main">Skip to content</a>
    <div className="site-shell">
      <header className="site-header search-header">
        <Link className="brand" href="/" aria-label="DipperPDF home">
          <img src="/app-icon.png" width="42" height="42" alt="" />
          <span>Dipper<span className="brand-pdf">PDF</span><span className="brand-dot">.</span></span>
        </Link>
        <nav aria-label="Main navigation">
          <Link href="/#tools">The toolkit</Link>
          <Link href="/guides/offline-pdf-tools-mac">Offline guide</Link>
          <Link href="/docs">Docs</Link>
        </nav>
      </header>
      <main id="search-main" className="search-main" tabIndex={-1}>
        <nav className="search-breadcrumbs" aria-label="Breadcrumb">
          <Link href="/">DipperPDF</Link><span aria-hidden="true"> / </span><span aria-current="page">{page.h1}</span>
        </nav>
        <article className="search-content">
          <h1>{page.h1}</h1>
          <p className="search-intro">{page.intro}</p>
          {page.table && <section aria-labelledby="comparison-heading">
            <h2 id="comparison-heading">Compare the workflow</h2>
            <div className="search-table-scroll" role="region" aria-label="Workflow comparison table" tabIndex={0}>
              <table>
                <caption>DipperPDF and {page.table.other}: scope and tradeoffs</caption>
                <thead><tr><th scope="col">Decision</th><th scope="col">DipperPDF</th><th scope="col">{page.table.other}</th></tr></thead>
                <tbody>{page.table.rows.map(([label, local, other]) => <tr key={label}>
                  <th scope="row">{label}</th><td>{local}</td><td>{other}</td>
                </tr>)}</tbody>
              </table>
            </div>
            <p className="search-source">Competitor facts checked October 11, 2026: <a href={page.table.source.url}>{page.table.source.label}</a>. Compare the named workflow; other products and editions may differ.</p>
          </section>}
          {page.sections.map(section => <section key={section.heading}>
            <h2>{section.heading}</h2>
            {section.paragraphs.map(paragraph => <p key={paragraph}>{paragraph}</p>)}
            {section.steps && <ol>{section.steps.map(step => <li key={step}>{step}</li>)}</ol>}
            {section.links && <ul>{section.links.map(link => <li key={link.href}><Link href={link.href}>{link.label}</Link></li>)}</ul>}
            {section.sources && <p className="search-source">Sources: {section.sources.map((source, index) => <span key={source.url}>
              {index > 0 && "; "}<a href={source.url}>{source.label}</a>
            </span>)}</p>}
          </section>)}
          {page.faq && <section aria-labelledby="faq-heading">
            <h2 id="faq-heading">FAQ</h2>
            {page.faq.map(({q, a}) => <div key={q}><h3>{q}</h3><p>{a}</p></div>)}
          </section>}
          <section className="search-next" aria-labelledby="next-heading">
            <h2 id="next-heading">Choose your next step</h2>
            <p><Link href={`/tools/${related.slug}`}>{related.name}</Link> is a related operation. For the wider workflow, read <Link href="/guides/edit-pdf-without-uploading">Edit a PDF without uploading</Link> or the <Link href="/guides/offline-pdf-tools-mac">offline PDF tools for Mac guide</Link>.</p>
            <p><a href={REPOSITORY_URL}>Read DipperPDF’s source on GitHub</a> and check the specific tool’s behavior before relying on the result.</p>
            <a className="button button-dark" href={DOWNLOAD_URL}>Download for Mac <span aria-hidden="true">↓</span></a>
          </section>
        </article>
      </main>
      <footer className="search-footer">
        <Link href="/">DipperPDF home</Link><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><Link href="/cookies">Cookies</Link>
      </footer>
    </div>
    <script type="application/ld+json" dangerouslySetInnerHTML={{__html: jsonLd(breadcrumbs)}} />
    {faq && <script type="application/ld+json" dangerouslySetInnerHTML={{__html: jsonLd(faq)}} />}
  </>;
}
