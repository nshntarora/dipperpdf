import type { Metadata } from "next";
import { AppPreview } from "./preview";
import { WorkflowCarousel } from "./workflow-carousel";
import { DownloadButton } from "./download-button";
import { ToolIcon, type IconName } from "./tool-icon";
import {
  DOWNLOAD_URL,
  REPOSITORY_URL,
  TOOL_PAGES,
} from "../config/search-pages";
import { siteUrlBase } from "./site-url";
import "./home.css";

const title = "Sensitive PDFs. Processed entirely on your Mac. | DipperPDF";
const description =
  "Work with sensitive PDFs entirely offline on your Mac. Merge, compress, split, compare, and more. No uploads, accounts, or in-app tracking. Free and open source.";
export const metadata: Metadata = {
  title,
  description,
  alternates: { canonical: "/" },
  openGraph: { title, description, url: "/" },
  twitter: { title, description },
};

const toolGroups: {
  title: string;
  note: string;
  tools: { name: string; description: string; icon: IconName }[];
}[] = [
  {
    title: "Put things in order.",
    note: "01 / ORGANIZE",
    tools: [
      {
        name: "Merge PDFs",
        description: "Bring separate documents together.",
        icon: "merge",
      },
      {
        name: "Split PDF",
        description: "Break a big document into smaller ones.",
        icon: "split",
      },
      {
        name: "Extract pages",
        description: "Take just the pages you need.",
        icon: "extract",
      },
      {
        name: "Remove pages",
        description: "Leave the extra pages behind.",
        icon: "remove",
      },
      {
        name: "Rotate PDF",
        description: "Give sideways pages a fresh perspective.",
        icon: "rotate",
      },
      {
        name: "Reverse pages",
        description: "Start at the other end.",
        icon: "reverse",
      },
    ],
  },
  {
    title: "Get it ready to go.",
    note: "02 / REFINE",
    tools: [
      {
        name: "Compress PDF",
        description: "Make that attachment a little lighter.",
        icon: "compress",
      },
      {
        name: "Crop PDF",
        description: "Trim the visible edges of your pages.",
        icon: "crop",
      },
      {
        name: "Add page numbers",
        description: "Help everyone find the same page.",
        icon: "number",
      },
      {
        name: "Add watermark",
        description: "Make your document’s status clear.",
        icon: "watermark",
      },
      {
        name: "Remove annotations",
        description: "Clear comments and review markup.",
        icon: "annotations",
      },
    ],
  },
  {
    title: "Find what’s inside.",
    note: "03 / ACCESS",
    tools: [
      {
        name: "Extract text",
        description: "Save selectable text for your next task.",
        icon: "text",
      },
      {
        name: "Edit metadata",
        description: "Update the title, author, and details.",
        icon: "metadata",
      },
      {
        name: "Unlock PDF",
        description: "Use your password. Save an unlocked copy.",
        icon: "unlock",
      },
      {
        name: "Repair PDF",
        description: "Rebuild a copy from readable pages.",
        icon: "repair",
      },
      {
        name: "Compare PDF",
        description: "Find added and removed selectable text.",
        icon: "compare",
      },
      {
        name: "Redact PDF",
        description: "Find text and make a redacted image-only copy.",
        icon: "redact",
      },
    ],
  },
];

