import type { ComponentType } from "react";

export type TocEntry = { id: string; label: string; level: 2 | 3 };
export type DocsPage = {
  slug: string;
  title: string;
  section: string;
  description: string;
  load: () => Promise<{ default: ComponentType; toc: TocEntry[] }>;
};

// Keep sections adjacent. This registry drives routes, navigation, index cards,
// metadata, and previous/next links. Each loader must use a literal import path.
export const DOCS_PAGES: DocsPage[] = [
  {
    slug: "",
    title: "Documentation",
    section: "Start here",
    description: "Install DipperPDF and learn to use all fourteen offline PDF tools.",
    load: () => import("../content/help/index.mdx"),
  },
  {
    slug: "install",
    title: "Install",
    section: "Start here",
    description: "Download and install DipperPDF on a Mac running macOS 14 or later.",
    load: () => import("../content/help/install.mdx"),
  },
  {
    slug: "getting-started",
    title: "Getting started",
    section: "Start here",
    description: "Choose a tool, open a PDF, and save your first result as a separate file.",
    load: () => import("../content/help/getting-started.mdx"),
  },
  {
    slug: "merge-pdfs",
    title: "Merge PDFs",
    section: "Organize",
    description: "Combine multiple PDFs into one document in the order you choose.",
    load: () => import("../content/help/merge-pdfs.mdx"),
  },
  {
    slug: "split-pdf",
    title: "Split PDF",
    section: "Organize",
    description: "Divide a PDF into smaller files with a fixed number of pages per file.",
    load: () => import("../content/help/split-pdf.mdx"),
  },
  {
    slug: "extract-pages",
    title: "Extract Pages",
    section: "Organize",
    description: "Export selected pages into one new PDF in their original order.",
    load: () => import("../content/help/extract-pages.mdx"),
  },
  {
    slug: "remove-pages",
    title: "Remove Pages",
    section: "Organize",
    description: "Save a new PDF with selected pages removed and the remaining order preserved.",
    load: () => import("../content/help/remove-pages.mdx"),
  },
  {
    slug: "rotate-pdf",
    title: "Rotate PDF",
    section: "Organize",
    description: "Turn selected pages left or right in 90-degree steps.",
    load: () => import("../content/help/rotate-pdf.mdx"),
  },
  {
    slug: "reverse-pages",
    title: "Reverse Pages",
    section: "Organize",
    description: "Save a PDF with its pages ordered from last to first.",
    load: () => import("../content/help/reverse-pages.mdx"),
  },
  {
    slug: "compress-pdf",
    title: "Compress PDF",
    section: "Refine",
    description: "Reduce image-heavy PDF sizes with Light, Balanced, or Strong compression.",
    load: () => import("../content/help/compress-pdf.mdx"),
  },
  {
    slug: "crop-pdf",
    title: "Crop PDF",
    section: "Refine",
    description: "Trim visible page margins with point-based controls and a preview.",
    load: () => import("../content/help/crop-pdf.mdx"),
  },
  {
    slug: "add-page-numbers",
    title: "Add Page Numbers",
    section: "Refine",
    description: "Add visible numbers to a page range and preview their placement.",
    load: () => import("../content/help/add-page-numbers.mdx"),
  },
  {
    slug: "add-watermark",
    title: "Add Watermark",
    section: "Refine",
    description: "Add a text watermark with configurable placement, opacity, angle, and page range.",
    load: () => import("../content/help/add-watermark.mdx"),
  },
  {
    slug: "remove-annotations",
    title: "Remove Annotations",
    section: "Refine",
    description: "Clear review markup from every page while keeping links and form fields.",
    load: () => import("../content/help/remove-annotations.mdx"),
  },
  {
    slug: "extract-text",
    title: "Extract Text",
    section: "Access",
    description: "Save existing selectable PDF text to a plain text file.",
    load: () => import("../content/help/extract-text.mdx"),
  },
  {
    slug: "edit-pdf-metadata",
    title: "Edit PDF Metadata",
    section: "Access",
    description: "Edit a PDF title, author, subject, and keywords without changing your source.",
    load: () => import("../content/help/edit-pdf-metadata.mdx"),
  },
  {
    slug: "unlock-pdf",
    title: "Unlock PDF",
    section: "Access",
    description: "Use an authorized password to save an unencrypted PDF copy.",
    load: () => import("../content/help/unlock-pdf.mdx"),
  },
  {
    slug: "troubleshooting",
    title: "Troubleshooting",
    section: "Help",
    description: "Resolve installation, encrypted-input, disabled-action, and output problems.",
    load: () => import("../content/help/troubleshooting.mdx"),
  },
  {
    slug: "faq",
    title: "FAQs",
    section: "Help",
    description: "Answers about compatibility, offline use, source files, scans, and supported tools.",
    load: () => import("../content/help/faq.mdx"),
  },
  {
    slug: "privacy-and-data",
    title: "Privacy & data",
    section: "Help",
    description: "Understand local PDF processing, saved outputs, and the website’s separate analytics.",
    load: () => import("../content/help/privacy-and-data.mdx"),
  },
];

export function docsPath(slug: string): string {
  return slug ? `/docs/${slug}` : "/docs";
}
