"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export type NavigationPage = { slug: string; title: string; section: string };

export function DocsNavigation({ pages }: { pages: NavigationPage[] }) {
  const pathname = usePathname();
  function links(mobile = false) {
    return <nav aria-label={mobile ? "Mobile documentation" : "Documentation"}>
      <ul>{pages.map((page, index) => {
        const href = page.slug ? `/docs/${page.slug}` : "/docs";
        return <li key={href}>
          {page.section !== pages[index - 1]?.section && <p className="docs-nav-section">{page.section}</p>}
          <Link href={href} aria-current={pathname === href ? "page" : undefined}
            onClick={event => {
              const menu = event.currentTarget.closest("details");
              if (menu) menu.open = false;
            }}>{page.title}</Link>
        </li>;
      })}</ul>
    </nav>;
  }
  return <>
    <aside className="docs-sidebar">{links()}</aside>
    <details className="docs-mobile-nav">
      <summary>Documentation menu</summary>
      {links(true)}
    </details>
  </>;
}
