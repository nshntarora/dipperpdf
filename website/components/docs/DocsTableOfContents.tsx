import type { TocEntry } from "../../config/docs";

export function DocsTableOfContents({ entries }: { entries: TocEntry[] }) {
  return <nav className="docs-toc" aria-label="On this page">
    <p>On this page</p>
    <ul>{entries.map(entry => <li key={entry.id}><a href={`#${entry.id}`}>{entry.label}</a></li>)}</ul>
  </nav>;
}
