import { AppPreview } from "./preview";
import { DownloadButton } from "./download-button";
import { HeroHeadline } from "./hero-headline";
import { ToolIcon, type IconName } from "./tool-icon";

const downloadUrl =
  "https://github.com/nshntarora/dipperpdf/releases/latest/download/DipperPDF.dmg";
const repositoryUrl = "https://github.com/nshntarora/dipperpdf";

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
    ],
  },
];

const heroOperations = toolGroups.flatMap((group) =>
  group.tools.map((tool) => tool.name[0].toLowerCase() + tool.name.slice(1)),
);

function Brand({ footer = false }: { footer?: boolean }) {
  return (
    <a
      className={`brand${footer ? " brand-footer" : ""}`}
      href="#top"
      aria-label="DipperPDF home"
    >
      <img src="/app-icon.png" width="42" height="42" alt="" />
      <span>
        Dipper<span className="brand-pdf">PDF</span>
        <span className="brand-dot">.</span>
      </span>
    </a>
  );
}

export default function Home() {
  return (
    <>
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <div className="site-shell" id="top">
        <header className="site-header">
          <Brand />
          <nav aria-label="Main navigation">
            <a href="#privacy">Your privacy</a>
            <a href="#tools">The toolkit</a>
            <a href="#pricing">Pricing</a>
            <a href="/docs">Docs</a>
            <a href={repositoryUrl}>
              GitHub <span aria-hidden="true">↗</span>
            </a>
          </nav>
          <DownloadButton
            className="header-cta"
            href={downloadUrl}
            location="header"
          >
            Download Mac app <span aria-hidden="true">↓</span>
          </DownloadButton>
        </header>
        <main id="main">
          <section className="hero" aria-labelledby="hero-title">
            <div className="hero-copy">
              <p className="eyebrow reveal uppercase">
                <span className="status-dot" /> FREE. OPEN SOURCE. NATIVELY
                BUILT FOR MAC.
              </p>
              <HeroHeadline operations={heroOperations} />
              <p className="hero-description reveal">
                All on your Mac. No uploads. Works offline.
              </p>
              <div className="hero-actions reveal">
                <DownloadButton
                  className="button button-dark"
                  href={downloadUrl}
                  location="hero"
                >
                  Download Mac app <span aria-hidden="true">↓</span>
                </DownloadButton>
                <p>
                  macOS 14 or later.
                  <br />
                  Works offline.
                </p>
              </div>
              <p className="hero-source reveal">
                Prefer to check for yourself?{" "}
                <a href={repositoryUrl}>
                  Read the code on GitHub <span aria-hidden="true">↗</span>
                </a>
              </p>
            </div>
            <div className="hero-visual reveal">
              <div className="visual-topline">
                <span>SENSITIVE DOCUMENTS. LOCAL TOOLS.</span>
                <span aria-hidden="true">
                  <ToolIcon name="text" />
                </span>
              </div>
              <AppPreview />
              <div className="visual-caption">
                <span>
                  <span className="status-dot" /> Your files stay right here.
                </span>
                <span>macOS 14+</span>
              </div>
            </div>
          </section>
          <div className="promise-strip" aria-label="Privacy principles">
            <span>
              <ToolIcon name="unlock" /> No uploads
            </span>
            <span>
              <ToolIcon name="metadata" /> No accounts
            </span>
            <span>
              <ToolIcon name="extract" /> No in-app tracking
            </span>
            <span>
              <span className="native-symbol" aria-hidden="true">
                ⌘
              </span>{" "}
              Works offline
            </span>
          </div>
          <section
            className="philosophy"
            id="privacy"
            aria-labelledby="privacy-title"
          >
            <div className="privacy-art" aria-hidden="true">
              <div className="orbit orbit-one" />
              <div className="orbit orbit-two" />
              <div className="orbit orbit-three" />
              <span className="orbit-label label-top">YOUR MAC</span>
              <div className="privacy-document">
                <ToolIcon name="text" />
                <span>Just yours.</span>
                <div className="paper-lines">
                  <i />
                  <i />
                  <i />
                </div>
                <div className="document-seal">
                  <ToolIcon name="unlock" />
                </div>
              </div>
              <span className="orbit-label label-bottom">
                PROCESSED HERE. NEVER UPLOADED.
              </span>
              <span className="orbit-file">
                <ToolIcon name="text" />
              </span>
            </div>
            <div className="philosophy-copy">
              <p className="eyebrow">PRIVACY COMES FIRST</p>
              <h2 id="privacy-title">
                Your documents.
                <br />
                Your Mac.
                <br />
                <span>Your business.</span>
              </h2>
              <p className="philosophy-description">
                Some documents are too personal to upload. Your contracts,
                unreleased pitch decks, financial records, and private notes can
                all be processed right on your Mac.
              </p>
              <div className="principle">
                <span>01</span>
                <div>
                  <h3>Offline. On purpose.</h3>
                  <p>
                    Every tool processes your PDFs on your Mac. No uploads, no
                    accounts, no in-app tracking, and no external PDF services.
                  </p>
                </div>
              </div>
              <div className="principle">
                <span>02</span>
                <div>
                  <h3>A fresh file. Every time.</h3>
                  <p>
                    Save your result as a separate file. Your original stays
                    exactly as it was.
                  </p>
                </div>
              </div>
              <div className="principle">
                <span>03</span>
                <div>
                  <h3>You can read the code.</h3>
                  <p>
                    You don’t have to take our word for it. If you don’t trust
                    our privacy claims, read the source code and verify them for
                    yourself.
                  </p>
                  <a className="source-link" href={repositoryUrl}>
                    View DipperPDF on GitHub <span aria-hidden="true">↗</span>
                  </a>
                </div>
              </div>
            </div>
          </section>
          <section
            className="toolkit section"
            id="tools"
            aria-labelledby="toolkit-title"
          >
            <div className="section-intro">
              <div>
                <p className="eyebrow">EVERY TOOL WORKS LOCALLY</p>
                <h2 id="toolkit-title">
                  Sensitive files.
                  <br />
                  Everyday PDF tasks.
                </h2>
              </div>
              <p>
                Merge the pages of a contract.
                <br />
                Compress a pitch deck before sending it.
                <br />
                Extract pages from your personal notes.
              </p>
            </div>
            <div className="tool-groups">
              {toolGroups.map((group) => (
                <div className="tool-group" key={group.title}>
                  <div className="group-heading">
                    <p className="eyebrow">{group.note}</p>
                    <h3>{group.title}</h3>
                  </div>
                  <div className="tool-list">
                    {group.tools.map((tool) => (
                      <article className="tool" key={tool.name}>
                        <div className="tool-icon">
                          <ToolIcon name={tool.icon} />
                        </div>
                        <div>
                          <h4>{tool.name}</h4>
                          <p>{tool.description}</p>
                        </div>
                      </article>
                    ))}
                  </div>
                </div>
              ))}
            </div>
            <p className="toolkit-footnote">
              <span aria-hidden="true">
                <ToolIcon name="text" />
              </span> Fourteen focused tools. One private place to work.
            </p>
          </section>
          <section
            className="workflow section"
            aria-labelledby="workflow-title"
          >
            <div className="workflow-heading">
              <p className="eyebrow">FROM OPEN TO SAVE, ALL ON YOUR MAC</p>
              <h2 id="workflow-title">Keep your work close.</h2>
            </div>
            <ol className="workflow-steps">
              <li>
                <span className="step-number">01</span>
                <h3>Pick your PDF.</h3>
                <p>Open a document from your Mac.</p>
              </li>
              <li>
                <span className="step-number">02</span>
                <h3>Process it locally.</h3>
                <p>Choose a tool. Your PDF stays on your Mac.</p>
              </li>
              <li>
                <span className="step-number">03</span>
                <h3>Save a fresh copy.</h3>
                <p>Keep the original. Enjoy the result.</p>
              </li>
            </ol>
          </section>
          <section
            className="pricing section"
            id="pricing"
            aria-labelledby="pricing-title"
          >
            <div className="pricing-copy">
              <p className="eyebrow">PRICING</p>
              <h2 id="pricing-title">
                Every tool.
                <br />
                Completely free.
              </h2>
              <p className="pricing-description">
                DipperPDF is completely free to download and use. All fourteen
                PDF tools are included, with no subscription, trial period, or
                paid upgrades.
              </p>
            </div>
            <div className="pricing-card">
              <p className="eyebrow">THE WHOLE TOOLKIT</p>
              <p className="pricing-price">$0</p>
              <p className="pricing-detail">Free to download. Free to use.</p>
              <ul className="pricing-inclusions">
                <li>All fourteen PDF tools included</li>
                <li>Works offline on your Mac</li>
                <li>No account or payment details needed</li>
              </ul>
              <DownloadButton
                className="button button-dark"
                href={downloadUrl}
                location="pricing"
              >
                Download for free <span aria-hidden="true">↓</span>
              </DownloadButton>
              <p className="pricing-requirement">For macOS 14 and later.</p>
            </div>
          </section>
          <section
            className="get-app"
            id="get-app"
            aria-labelledby="get-app-title"
          >
            <div>
              <p className="eyebrow">FOR THE FILES YOU KEEP TO YOURSELF</p>
              <h2 id="get-app-title">
                Private documents.
                <br />A place to work.
              </h2>
              <p>
                Fourteen PDF tools. All local. No uploads.
                <br />
                Made for macOS 14 and later.
              </p>
              <DownloadButton
                className="button button-paper"
                href={downloadUrl}
                location="get_app"
              >
                Download Mac app <span aria-hidden="true">↓</span>
              </DownloadButton>
            </div>
            <div className="closing-icon">
              <img
                src="/app-icon.png"
                width="280"
                height="280"
                alt="DipperPDF’s brown-and-white dipper bird app icon"
              />
              <span>A small bird. A useful companion.</span>
            </div>
            <span className="closing-file" aria-hidden="true">
              <ToolIcon name="text" />
            </span>
          </section>
        </main>
        <footer className="site-footer">
          <Brand footer />
          <p>Made for PDFs that stay yours.</p>
          <a href="/docs">Documentation</a>
          <a href={repositoryUrl}>
            Read the code on GitHub <span aria-hidden="true">↗</span>
          </a>
          <a href="#top">
            Back to top <span aria-hidden="true">↑</span>
          </a>
        </footer>
      </div>
    </>
  );
}