const workflows: {
  icon: IconName;
  category: string;
  title: string;
  description: string;
  files: string[];
  result: string;
  steps: string;
  href: string;
}[] = [
  {
    icon: "merge",
    category: "CONTRACTS & AGREEMENTS",
    title: "One packet. Ready for review.",
    description: "Bring the agreement and its appendices together in one PDF.",
    files: ["Agreement.pdf", "Appendix.pdf"],
    result: "Review packet.pdf",
    steps: "Choose files → Arrange → Merge",
    href: "/docs/merge-pdfs",
  },
  {
    icon: "compress",
    category: "EMAIL ATTACHMENTS",
    title: "A little lighter. Easier to send.",
    description:
      "Reduce the size of image-heavy PDFs before sharing. Savings depend on the document.",
    files: ["Presentation.pdf"],
    result: "Smaller presentation.pdf",
    steps: "Open → Choose compression → Save",
    href: "/docs/compress-pdf",
  },
  {
    icon: "split",
    category: "LARGE DOCUMENTS",
    title: "Give each part its own file.",
    description:
      "Break a long document into smaller PDFs for the people who need them.",
    files: ["Handbook.pdf"],
    result: "Handbook part 1.pdf",
    steps: "Open → Choose split → Save",
    href: "/docs/split-pdf",
  },
  {
    icon: "extract",
    category: "FINANCIAL RECORDS",
    title: "Share the pages you need.",
    description:
      "Pull the relevant pages from a longer report into a separate PDF.",
    files: ["Annual report.pdf"],
    result: "Selected pages.pdf",
    steps: "Open → Select pages → Extract",
    href: "/docs/extract-pages",
  },
  {
    icon: "remove",
    category: "DOCUMENT CLEANUP",
    title: "Leave the extras behind.",
    description:
      "Remove unwanted pages and save a cleaner copy of your document.",
    files: ["Report with blanks.pdf"],
    result: "Clean report.pdf",
    steps: "Open → Select pages → Remove",
    href: "/docs/remove-pages",
  },
  {
    icon: "rotate",
    category: "SCANNED DOCUMENTS",
    title: "The right way up.",
    description:
      "Turn sideways or upside-down pages so your document is easier to read.",
    files: ["Sideways scan.pdf"],
    result: "Rotated scan.pdf",
    steps: "Open → Choose rotation → Save",
    href: "/docs/rotate-pdf",
  },
  {
    icon: "reverse",
    category: "SCANNER OUTPUT",
    title: "Put the last page first.",
    description:
      "Reverse the page order when a scanned document comes out back to front.",
    files: ["Reversed scan.pdf"],
    result: "Reordered scan.pdf",
    steps: "Open → Reverse → Save",
    href: "/docs/reverse-pages",
  },
  {
    icon: "crop",
    category: "PAGE LAYOUT",
    title: "A cleaner frame.",
    description:
      "Trim visible page edges to focus on the content you want to present.",
    files: ["Wide margins.pdf"],
    result: "Cropped pages.pdf",
    steps: "Open → Set crop → Save",
    href: "/docs/crop-pdf",
  },
  {
    icon: "number",
    category: "REVIEW PACKETS",
    title: "Keep everyone on the same page.",
    description:
      "Add page numbers so colleagues can reference the same place in a document.",
    files: ["Review packet.pdf"],
    result: "Numbered packet.pdf",
    steps: "Open → Set numbering → Save",
    href: "/docs/add-page-numbers",
  },
  {
    icon: "watermark",
    category: "DRAFTS & REVIEWS",
    title: "Make its status clear.",
    description:
      "Add a text watermark to label drafts and documents for review.",
    files: ["Proposal.pdf"],
    result: "Marked proposal.pdf",
    steps: "Open → Set watermark → Save",
    href: "/docs/add-watermark",
  },
  {
    icon: "annotations",
    category: "FINISHED REVIEWS",
    title: "Clear the review markup.",
    description:
      "Remove annotations and comments from a separate copy when your review is complete.",
    files: ["Reviewed draft.pdf"],
    result: "Clean draft.pdf",
    steps: "Open → Remove annotations → Save",
    href: "/docs/remove-annotations",
  },
  {
    icon: "text",
    category: "RESEARCH & NOTES",
    title: "Take the words with you.",
    description:
      "Save existing selectable text for your notes or your next writing task. Scanned images need OCR elsewhere.",
    files: ["Research paper.pdf"],
    result: "Research notes.txt",
    steps: "Open → Extract text → Save",
    href: "/docs/extract-text",
  },
  {
    icon: "metadata",
    category: "DOCUMENT DETAILS",
    title: "Get the details right.",
    description:
      "Update the title, author, and other metadata before handing off your PDF.",
    files: ["Final report.pdf"],
    result: "Updated report.pdf",
    steps: "Open → Edit details → Save",
    href: "/docs/edit-pdf-metadata",
  },
  {
    icon: "unlock",
    category: "PASSWORD-PROTECTED FILES",
    title: "Open once. Save a working copy.",
    description:
      "Use your document’s password to save an unencrypted copy for your next task.",
    files: ["Protected statement.pdf"],
    result: "Unlocked statement.pdf",
    steps: "Open → Enter password → Save",
    href: "/docs/unlock-pdf",
  },
  {
    icon: "repair",
    category: "TROUBLESOME FILES",
    title: "Give readable pages a fresh start.",
    description:
      "Rebuild a PDF from the pages that can still be read. Recovery depends on the source file.",
    files: ["Damaged document.pdf"],
    result: "Rebuilt document.pdf",
    steps: "Open → Rebuild → Save",
    href: "/docs/repair-pdf",
  },
  {
    icon: "compare",
    category: "DOCUMENT REVISIONS",
    title: "Know what changed.",
    description:
      "Compare selectable text in two versions and save a report of added and removed lines.",
    files: ["Original.pdf", "Revised.pdf"],
    result: "Changes report.pdf",
    steps: "Choose versions → Compare → Save report",
    href: "/docs/compare-pdf",
  },
  {
    icon: "redact",
    category: "SENSITIVE INFORMATION",
    title: "Keep private details private.",
    description:
      "Find selectable text and save a redacted, image-only copy with those details covered.",
    files: ["Sensitive report.pdf"],
    result: "Redacted report.pdf",
    steps: "Open → Find text → Redact → Save",
    href: "/docs/redact-pdf",
  },
];

