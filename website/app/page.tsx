import { AppPreview } from "./preview";
import { ToolIcon, type IconName } from "./tool-icon";

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
            <a href="#tools">The toolkit</a>
            <a href="#philosophy">Our philosophy</a>
          </nav>
          <a className="header-cta" href="#get-app">
            Get DipperPDF <span aria-hidden="true">↗</span>
          </a>
        </header>
        <main id="main">
          <section className="hero" aria-labelledby="hero-title">
            <div className="hero-copy">
              <p className="eyebrow reveal">
                <span className="status-dot" /> A LITTLE UTILITY FOR YOUR MAC
              </p>
              <h1 id="hero-title" className="reveal">
                PDFs.
                <br />
                Less fuss.
                <br />
                <span>More done.</span>
              </h1>
              <p className="hero-description reveal">
                The everyday PDF toolkit that feels right at home. Small,
                thoughtful tools. All on your Mac.
              </p>
              <div className="hero-actions reveal">
                <a className="button button-dark" href="#tools">
                  Meet your new toolkit <span aria-hidden="true">↗</span>
                </a>
                <p>
                  Native to macOS.
                  <br />
                  Private by nature.
                </p>
              </div>
            </div>
            <div className="hero-visual reveal">
              <div className="visual-topline">
                <span>LESS BUSYWORK, MORE BREATHING ROOM</span>
                <span aria-hidden="true">✳</span>
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
          <div className="promise-strip" aria-label="Product principles">
            <span>
              <ToolIcon name="unlock" /> No uploads
            </span>
            <span>
              <ToolIcon name="metadata" /> No accounts
            </span>
            <span>
              <ToolIcon name="extract" /> Originals untouched
            </span>
            <span>
              <span className="native-symbol" aria-hidden="true">
                ⌘
              </span>{" "}
              Made for Mac
            </span>
          </div>
          <section
            className="toolkit section"
            id="tools"
            aria-labelledby="toolkit-title"
          >
            <div className="section-intro">
              <div>
                <p className="eyebrow">THE EVERYDAY ESSENTIALS</p>
                <h2 id="toolkit-title">
                  A small app.
                  <br />A rather useful toolkit.
                </h2>
              </div>
              <p>
                For the attachment that’s too big.
                <br />
                The page that’s the wrong way up.
                <br />
                The five files that should have been one.
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
              <span aria-hidden="true">✳</span> Fourteen focused tools. One
              quieter way to work.
            </p>
          </section>
          <section
            className="philosophy"
            id="philosophy"
            aria-labelledby="philosophy-title"
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
                A GOOD PLACE FOR YOUR FILES.
              </span>
              <span className="orbit-star">✳</span>
            </div>
            <div className="philosophy-copy">
              <p className="eyebrow">A DIFFERENT KIND OF PDF APP</p>
              <h2 id="philosophy-title">
                Your documents.
                <br />
                Your Mac.
                <br />
                <span>Your business.</span>
              </h2>
              <p className="philosophy-description">
                A contract, a bank statement, a work in progress. Whatever’s in
                your PDF, it doesn’t need a trip to someone else’s server.
              </p>
              <div className="principle">
                <span>01</span>
                <div>
                  <h3>Offline. On purpose.</h3>
                  <p>
                    Every tool works locally. No uploads, no accounts, no
                    external PDF services.
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
                  <h3>At home on your Mac.</h3>
                  <p>
                    A native app with familiar file pickers and a focused
                    workspace.
                  </p>
                </div>
              </div>
            </div>
          </section>
          <section
            className="workflow section"
            aria-labelledby="workflow-title"
          >
            <div className="workflow-heading">
              <p className="eyebrow">THAT’S REALLY ALL THERE IS TO IT</p>
              <h2 id="workflow-title">In. Done. On with your day.</h2>
            </div>
            <ol className="workflow-steps">
              <li>
                <span className="step-number">01</span>
                <h3>Pick your PDF.</h3>
                <p>Open a document from your Mac.</p>
              </li>
              <li>
                <span className="step-number">02</span>
                <h3>Do your thing.</h3>
                <p>Choose a tool. Make it just right.</p>
              </li>
              <li>
                <span className="step-number">03</span>
                <h3>Save a fresh copy.</h3>
                <p>Keep the original. Enjoy the result.</p>
              </li>
            </ol>
          </section>
          <section
            className="get-app"
            id="get-app"
            aria-labelledby="get-app-title"
          >
            <div>
              <p className="eyebrow">MAKE YOURSELF AT HOME</p>
              <h2 id="get-app-title">
                A little less PDF.
                <br />A little more day.
              </h2>
              <p>
                DipperPDF is available to build from source.
                <br />
                Made for macOS 14 and later.
              </p>
              <a
                className="button button-paper"
                href="https://github.com/nshntarora/dipperpdf/tree/main/macos#build-and-run"
              >
                Get DipperPDF on GitHub <span aria-hidden="true">↗</span>
              </a>
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
            <span className="closing-star" aria-hidden="true">
              ✳
            </span>
          </section>
        </main>
        <footer className="site-footer">
          <Brand footer />
          <p>Made for PDFs that stay yours.</p>
          <a href="https://github.com/nshntarora/dipperpdf">
            Source code <span aria-hidden="true">↗</span>
          </a>
          <a href="#top">
            Back to top <span aria-hidden="true">↑</span>
          </a>
        </footer>
      </div>
    </>
  );
}