const faqs = [
  {
    q: "Does it really work completely offline?",
    a: "Yes. Once installed, every PDF tool runs on your Mac without network access. You need an internet connection to download the app or read this website, but not to process your documents.",
    href: "/docs/privacy-and-data",
    link: "How your data is handled",
  },
  {
    q: "Where do my documents go?",
    a: "You open files from your Mac and choose where to save the results. DipperPDF does not upload your PDFs or use external PDF services. If you save into an iCloud or other synchronized folder, that service may upload the saved file according to its own settings.",
    href: "/docs/privacy-and-data",
    link: "Read about local processing",
  },
  {
    q: "Is every tool free?",
    a: "Yes. Every tool is included, with no trial, subscription, or paid upgrade. You do not need an account or payment details. The source code is available on GitHub.",
    href: REPOSITORY_URL,
    link: "Explore the source code",
  },
  {
    q: "Will my original PDF change?",
    a: "No. DipperPDF prepares a separate result and prevents saving over an imported source. Review the output, then save it with a fresh filename. To use another tool, import the copy you just saved.",
    href: "/docs/getting-started",
    link: "See the open-to-save workflow",
  },
  {
    q: "Can I work with password-protected PDFs?",
    a: "Use Unlock PDF first with the password and permissions needed for the document. Other tools require an unencrypted input. Unlocking happens locally and saves a separate, unencrypted copy; it does not crack passwords.",
    href: "/docs/unlock-pdf",
    link: "Learn about password-protected files",
  },
  {
    q: "Can it read scanned text?",
    a: "DipperPDF does not include OCR. Text extraction, comparison, and redaction work with existing selectable text, not words inside scanned images. Compression can reduce image-heavy PDFs, but savings depend on the document.",
    href: "/docs/faq",
    link: "More answers in the documentation",
  },
  {
    q: "Does it work on my Mac?",
    a: "DipperPDF is a native Mac app with support for Apple silicon and Intel. Visit the installation guide for system requirements and step-by-step setup instructions.",
    href: "/docs/install",
    link: "View installation requirements",
  },
];

function Brand() {
  return (
    <a className="brand" href="#top" aria-label="DipperPDF home">
      <img src="/app-icon.png" width="42" height="42" alt="" />
      <span>
        Dipper<span className="brand-pdf">PDF</span>
        <span className="brand-dot">.</span>
      </span>
    </a>
  );
}

function SectionLabel({
  number,
  children,
}: {
  number: string;
  children: React.ReactNode;
}) {
  return (
    <p className="home-label">
      <span>{number}</span>
      {children}
    </p>
  );
}

export default function Home() {
  const structuredData = {
    "@context": "https://schema.org",
    "@graph": [
      { "@type": "WebSite", name: "DipperPDF", url: siteUrlBase.href },
      {
        "@type": "Organization",
        name: "DipperPDF",
        url: siteUrlBase.href,
        logo: new URL("/app-icon.png", siteUrlBase).href,
        sameAs: [REPOSITORY_URL],
      },
      {
        "@type": "SoftwareApplication",
        name: "DipperPDF",
        url: siteUrlBase.href,
        operatingSystem: "macOS",
        applicationCategory: "UtilitiesApplication",
        downloadUrl: DOWNLOAD_URL,
        isAccessibleForFree: true,
        offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
      },
    ],
  };
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(structuredData).replace(/</g, "\\u003c"),
        }}
      />
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <div className="site-shell home" id="top">
        <header className="site-header home-header">
          <Brand />
          <nav aria-label="Main navigation">
            <a href="#privacy">Why local?</a>
            <a href="#workflows">Workflows</a>
            <a href="#tools">The toolkit</a>
            <a href="/docs">Docs</a>
          </nav>
          <DownloadButton
            className="header-cta"
            href={DOWNLOAD_URL}
            location="header"
          >
            Download for Mac <span aria-hidden="true">↓</span>
          </DownloadButton>
        </header>
        <main id="main" tabIndex={-1}>
          <section className="home-hero" aria-labelledby="hero-title">
            <div className="home-hero-copy">
              <p className="home-kicker">
                <span className="status-dot" /> OPEN SOURCE. NATIVE. DESIGNED
                FOR MAC.
              </p>
              <h1 id="hero-title">
                Private PDF Tools
                <em> for your Mac</em>
              </h1>
              <p className="home-lead">
                Your contracts, financial records, and private notes deserve a
                little privacy. Merge, compress, and more—without uploading a
                single page.
              </p>
              <div className="home-actions">
                <DownloadButton
                  className="button button-dark"
                  href={DOWNLOAD_URL}
                  location="hero"
                >
                  Download for Mac <span aria-hidden="true">↓</span>
                </DownloadButton>
                <a
                  className="home-text-link"
                  href="#tools"
                  data-analytics-cta="explore_tools"
                  data-analytics-location="hero"
                >
                  Explore the tools <span aria-hidden="true">↗</span>
                </a>
              </div>
              <p className="home-fine">
                Free & open source. No account. Works completely offline.
              </p>
            </div>
            <div className="home-preview">
              <div className="home-preview-label">
                <span>YOUR DESK. YOUR DOCUMENTS.</span>
                <span aria-hidden="true">⌘</span>
              </div>
              <AppPreview />
              <div className="home-local-note">
                <span className="status-dot" /> Processing happens here. On your
                Mac.
              </div>
            </div>
          </section>
          <div
            className="home-trust"
            aria-label="Native app privacy principles"
          >
            <span>No PDF uploads</span>
            <span>No accounts</span>
            <span>No in-app tracking</span>
            <span>Every tool works offline</span>
          </div>

          <section
            className="home-section home-privacy"
            id="privacy"
            aria-labelledby="privacy-title"
          >
            <div className="home-section-heading">
              <div>
                <SectionLabel number="01">
                  A SMALLER CIRCLE OF TRUST
                </SectionLabel>
                <h2 id="privacy-title">
                  Your files don’t need
                  <br />a round trip to the cloud.
                </h2>
              </div>
              <p>
                When a document is sensitive, where you process it matters.
                DipperPDF brings the tools to your files, right on your Mac.
              </p>
            </div>
            <div className="home-privacy-grid">
              <div className="home-mac-boundary">
                <div className="home-boundary-label">
                  <span aria-hidden="true">⌘</span> INSIDE YOUR MAC{" "}
                  <span className="status-dot" />
                </div>
                <div className="home-local-flow">
                  {[
                    { icon: "text", title: "Open", text: "Your PDF" },
                    { icon: "compress", title: "Process", text: "Local tools" },
                    { icon: "extract", title: "Save", text: "A fresh copy" },
                  ].map((step) => (
                    <div key={step.title}>
                      <div className="home-flow-icon">
                        <ToolIcon name={step.icon as IconName} />
                      </div>
                      <strong>{step.title}</strong>
                      <span>{step.text}</span>
                    </div>
                  ))}
                </div>
                <p className="home-boundary-caption">
                  No upload step. No external PDF service.
                </p>
              </div>
              <div className="home-privacy-points">
                <article>
                  <span>01 /</span>
                  <div>
                    <h3>Offline is how it works.</h3>
                    <p>
                      Every PDF operation runs locally. Once installed, the app
                      needs no internet connection, account, or external
                      processing service.
                    </p>
                  </div>
                </article>
                <article>
                  <span>02 /</span>
                  <div>
                    <h3>Your original stays yours.</h3>
                    <p>
                      Prepare and review a result before saving a separate copy.
                      You choose its name and destination; your imported source
                      stays unchanged.
                    </p>
                  </div>
                </article>
                <article>
                  <span>03 /</span>
                  <div>
                    <h3>Trust you can inspect.</h3>
                    <p>
                      No in-app analytics or tracking. Open source, so you can
                      inspect how the app handles your documents.
                    </p>
                    <a className="home-text-link" href={REPOSITORY_URL}>
                      Read the source on GitHub{" "}
                      <span aria-hidden="true">↗</span>
                    </a>
                  </div>
                </article>
              </div>
            </div>
            <p className="home-privacy-footnote">
              You control where results are saved. Cloud-synchronized folders
              follow your storage provider’s settings.{" "}
              <a href="/docs/privacy-and-data">More about privacy & data ↗</a>
            </p>
          </section>

          <section
            className="home-section"
            id="workflows"
            aria-labelledby="workflows-title"
          >
            <div className="home-section-heading">
              <div>
                <SectionLabel number="02">
                  PRIVATE FILES. PRACTICAL WORK.
                </SectionLabel>
                <h2 id="workflows-title">
                  For the documents
                  <br />
                  you handle every day.
                </h2>
              </div>
              <p>
                Tools to get from a folder full of PDFs to the file you actually
                need. Every step stays on your Mac.
              </p>
            </div>
            <WorkflowCarousel>
              {workflows.map((workflow, index) => (
                <article className="home-workflow" key={workflow.title}>
                  <div
                    className={`home-workflow-art home-workflow-art-${index % 3}`}
                    aria-hidden="true"
                  >
                    <div className="home-file-stack">
                      {workflow.files.map((file) => (
                        <div className="home-mini-file" key={file}>
                          <ToolIcon name="text" />
                          <span>{file}</span>
                          <i />
                          <i />
                          <i />
                        </div>
                      ))}
                    </div>
                    <span className="home-file-arrow">↓</span>
                    <div className="home-result-file">
                      <ToolIcon name={workflow.icon} />
                      <span>{workflow.result}</span>
                      <span>✓</span>
                    </div>
                    <span className="home-art-note">PROCESSED LOCALLY</span>
                  </div>
                  <div className="home-workflow-copy">
                    <p className="home-kicker">
                      {
                        TOOL_PAGES.find((tool) => tool.id === workflow.icon)
                          ?.name
                      }
                    </p>
                    <h3>{workflow.title}</h3>
                    <p>{workflow.description}</p>
                    <div className="home-workflow-steps">{workflow.steps}</div>
                    <a className="home-text-link" href={workflow.href}>
                      Learn more <span aria-hidden="true">↗</span>
                    </a>
                  </div>
                </article>
              ))}
            </WorkflowCarousel>
            <p className="home-section-note">
              One focused tool at a time. To combine operations, save your
              result and open that copy in the next tool. Compression savings
              depend on the document.
            </p>
          </section>

          <section
            className="home-section home-toolkit"
            id="tools"
            aria-labelledby="toolkit-title"
          >
            <div className="home-section-heading">
              <div>
                <SectionLabel number="03">THE COMPLETE TOOLKIT</SectionLabel>
                <h2 id="toolkit-title">
                  {TOOL_PAGES.length} useful tools.
                  <br />
                  <em>Zero uploads.</em>
                </h2>
              </div>
              <p>
                Organize pages, prepare documents for sharing, and work with the
                text inside. All included. All local.
              </p>
            </div>
            <div className="home-tool-groups">
              {toolGroups.map((group) => (
                <div className="home-tool-group" key={group.title}>
                  <p className="home-kicker">{group.note}</p>
                  <h3>{group.title}</h3>
                  <ul>
                    {group.tools.map((tool) => (
                      <li key={tool.name}>
                        <a
                          href={`/tools/${TOOL_PAGES.find((page) => page.id === tool.icon)!.slug}`}
                        >
                          <ToolIcon name={tool.icon} />
                          <span>
                            <strong>{tool.name}</strong>
                            <span>{tool.description}</span>
                          </span>
                          <span className="home-tool-arrow" aria-hidden="true">
                            ↗
                          </span>
                        </a>
                      </li>
                    ))}
                  </ul>
                </div>
              ))}
            </div>
          </section>

          <section
            className="home-section home-how"
            aria-labelledby="how-title"
          >
            <SectionLabel number="04">FROM OPEN TO SAVE</SectionLabel>
            <h2 id="how-title">
              A familiar rhythm.
              <br />A fresh copy at the end.
            </h2>
            <ol className="home-how-steps">
              {[
                ["Choose", "Drop in your PDF or choose a file from Finder."],
                ["Configure", "Choose the pages or settings for your task."],
                ["Prepare", "Run the tool. Processing happens on your Mac."],
                ["Review", "Inspect the prepared result before saving."],
                ["Save", "Choose a new filename and a place for your copy."],
              ].map(([name, text], index) => (
                <li key={name}>
                  <span>0{index + 1}</span>
                  <h3>{name}</h3>
                  <p>{text}</p>
                </li>
              ))}
            </ol>
            <a className="home-text-link" href="/docs/getting-started">
              Walk through your first PDF <span aria-hidden="true">↗</span>
            </a>
          </section>

          <section
            className="home-section home-faq"
            aria-labelledby="faq-title"
          >
            <div>
              <SectionLabel number="05">A FEW GOOD QUESTIONS</SectionLabel>
              <h2 id="faq-title">
                Before you
                <br />
                <em>bring your files.</em>
              </h2>
              <p>Know what to expect before you download.</p>
              <a className="home-text-link" href="/docs">
                Explore the documentation ↗
              </a>
            </div>
            <div className="home-faq-list">
              {faqs.map((faq) => (
                <details key={faq.q}>
                  <summary>
                    {faq.q}
                    <span aria-hidden="true">+</span>
                  </summary>
                  <div>
                    <p>{faq.a}</p>
                    <a className="home-text-link" href={faq.href}>
                      {faq.link} ↗
                    </a>
                  </div>
                </details>
              ))}
            </div>
          </section>

          <section
            className="home-section home-guides"
            aria-labelledby="guides-title"
          >
            <div className="home-guides-heading">
              <h2 id="guides-title">A little guidance goes a long way.</h2>
              <a className="home-text-link" href="/docs">
                All documentation ↗
              </a>
            </div>
            <div className="home-guide-grid">
              {[
                {
                  title: "Your first PDF, step by step.",
                  text: "From opening a document to reviewing and saving your result.",
                  href: "/docs/getting-started",
                  label: "GETTING STARTED",
                },
                {
                  title: "Keep the whole workflow local.",
                  text: "A practical guide to working with PDFs without uploading them.",
                  href: "/guides/edit-pdf-without-uploading",
                  label: "OFFLINE WORKFLOWS",
                },
                {
                  title: "Know where your data goes.",
                  text: "Understand local processing, saved copies, and storage choices.",
                  href: "/docs/privacy-and-data",
                  label: "PRIVACY & DATA",
                },
              ].map((guide) => (
                <a className="home-guide" href={guide.href} key={guide.href}>
                  <p className="home-kicker">{guide.label}</p>
                  <h3>{guide.title}</h3>
                  <p>{guide.text}</p>
                  <span aria-hidden="true">↗</span>
                </a>
              ))}
            </div>
          </section>

          <section
            className="home-download"
            id="pricing"
            aria-labelledby="get-app-title"
          >
            <div id="get-app">
              <p className="home-kicker">EVERY TOOL. COMPLETELY FREE.</p>
              <h2 id="get-app-title">
                Keep your documents
                <br />
                <em>close to home.</em>
              </h2>
              <p>
                All {TOOL_PAGES.length} tools. No subscription, trial, or paid
                upgrades.
                <br />A native app for Apple silicon and Intel Macs.
              </p>
              <DownloadButton
                className="button button-dark"
                href={DOWNLOAD_URL}
                location="get_app"
              >
                Download for free <span aria-hidden="true">↓</span>
              </DownloadButton>
              <a
                className="home-text-link"
                href="/docs/install"
                data-analytics-cta="installation_guide"
                data-analytics-location="get_app"
              >
                Installation guide ↗
              </a>
            </div>
            <div className="home-bird">
              <img
                src="/app-icon.png"
                width="250"
                height="250"
                alt="DipperPDF’s brown-and-white dipper bird app icon"
              />
              <span>A small bird. A private place to work.</span>
            </div>
          </section>
        </main>
        <footer className="home-footer">
          <Brand />
          <p>Made for PDFs that stay yours.</p>
          <nav aria-label="Footer navigation">
            <a href="/docs">Docs</a>
            <a href="/privacy">Privacy</a>
            <a href="/terms">Terms</a>
            <a href="/cookies">Cookies</a>
            <a href={REPOSITORY_URL}>GitHub ↗</a>
            <a href="#top">Back to top ↑</a>
          </nav>
        </footer>
      </div>
    </>
  );
}
