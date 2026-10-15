// Audited against ToolCatalog.swift, tool models/views, and PDFEngine on 2026-10-11.
// Keep these IDs aligned with executable app destinations; do not infer capabilities from names.
export type SearchPage = {
  slug: string;
  kind: "tools" | "compare" | "guides";
  query: string;
  title: string;
  h1: string;
  description: string;
  intro: string;
  sections: {
    heading: string;
    paragraphs: string[];
    steps?: string[];
    links?: { label: string; href: string }[];
    sources?: { label: string; url: string }[];
  }[];
  faq?: { q: string; a: string }[];
  table?: {
    other: string;
    rows: string[][];
    source: { label: string; url: string };
  };
  related: string;
};

export const TOOL_PAGES = [
  {
    "id": "compress",
    "name": "Compress PDF",
    "slug": "compress-pdf",
    "query": "compress pdf offline mac"
  },
  {
    "id": "merge",
    "name": "Merge PDFs",
    "slug": "merge-pdf",
    "query": "merge pdf on mac offline"
  },
  {
    "id": "rotate",
    "name": "Rotate PDF",
    "slug": "rotate-pdf",
    "query": "rotate pdf on mac"
  },
  {
    "id": "remove",
    "name": "Remove Pages",
    "slug": "remove-pdf",
    "query": "remove pages from pdf mac"
  },
  {
    "id": "extract",
    "name": "Extract Pages",
    "slug": "extract-pdf",
    "query": "extract pages from pdf mac"
  },
  {
    "id": "split",
    "name": "Split PDF",
    "slug": "split-pdf",
    "query": "split pdf offline mac"
  },
  {
    "id": "number",
    "name": "Add Page Numbers",
    "slug": "number-pdf",
    "query": "add page numbers to pdf mac"
  },
  {
    "id": "reverse",
    "name": "Reverse Pages",
    "slug": "reverse-pdf",
    "query": "reverse pdf pages on mac"
  },
  {
    "id": "metadata",
    "name": "Edit PDF Metadata",
    "slug": "metadata-pdf",
    "query": "edit pdf metadata on mac"
  },
  {
    "id": "text",
    "name": "Extract Text",
    "slug": "text-pdf",
    "query": "extract text from pdf mac"
  },
  {
    "id": "watermark",
    "name": "Add Watermark",
    "slug": "watermark-pdf",
    "query": "watermark pdf on mac"
  },
  {
    "id": "crop",
    "name": "Crop PDF",
    "slug": "crop-pdf",
    "query": "crop pdf on mac"
  },
  {
    "id": "annotations",
    "name": "Remove Annotations",
    "slug": "annotations-pdf",
    "query": "remove pdf annotations on mac"
  },
  {
    "id": "unlock",
    "name": "Unlock PDF",
    "slug": "unlock-pdf",
    "query": "unlock pdf offline mac"
  },
  {
    "id": "repair",
    "name": "Repair PDF",
    "slug": "repair-pdf",
    "query": "repair pdf on mac"
  },
  {
    "id": "compare",
    "name": "Compare PDF",
    "slug": "compare-pdf",
    "query": "compare pdf text on mac"
  },
  {
    "id": "redact",
    "name": "Redact PDF",
    "slug": "redact-pdf",
    "query": "redact pdf offline mac"
  }
] as const;
export const SEARCH_PAGES: SearchPage[] = [
  {
    "slug": "compress-pdf",
    "kind": "tools",
    "title": "Compress a PDF offline on your Mac | DipperPDF",
    "h1": "Compress a PDF offline on your Mac",
    "query": "compress pdf offline mac",
    "description": "Reduces image-heavy PDFs using three compression levels. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To compress a PDF offline on a Mac, open Compress PDF in DipperPDF, choose Light, Balanced, or Strong, and save the prepared copy. Processing stays on your Mac without uploading the document. The tool reduces image data; an already optimized or mostly text document may not become smaller.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "An image-heavy pitch deck or scanned handout can be awkward to attach. Compression is useful when the pages you need are already in the right order and the main problem is the space occupied by pictures. Choose a quality level based on how the recipient will use the document: screen reading and detailed print review can need different image quality."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open one PDF in Compress PDF.",
          "Choose Light to retain more image detail, Balanced as a starting point, or Strong to prioritize a smaller file.",
          "Click Compress PDF and inspect the displayed original size, result size, and savings.",
          "Check the prepared pages, then click Save PDF… and choose a separate filename."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Compression uses lossy image recompression and downsampling. Strong can lose fine image detail. The app keeps the original bytes as the result when recompression would increase file size. There is no guaranteed percentage reduction, target-size control, or OCR. Existing selectable text is not turned into newly recognized scan text."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a pitch deck contains product photographs and small chart labels. Prepare a Balanced copy, look at the photographs, and zoom into the labels. If they remain useful, save that version for the attachment. If the images become too soft, prepare Light instead. Keep the original for a print workflow. If neither reduces it enough, split the deck by a sensible page count rather than promising a particular attachment size."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Compare the saved file’s image detail with the original at the zoom level your recipient is likely to use. Look especially at photographs containing text, small labels inside charts, and thin lines in scanned diagrams. Readable selectable text does not prove that text embedded in a picture survived equally well. If a stronger setting is unacceptable, retain the gentler result or send the needed pages separately. The displayed size comparison is evidence for this particular input, not a prediction for the next PDF.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Use another workflow when full-resolution images are essential or the document needs an exact final byte size. A mostly text PDF may offer little opportunity for image compression. When the problem is an unnecessary appendix, removing its pages is more directly related to the job than changing image quality."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Why is the compressed PDF the same size?",
        "a": "The source may already be optimized. DipperPDF uses the original bytes if its compressed representation would be larger."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "split-pdf"
  },
  {
    "slug": "merge-pdf",
    "kind": "tools",
    "title": "Merge PDFs offline on your Mac | DipperPDF",
    "h1": "Merge PDFs offline on your Mac",
    "query": "merge pdf on mac offline",
    "description": "Combines PDFs in the chosen file order. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To merge PDFs on a Mac without uploading them, choose Merge PDFs in DipperPDF, add the files, arrange their order, and save one combined PDF. All processing happens locally. Each document contributes its pages in sequence, and the separate source PDFs remain unchanged.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "Merge when several finished PDF documents need to travel as one package. A cover note, contract, and appendix can become a single reading sequence. Decide the file order before preparing the result: the first file supplies the opening pages, and the following files are appended. This job differs from extracting selected pages out of one document."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Choose Merge PDFs and add at least two PDF files from your Mac.",
          "Arrange the files using the order controls or drag their rows into place.",
          "Click Merge PDFs to prepare one combined document.",
          "Review the transitions between source files and use Save PDF… to save the new PDF."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "This tool accepts PDF inputs, not a mixture of Word documents and pictures. It joins complete files in their chosen order; it does not rewrite the contract text or reconcile conflicting versions. The engine copies pages into a new document, so keep the sources when their document-level features matter."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Imagine a two-page cover letter, a six-page agreement, and a three-page schedule. Add the cover letter first, agreement second, and schedule last. The hypothetical result has eleven pages. Review pages two and three, then eight and nine, to verify the transitions. If the schedule contains an extra page, prepare a separate cleaned schedule with Remove Pages before merging; this keeps the final package easy to reason about."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Check the boundaries between every pair of input files. A correct cover can hide an incorrect attachment order farther into the package. Look for duplicate title pages, missing schedules, and page references that still refer to the original separate documents. Merging does not rewrite those references. If the final package needs consecutive visible page numbers, save the merged copy first and then open that copy in Add Page Numbers. Keep the intermediate assembly if you might need to revise the packet.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "If you need only a few pages from a single file, Extract Pages is the more direct choice. For a quick combine task you already know how to do in Preview, installing another app may be unnecessary. For conversion from Office files, choose a tool that actually supports those inputs."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can I change the order of the PDFs?",
        "a": "Yes. Arrange the input file rows before preparing the result. The pages within each input remain in their original sequence."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "remove-pdf"
  },
  {
    "slug": "rotate-pdf",
    "kind": "tools",
    "title": "Rotate PDF pages on your Mac | DipperPDF",
    "h1": "Rotate PDF pages on your Mac",
    "query": "rotate pdf on mac",
    "description": "Turns selected pages in 90-degree steps. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To rotate PDF pages on a Mac, open Rotate PDF in DipperPDF, select the affected pages, turn them left or right in 90-degree steps, and save a new PDF. Your document stays on the Mac without uploads. The tool changes page orientation rather than changing the page sequence.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A scanned packet can contain sideways sheets among upright pages. Rotate only the affected sheets so the whole document is easier to read. Before selecting anything, look at the page thumbnails and distinguish a sideways page from a page that belongs earlier or later in the document. Orientation and order are separate problems."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Choose Rotate PDF and open the document.",
          "Select the pages whose orientation needs changing.",
          "Use Rotate left 90° or Rotate right 90° until the selected pages face the intended way.",
          "Click Rotate PDF, inspect the prepared document, and save a separate copy with Save PDF…."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The controls turn pages in right-angle steps. They do not straighten a slightly tilted scan, recognize scanned text, or change the order of pages. The processing operation applies the selected rotation per page and retains the other pages in sequence. Use a scan correction workflow if the paper itself was photographed at an angle."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a five-page packet has landscape tables on pages two and four that were scanned sideways. Select those two pages and rotate them in the direction that makes the headings readable. Prepare the result and check pages one through five, including the unchanged pages. If one table needs the opposite direction, adjust that page separately. Save the finished copy with a name that distinguishes it from the scanner output."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Check a page with text near each edge after rotation. A portrait thumbnail and a readable heading are useful indicators, but they do not confirm that every selected page needed the same turn. Follow the complete sequence and look for a sheet that was already upright before the operation. When several pages need different directions, apply the controls to the appropriate selections before preparing the result. Reopen the saved PDF in the viewer you intend to use for reading or printing.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Preview may be enough for a single sideways page. DipperPDF is also a poor fit for deskewing or correcting camera perspective, because those are different transformations. If you are actually trying to put the last page first, Reverse Pages changes order; rotating every page does not."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Does rotating pages reverse their order?",
        "a": "No. Rotate PDF changes orientation for selected pages. Their order stays the same."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "reverse-pdf"
  },
  {
    "slug": "remove-pdf",
    "kind": "tools",
    "title": "Remove pages from a PDF on your Mac | DipperPDF",
    "h1": "Remove pages from a PDF on your Mac",
    "query": "remove pages from pdf mac",
    "description": "Deletes selected pages while retaining the remaining order. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To remove pages from a PDF on a Mac, open Remove Pages in DipperPDF, select the pages to discard, prepare the result, and save a separate PDF. No document is uploaded. The remaining pages keep their original order, and the imported source remains available unchanged.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A packet may contain an empty scanner sheet, an outdated cover page, or an appendix that does not belong in the version you want to send. Select the unwanted pages, rather than the pages you intend to keep. That distinction matters because Extract Pages uses the opposite selection: its chosen pages become the new document."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open one PDF in Remove Pages.",
          "Select the thumbnails or page ranges you want removed.",
          "Keep at least one page, then click Remove Pages.",
          "Inspect the remaining sequence and save it using Save PDF… under a separate name."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The tool removes whole selected pages. It cannot erase a paragraph while keeping the rest of that page. The selection must leave at least one page in the output. Removing a page is not a document-wide check for sensitive information; the same information may be present elsewhere in the retained pages."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Consider a ten-page contract packet whose first sheet is an obsolete cover and whose final sheet is blank. Select pages one and ten. Prepare the result and check that the eight retained pages start with the correct agreement heading and end with the intended schedule. The retained content follows its original sequence. If you accidentally selected a needed schedule, return to the unchanged source and prepare a corrected result."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Review the joins created where removed pages used to sit. The remaining pages may be ordered correctly while still referring to a deleted appendix. Check the cover, contents page, and any reference to an attachment before treating the shorter document as complete. Whole-page removal also cannot tell you whether repeated confidential details appear on retained sheets. If those details matter, review the retained content separately instead of assuming that discarding one page addressed the entire disclosure.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Choose Extract Pages when your goal is to keep a small set from a large file. Choose text redaction when a sensitive phrase is embedded on a page you must retain. If the document is a signed record whose exact original structure matters, keep that record and treat the shortened output as a separate distribution copy."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can I remove every page?",
        "a": "No. The tool requires at least one page to remain so that it can produce a PDF."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "extract-pdf"
  },
  {
    "slug": "extract-pdf",
    "kind": "tools",
    "title": "Extract pages from a PDF on your Mac | DipperPDF",
    "h1": "Extract pages from a PDF on your Mac",
    "query": "extract pages from pdf mac",
    "description": "Saves selected pages in their original order. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To extract pages from a PDF on a Mac, choose Extract Pages in DipperPDF, select the sheets you need, and save them as one new PDF. Processing is local with no uploads. Selected pages retain their original order; the full source document remains unchanged.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "Extraction is useful when a large report contains a few pages needed for a particular conversation. The new file contains the selected pages, not every page except those selections. It is a practical distinction when an appendix should stand alone or when a recipient needs only one schedule from a larger packet."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the source PDF in Extract Pages.",
          "Select at least one page using the page selection controls.",
          "Click Extract Pages to prepare a PDF containing those selected pages.",
          "Review the extracted sequence and click Save PDF… to save a new document."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Selected pages are exported in original document order. This tool does not arrange them into a new custom sequence or produce a separate file for each chosen page. It extracts whole pages rather than individual pictures, text blocks, or table cells. For regular groups of pages, Split PDF addresses a different job."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a twelve-page proposal has the cost schedule on pages seven through nine. Select those three pages and prepare the result. The new PDF contains original pages seven, eight, and nine in that order. Check whether references on those pages depend on material elsewhere in the proposal before sending the extract. A standalone schedule can be useful, but the app does not rewrite its cross-references or add missing context."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Check the beginning and end of the extract for context. A selected page can begin halfway through a clause or finish before its definition appears. Printed page numbers continue to reflect the original document; extraction does not automatically renumber the visible labels. Decide whether that is useful for references back to the source. If you need a new visible numbering sequence, save the extract and use Add Page Numbers on that saved copy after checking the intended page range.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "If you want the original document with only an unwanted cover removed, Remove Pages makes the selection simpler. If you need a plain text quotation, Extract Text exports the text layer instead. For extracting individual embedded images or converting a page to an image file, this tool does not implement that output."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Will each selected page become a separate PDF?",
        "a": "No. Extract Pages places all selected pages into one PDF. Split PDF can create fixed-size groups."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "split-pdf"
  },
  {
    "slug": "split-pdf",
    "kind": "tools",
    "title": "Split a PDF offline on your Mac | DipperPDF",
    "h1": "Split a PDF offline on your Mac",
    "query": "split pdf offline mac",
    "description": "Divides a PDF into fixed-page-count parts. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To split a PDF offline on a Mac, choose Split PDF in DipperPDF, set the number of pages per file, prepare the parts, and save them together. The document is processed on your Mac without uploads. Each output holds a consecutive group of pages, leaving the original intact.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "Use splitting when a long PDF needs regular chunks: one page per file, short review packets, or consecutive portions of a report. Decide the number of pages per part before preparing the outputs. Fixed-size splitting is different from selecting meaningful chapter boundaries, which can fall at irregular intervals."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open one PDF in Split PDF.",
          "Set Pages per file to a positive count within the document’s page count.",
          "Click Split PDF and review the prepared output files.",
          "Choose Save PDFs… and a destination; the app saves the parts together in a new subfolder."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The split operation uses a fixed number of consecutive pages per file. The final part may be shorter. It does not find chapters, detect invoice boundaries, or divide the document at bookmark headings. The files are named with their source page ranges so you can identify which portion each contains."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Imagine a thirteen-page report split into groups of five. The outputs contain pages one through five, six through ten, and eleven through thirteen. Review all three parts, especially the final shorter one. If a section begins halfway through the second part, fixed-size splitting will not move that boundary for you. Use selected-page extraction instead if the recipient needs a complete section rather than a regular chunk."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Inspect the boundary between each pair of output files. Fixed-size chunks can split a sentence, a table, or a section between documents, which may be acceptable for storage but awkward for review. The page-range filenames help you reconstruct the original order. Keep those names or use another equally clear naming scheme when distributing the parts. If one part contains an incomplete section, use Extract Pages to create a purpose-built alternative instead of assuming every regular chunk is independently understandable.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "For one selected appendix, Extract Pages is easier than splitting the whole source. If a recipient needs one continuous document, compression may be a better response to an attachment problem. Do not expect fixed page counts to produce identical file sizes: pages with pictures and pages with text can occupy different amounts of data."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "What happens when the page count is not divisible by the group size?",
        "a": "The last PDF contains the remaining pages and can be shorter than the other parts."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "extract-pdf"
  },
  {
    "slug": "number-pdf",
    "kind": "tools",
    "title": "Add page numbers to a PDF on your Mac | DipperPDF",
    "h1": "Add page numbers to a PDF on your Mac",
    "query": "add page numbers to pdf mac",
    "description": "Adds visible numbers to a consecutive page range. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To add page numbers to a PDF on a Mac, open Add Page Numbers in DipperPDF, choose a page range, starting number, and placement, then save the prepared PDF. The operation stays on your Mac without uploads. It adds visible numbers while preserving the original source file.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A review packet is easier to discuss when readers can point to visible page numbers. Decide whether a cover should be excluded and what number the first included page should carry. The PDF viewer’s page position and the visible number printed on the sheet need not be identical when a cover or introductory pages are left unnumbered."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the PDF in Add Page Numbers.",
          "Set the first and last page and a positive starting number.",
          "Choose Bottom left, Bottom center, or Bottom right, and adjust the font size.",
          "Prepare the numbered PDF, check the placement on the selected pages, and use Save PDF…."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "This tool adds visible numeric labels in the supported bottom positions. It does not rewrite existing page numbers, create a table of contents, or implement arbitrary header templates. Check the page margins because a newly drawn number can occupy the same area as existing footer text. Pages outside the range are not numbered by this operation."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a six-page review document has a cover followed by five content pages. Choose source pages two through six and start numbering at one. Place the numbers at bottom center and prepare the result. The cover stays outside the numbering range; the next sheet visibly starts at one. Check that the fifth content page shows five and that the footer labels do not cover a caption or existing reference."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Inspect the first and last numbered pages and at least one page with a dense footer. Confirm both the starting label and the chosen position. A viewer may display source page three while the printed label shows two, depending on the range you selected; that difference can be intentional. Make the distinction clear when referring someone to a page. If the packet changes later, regenerate numbering from an appropriate unnumbered copy so you do not accumulate competing visible number labels.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "If the original authoring file is available and needs a complex numbering system, add it there. A document requiring chapter prefixes, mixed Roman and Arabic numbering, or a regenerated contents table needs a workflow beyond this tool’s numeric labels. If the task is document assembly, merge the parts before deciding the final numbering range."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can I leave the cover unnumbered?",
        "a": "Yes. Start the page range after the cover and set the starting number for the first included page."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "merge-pdf"
  },
  {
    "slug": "reverse-pdf",
    "kind": "tools",
    "title": "Reverse PDF page order on your Mac | DipperPDF",
    "h1": "Reverse PDF page order on your Mac",
    "query": "reverse pdf pages on mac",
    "description": "Reverses the complete page sequence. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To reverse PDF pages on a Mac, open Reverse Pages in DipperPDF, prepare the reversed copy, and save it as a new PDF. The file stays local with no uploads. The last page becomes the first, and the complete page sequence is reversed without changing page rotation.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "Some scanner outputs arrive in the opposite sequence from the intended reading order. Full reversal is useful when every page follows that backward sequence. Look at the first and last pages before processing; a file with just two misplaced pages needs a different kind of rearrangement than turning the whole sequence around."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the source document in Reverse Pages.",
          "Check the displayed original and reversed page order.",
          "Click Reverse Pages and inspect the prepared sequence.",
          "Save the separate result with Save PDF… and reopen it to confirm the endpoints."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The operation reverses every page in the PDF. It does not sort pages by printed page numbers, detect alternating scan errors, or rotate upside-down content. A one-page input has the same order after reversal. Page content and page rotation stay as they were while the page positions change."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Take a hypothetical four-page scan whose printed page numbers read four, three, two, one. Reverse the complete document. The prepared copy should read one, two, three, four. Inspect the intermediate pages rather than checking only the cover: reversal is useful only if the entire original sequence was backward. If one sheet is sideways after the ordering is corrected, process that saved copy with Rotate PDF."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Read the first several pages in the prepared result as well as the last ones. Reversal is a mechanical sequence change, so it cannot know whether an inserted cover should stay first or an appendix was already in the right order. A mixed packet may need a more deliberate assembly. Compare printed page labels with the intended reading sequence, and retain the backward source until you have checked that full reversal actually solves the scan-order problem.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Do not use full reversal when only part of the document is out of order, or when the scanner alternated front and back pages incorrectly. It also does not fix a backward sequence inside several independently ordered attachments. If you need to change the order of whole source documents, Merge PDFs provides file-order controls."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Does reversing change the orientation of pages?",
        "a": "No. Reverse Pages changes their positions in the sequence, keeping content and rotation the same."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "rotate-pdf"
  },
  {
    "slug": "metadata-pdf",
    "kind": "tools",
    "title": "Edit PDF metadata on your Mac | DipperPDF",
    "h1": "Edit PDF metadata on your Mac",
    "query": "edit pdf metadata on mac",
    "description": "Edits title, author, subject, and keywords. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To edit PDF metadata on a Mac, open Edit PDF Metadata in DipperPDF, update the title, author, subject, or keywords, and save a new PDF. Your document is processed locally without uploads. This changes document details rather than the visible text printed on its pages.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A PDF can carry a stale title or author even when the visible report is correct. Updating those details is useful before distributing a copy whose document properties should match its current purpose. Inspect the values loaded from the file, and decide which fields should be updated or left empty instead of assuming the filename supplies them."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the PDF in Edit PDF Metadata.",
          "Review and edit Title, Author, Subject, and Keywords.",
          "Click Edit PDF Metadata and compare the original and updated field values.",
          "Use Save PDF… to write a separate copy, then inspect its document properties."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Only the four exposed fields are edited. Empty values clear those fields, while attributes outside them are retained by the operation. Clearing metadata does not remove names printed on pages, embedded information elsewhere in the document, or every possible identifying attribute. It is not a complete privacy sanitization workflow."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose an exported proposal still has the title of an earlier draft and an author value from a template. Replace the title with the current proposal name, correct or clear the author, and enter a short subject if appropriate. Prepare the result and inspect the field comparison. Save the updated copy and check both its visible cover and its properties; the tool does not change the cover’s printed heading."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Reopen the saved copy and inspect its document properties, then compare the page appearance with the source. Keep the filename and the title property distinct in your reasoning: changing one does not necessarily change the other. If your aim is privacy, also inspect visible text, review comments, and images. The four editable fields cover only their own metadata values. An empty author field is useful evidence about that field, not evidence that every identifying detail has been removed.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "If you need to remove a name from the actual page, metadata editing will not do it. Use a supported redaction workflow for matching selectable text and review the entire output. If your distribution requirements demand a complete audit of embedded data or conformance to an archival standard, the four metadata controls are insufficient."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Does clearing the author field remove the author’s name from the page?",
        "a": "No. The author property and visible page text are separate. Metadata editing does not alter page content."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "redact-pdf"
  },
  {
    "slug": "text-pdf",
    "kind": "tools",
    "title": "Extract text from a PDF on your Mac | DipperPDF",
    "h1": "Extract text from a PDF on your Mac",
    "query": "extract text from pdf mac",
    "description": "Exports the existing selectable text in page order. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To extract text from a PDF on a Mac, open Extract Text in DipperPDF and save the document’s existing selectable text as a plain text file. Processing stays on your Mac without uploads. This tool exports a text layer; it does not recognize words in scanned images.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A PDF report may contain wording that you want to search, quote, or work with in a text editor. Check whether the words can already be selected in a PDF viewer. The distinction matters because a page can look like text while containing only a picture of printed paper. Extraction needs the underlying selectable text."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open one PDF in Extract Text.",
          "Click Extract Text to prepare the plain text result.",
          "Read the text preview and check the reading order against the PDF.",
          "Choose Save Text… and save the separate UTF-8 .txt file."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The output follows page order, with blank lines between pages. Layout and formatting are not preserved, and reading order within a page may vary. A document with no selectable text cannot provide an extracted text result. This is not PDF-to-Word conversion, table reconstruction, or OCR for scans."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Imagine a three-page project brief with two columns on one page. Extract its text and check where headings, paragraphs, and column transitions appear in the preview. Open the saved .txt file in a text editor and compare any quotation with the PDF before reusing it. The words may be present but organized differently from their visual layout. If a page is an image-only scan, obtain a text layer through another workflow first."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Check repeated headers, footers, and column transitions in the exported text. The PDF’s selectable text order can differ from the visual reading order, so a paragraph may need manual cleanup before reuse. Compare quotations with the page itself, including punctuation and line breaks. A scan with an existing text layer may also contain recognition mistakes from the process that originally produced it. DipperPDF exports that existing layer; it does not verify its accuracy against the visible image.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Use another tool if the job requires preserving fonts, page layout, tables, or an editable Word document. Use an OCR-capable workflow if the input is an image-only scan. If you need to give someone the original visual pages rather than their words, Extract Pages preserves those sheets in a PDF."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can it read a scanned PDF?",
        "a": "Only if that PDF already has selectable text. DipperPDF does not add OCR to an image-only scan."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "compare-pdf"
  },
  {
    "slug": "watermark-pdf",
    "kind": "tools",
    "title": "Add a watermark to a PDF on your Mac | DipperPDF",
    "h1": "Add a watermark to a PDF on your Mac",
    "query": "watermark pdf on mac",
    "description": "Adds a configurable text watermark to a page range. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To watermark a PDF on a Mac, open Add Watermark in DipperPDF, enter a text message, choose its appearance and page range, then save a separate PDF. Processing is local with no uploads. The watermark visibly labels the document; it does not encrypt the file or restrict access.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A review draft can benefit from a visible status such as DRAFT before it is circulated. Choose wording that accurately describes the document and a position that remains readable without obscuring important material. The purpose is communication: a visible label tells the reader about the copy’s status, but it is not an access-control mechanism."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the PDF in Add Watermark and enter the watermark text.",
          "Choose a position and adjust font size, opacity, and angle.",
          "Set the first and last page, then click Add Watermark.",
          "Inspect the marked pages and use Save PDF… to save the separate result."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The implemented watermark is text, not an uploaded logo or picture. The exposed controls change placement, size, opacity, angle, and a consecutive page range. The operation does not add a password, stop copying, or prove that the document is authentic. A visible confidentiality label should not be confused with redaction."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a draft contract needs DRAFT across the review copy. Enter that word, choose the intended position, and reduce opacity if the mark competes with the underlying paragraphs. Prepare the result and inspect the first page, a dense middle page, and the signature page. Adjust the settings if the mark hides wording that the reviewer needs. Save the labeled version under a name that keeps it distinct from the unmarked original."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Inspect pages with different layouts before accepting the appearance. A position that works on a mostly blank cover can interfere with a dense table later in the document. Check both portrait and landscape sheets if the file contains them. The page range defines where the mark is added, so confirm that any deliberately excluded sheets are really outside it. Choose wording that communicates the copy’s status accurately; the app cannot decide whether the underlying document is final or confidential.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "If the requirement is a logo watermark, a digital signature, or enforceable access restrictions, choose software that implements those features. If the task is to remove a confidential phrase before sharing, a watermark does not remove it. The Redact PDF page explains the available selectable-text workflow and its review requirements."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can I watermark only part of the document?",
        "a": "Yes. Set the first and last page to apply the text watermark to a consecutive range."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "redact-pdf"
  },
  {
    "slug": "crop-pdf",
    "kind": "tools",
    "title": "Crop a PDF on your Mac | DipperPDF",
    "h1": "Crop a PDF on your Mac",
    "query": "crop pdf on mac",
    "description": "Trims visible margins without deleting hidden content. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To crop a PDF on a Mac, open Crop PDF in DipperPDF, set margins and a page range, prepare the result, and save a separate copy. Nothing is uploaded. Cropping trims the visible edges; it does not delete the hidden text or images and must not be used as redaction.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A scan or exported slide can have broad margins that take up space around useful material. Cropping changes the visible window around that material. Before trimming, look for footnotes, labels, and page numbers near the edges. The margins should improve the presentation without hiding information that the reader needs."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open one PDF in Crop PDF.",
          "Enter nonnegative Top, Bottom, Left, and Right margins in points.",
          "Set the page range and click Crop PDF to prepare the result.",
          "Inspect the visible area on the selected pages, then save with Save PDF…."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The engine changes page crop bounds relative to the current visible edges, including rotated pages. Margins must leave a visible area on every selected page. Hidden content remains in the PDF and may be recoverable. The tool does not remove sensitive data, straighten scans, or convert the cropped pages into images."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a slide export has wide empty margins but small page numbers near the bottom. Trim the left and right edges first, then consider whether the top and bottom need adjustment. Prepare a copy and review every selected page, especially the page with the smallest footer. If a label disappears, reduce that margin and prepare again. Save the cropped result for presentation while retaining the original with its full visible area."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Look at edge content on every affected page. Headers, chart legends, handwritten notes, and page numbers can sit at different distances from the margins even within one report. A crop that suits the cover may hide useful material on another sheet. Reduce margins or narrow the consecutive page range if necessary. The fact that cropped text disappears from the viewer does not mean it has disappeared from the file, so never use the visible result alone as evidence of redaction.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Do not crop to hide an address, account number, or confidential paragraph. Use an actual redaction workflow suited to the document and inspect its output. Preview may already be sufficient for a simple crop. When the unwanted material occupies an entire sheet, Remove Pages addresses that job directly."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Is content outside the cropped area permanently removed?",
        "a": "No. Cropping hides content without deleting it. Hidden text or images may still be recoverable."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "redact-pdf"
  },
  {
    "slug": "annotations-pdf",
    "kind": "tools",
    "title": "Remove PDF annotations on your Mac | DipperPDF",
    "h1": "Remove PDF annotations on your Mac",
    "query": "remove pdf annotations on mac",
    "description": "Removes review markup while keeping links and form fields. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To remove PDF annotations on a Mac, choose Remove Annotations in DipperPDF, open the document, and save the prepared copy. Files stay on your Mac without uploads. The tool removes supported review markup from every page while keeping links and form fields; flattened marks remain part of the page.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A review PDF can accumulate comments, highlights, drawn shapes, and stamps that are no longer wanted in a clean reading copy. Distinguish review objects from the page’s actual artwork before processing. A highlight added by a reviewer and a colored rectangle printed by the author may look similar but be stored differently."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the PDF in Remove Annotations.",
          "Read the scope: supported review markup is removed across every page.",
          "Click Remove Annotations and inspect the prepared PDF.",
          "Use Save PDF… to save a separate copy and check the pages with the most markup."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Comments, highlights, text boxes, drawings, stamps, and other supported review annotation types are removed. Links and form fields are retained. Marks flattened into page content cannot be removed by this operation, and unfamiliar annotation types are preserved. The tool is not a way to erase all hidden information or rewrite page artwork."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Imagine a reviewed agreement with yellow highlights, margin comments, and a stamp on its final page. Prepare a copy with Remove Annotations and compare the formerly marked pages with the source. Check that the expected review marks disappeared and that useful links still behave as intended. If a colored mark remains because it is flattened into the page, the tool cannot identify and remove it as a separate review object."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Compare the clean copy with the review source on several representative pages. Check comments, highlights, drawn shapes, and stamps rather than assuming all marks use the same storage type. A remaining mark may be flattened page content or an annotation type the tool intentionally keeps. If you need to preserve particular reviewer notes, retain the annotated source as the record. The output is a separate clean-reading copy, and the operation does not decide which comments should be accepted as document revisions.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Use another workflow when you want to keep some comments while deleting only a chosen subset. This tool operates across the document. If the mark is embedded page content or a phrase needing redaction, annotation removal does not address that job. Preserve the review source if its comments are needed for the revision record."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Will it remove links or form fields?",
        "a": "The implementation keeps link and form-field annotations while removing the supported review markup types."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "metadata-pdf"
  },
  {
    "slug": "unlock-pdf",
    "kind": "tools",
    "title": "Unlock a PDF offline on your Mac | DipperPDF",
    "h1": "Unlock a PDF offline on your Mac",
    "query": "unlock pdf offline mac",
    "description": "Uses an authorized password to save an unencrypted copy. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To unlock a PDF offline on a Mac, open Unlock PDF in DipperPDF, supply the appropriate password, and save a separate unencrypted copy. Your file and password are processed locally without uploads. The tool checks copying and assembly permissions; it does not guess or crack a missing password.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "An encrypted document can be inconvenient when you need an authorized local copy for further page work. Establish that you have the password and permissions required by the file. Some PDFs open without asking for a password but still restrict copying or page assembly, so being able to read the pages is not always enough."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Choose Unlock PDF and open the encrypted document.",
          "Enter the password; leave the field blank only if the document opens without one.",
          "If copying or page assembly is restricted, supply the owner password required by the file.",
          "Click Unlock PDF, review the prepared copy, and use Save PDF… to save it separately."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "This tool accepts encrypted PDFs and creates an unencrypted copy when the password and permissions checks succeed. It does not recover forgotten passwords or add new protection. The original stays encrypted and unchanged. Other DipperPDF tools reject encrypted input, so an authorized unlocked copy can be used for subsequent local operations."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a password-protected report must be divided into smaller internal review packets. Open it in Unlock PDF and enter the supplied password. If the file also restricts assembly, obtain its owner password rather than assuming the opening password grants that permission. Save the unlocked copy to the intended local destination, then import that copy into Split PDF. Keep the encrypted source as the original record."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "After saving, reopen the unencrypted copy and confirm that it is the intended document. Remember that the original remains encrypted while the new file has different protection. Choose local storage and sharing destinations appropriate to that change. If a later DipperPDF tool still rejects the file, check that you imported the saved unlocked output rather than the original. Supplying a password authorizes the processing permitted by the PDF; it does not turn the tool into password recovery.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "DipperPDF is a poor fit when you do not have the needed password or when the objective is to create a newly password-protected PDF. Unlocking also changes the protection of the saved copy, so choose its destination deliberately. A document that must remain encrypted throughout a different editing workflow needs software that supports that workflow."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Does Unlock PDF recover a forgotten password?",
        "a": "No. It uses the password and permissions needed to open and assemble an authorized unencrypted copy."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "split-pdf"
  },
  {
    "slug": "repair-pdf",
    "kind": "tools",
    "title": "Repair a readable PDF on your Mac | DipperPDF",
    "h1": "Repair a readable PDF on your Mac",
    "query": "repair pdf on mac",
    "description": "Rebuilds a PDF from the pages macOS can already read. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To try repairing a PDF on a Mac, open Repair PDF in DipperPDF and rebuild a copy from the pages macOS can already read. The document stays local without uploads. This is a best-effort structure rewrite: it cannot recover missing content or pages that the PDF reader cannot open.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A PDF may be readable while having structural problems that interfere with another workflow. Rebuilding its readable pages can be worth trying when a new copy is acceptable. Keep the source and establish which pages are supposed to be present. A readable preview is a prerequisite, not proof that missing material can be reconstructed."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Choose Repair PDF and open the readable PDF.",
          "Read the limitations before preparing a rebuilt copy.",
          "Click Repair PDF and inspect the result page by page.",
          "Save the separate output with Save PDF… and try it in the workflow that had trouble."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Repair depends on what macOS can read. The app rebuilds a document from those readable pages and checks that its serialized result retains the page count. Missing or unreadable content cannot be restored. Bookmarks, forms, and other document features may change, and digital signatures will no longer be valid on the rewritten copy."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Consider a readable report that another viewer has difficulty handling. Open it in Repair PDF, prepare the new copy, and compare its page count and visual content with the source. Check the diagrams and the last page as well as the cover. Save the rebuilt version and reopen it in the destination viewer. If the problem persists, obtain a fresh export from the document’s author instead of treating repeated rewrites as recovery."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Check page count, text, diagrams, and any interactive features you rely on. A successful rewrite means the app produced a readable copy with the expected pages, not that it certified every aspect of the PDF. Try the saved file in the reader or workflow that originally had trouble. If the source contains forms or signed content, preserve it for comparison and do not assume the rewritten file carries the same behavior or validity. Ask for a fresh export when recovery is uncertain.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Do not use this as a promise of recovering a PDF that cannot be opened or content that has already disappeared. If valid digital signatures or complex form behavior must survive unchanged, a page rebuild is unsuitable. For an archival or official record, retain the original and use a fresh authoritative export when available."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Can it recover pages that cannot be read?",
        "a": "No. Repair PDF rebuilds only the pages macOS can already read; it cannot restore missing or unreadable content."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "compare-pdf"
  },
  {
    "slug": "compare-pdf",
    "kind": "tools",
    "title": "Compare PDF text on your Mac | DipperPDF",
    "h1": "Compare PDF text on your Mac",
    "query": "compare pdf text on mac",
    "description": "Compares selectable text in numbered page pairs. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To compare PDF text on a Mac, open Compare PDF in DipperPDF, add the original and revised documents, and save a report of selectable-text changes. Processing stays local without uploads. Pages are paired by number; the report identifies added and removed lines, not visual changes to images or layout.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "Two versions of a contract can look similar while their wording differs. A text report helps locate additions and removals for closer review. Make sure both documents contain selectable text and that page numbering is reasonably aligned. Adding an early page can shift later page pairs, because this comparison does not semantically match sections across the documents."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Choose Compare PDF and add the original first, then the revised PDF.",
          "Check their roles; use Swap original and revised if needed.",
          "Click Compare PDF and review the changed page pairs, added lines, removed lines, and missing-text notices.",
          "Use Save PDF… to save the separate comparison report."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "The comparison uses selectable text and pairs pages by position. PDF text order and line breaks affect the report. Images, formatting, and metadata are not compared. Pages without selectable text are flagged for review; scanned images need OCR before their text could be compared, and DipperPDF does not provide that OCR step."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose two contract drafts have the same page count and one clause changes on page three. Add the earlier version as Original and the later one as Revised. Prepare the report and read the removed and added lines for that page pair. Return to the actual PDFs to assess the change in context. If a diagram changed without its text changing, inspect it visually because the text report will not cover that difference."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Read differences in the context of both source PDFs. The report’s plus and minus lines are a starting point for review rather than an interpretation of contractual meaning. If the revised document inserts a page early on, later positional pairs can contain large differences that reflect the shift. Check the missing-text notices even if there are few added lines. A page containing only an image can change significantly without supplying any selectable words for the report to compare.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Use a visual comparison workflow when image placement, formatting, or drawing revisions are the main concern. Use another workflow when scan recognition or section-aware page matching is required. A report showing no text additions does not establish that the files are identical or that every meaningful change has been checked."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Does it compare images and formatting?",
        "a": "No. Compare PDF reports changes to selectable text. Images, formatting, and metadata need separate review."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "text-pdf"
  },
  {
    "slug": "redact-pdf",
    "kind": "tools",
    "title": "Redact PDF text offline on your Mac | DipperPDF",
    "h1": "Redact PDF text offline on your Mac",
    "query": "redact pdf offline mac",
    "description": "Finds selectable text and rebuilds a blacked-out image-only copy. Process PDFs locally on Mac without uploads. Free and open source; save a separate result.",
    "intro": "To redact PDF text offline on a Mac, use Redact PDF in DipperPDF to find selectable text or supported patterns, then save an image-only copy with matching regions blacked out. The document stays on your Mac without uploads. Review every page: patterns can miss sensitive material, and scanned images are not searched.",
    "sections": [
      {
        "heading": "When you need this",
        "paragraphs": [
          "A sharing copy may need contact details or a specific phrase removed from readable page text. Identify what must be removed, which pages need checking, and whether the words are selectable. A visible black rectangle alone is not enough: this implementation creates a fresh image-only output from sanitized pixels rather than leaving original text under a drawn overlay."
        ]
      },
      {
        "heading": "How to do it in DipperPDF",
        "paragraphs": [
          "Download the DMG from GitHub Releases, open it, drag DipperPDF into Applications, and launch the app from there. The app’s README specifies macOS 14 or later. Downloading the app requires a connection, but the PDF operation works offline once the app is installed. You do not need an account, subscription, trial, or paid upgrade to use the tool."
        ],
        "steps": [
          "Open the PDF in Redact PDF and choose the page range to search.",
          "Enter a word or phrase, choose case matching, or enable email, phone, or credit-card-number patterns.",
          "Click Redact PDF and inspect the reported text-match count and prepared pages.",
          "Review every output page for missed information and readability, then save the separate copy with Save PDF…."
        ]
      },
      {
        "heading": "What it does not do",
        "paragraphs": [
          "Matches come from selectable text. Image-only scans are not searched, and the app does not run OCR. Patterns can miss unusual formats or match unrelated numbers; names, expiry dates, and card security codes are not automatically detected. The entire output is image-only at 144 dpi, losing selectable text and interactive document features. This is not a guarantee that all sensitive material has been found."
        ]
      },
      {
        "heading": "A worked example",
        "paragraphs": [
          "Suppose a sample agreement has an email address on the cover and the same contact detail in a later paragraph. Search the relevant page range with the email pattern, then inspect both locations and every other page. Check for a handwritten address in an image, which the search will not detect. Save the redacted copy only after review; keep the source separate because the new image-only version no longer has the original text layer."
        ]
      },
      {
        "heading": "Check the result before sharing",
        "paragraphs": [
          "Inspect every output page at a readable zoom, including pages outside the selected search range. Search settings determine which text matches are covered, but sensitive material can appear as a picture, an unusual number format, or a phrase you did not enter. Match counts describe detected matches; they do not certify completeness. The image-only output also changes searchability and interactive behavior throughout the document. If that tradeoff is unacceptable, use a different redaction workflow rather than sending the original with a cosmetic overlay.",
          "Preparing a result and saving it are separate steps. Use the prepared view to check the outcome before choosing a destination. Save under a descriptive name in a writable local folder, then reopen the saved output to check that you chose the intended result. DipperPDF saves a separate file and prevents overwriting an imported source. Keeping the original gives you a starting point if a selection or setting needs correction."
        ]
      },
      {
        "heading": "When not to use DipperPDF for this job",
        "paragraphs": [
          "Choose another workflow if sensitive information lives only inside images, you need manual region selection, or the output must keep searchable text and forms. Pattern matching is also insufficient when a document requires expert review of every identifier. Cropping, watermarking, and clearing metadata do not substitute for checking the actual page information."
        ]
      },
      {
        "heading": "If the document needs another operation",
        "paragraphs": [
          "If another operation is needed, save this result and import that saved copy into the next tool. There is no automatic chain of tasks here. Make the order deliberate: changing the page count or sequence can change which pages a later range refers to. When an input is encrypted, use Unlock PDF first with the password and permissions required by the document, then work with the authorized unencrypted copy."
        ]
      }
    ],
    "faq": [
      {
        "q": "Will the redacted output keep selectable text?",
        "a": "No. DipperPDF rebuilds the entire PDF as sanitized page images at 144 dpi. Review the result for both missed information and lost features."
      },
      {
        "q": "Does this operation upload my document?",
        "a": "No. DipperPDF processes PDFs on your Mac and works offline. The native app has no account or in-app tracking. Downloading the DMG and opening this website require internet access; those are separate from processing your document."
      },
      {
        "q": "Will my original file change?",
        "a": "No. Save the result as a separate output. The app prevents saving over an imported source. Keep the original and review the saved copy before using it as a replacement or sharing it with someone else."
      }
    ],
    "related": "metadata-pdf"
  },
  {
    "slug": "ilovepdf-alternative-mac",
    "kind": "compare",
    "query": "ilovepdf alternative mac",
    "h1": "An iLovePDF alternative for local PDF work on Mac",
    "title": "iLovePDF alternative for Mac | DipperPDF",
    "description": "Compare iLovePDF’s upload workflow with a free native Mac toolkit. Merge, split, compress, and more locally, with clear limits.",
    "intro": "For an iLovePDF alternative on a Mac, DipperPDF handles everyday PDF operations locally: merge, split, compress, remove or extract pages, and more. Files are not uploaded, and the installed app works offline. It fits PDF-to-PDF tasks; it does not replace conversion, OCR, signing, or every other capability in a broader PDF service.",
    "sections": [
      {
        "heading": "The difference is the file workflow",
        "paragraphs": [
          "This comparison covers the iLovePDF website. Its security page describes uploaded files and cloud processing; that is a different workflow from opening a local document in DipperPDF. The same site also links a desktop product, so the website comparison should not be read as a claim about every iLovePDF app.",
          "If your requirement is that the source PDF never be uploaded for processing, choose an operation that runs locally. In DipperPDF, the PDF processing engine runs on the Mac. No account is needed, and there is no in-app tracking. Those facts concern the native toolkit; downloading the app and browsing a website are separate activities."
        ],
        "sources": [
          {
            "label": "iLovePDF security and product links, checked October 11, 2026",
            "url": "https://www.ilovepdf.com/help/security"
          }
        ]
      },
      {
        "heading": "Jobs the local app can handle",
        "paragraphs": [
          "Use Merge PDFs to combine finished documents, Split PDF to create fixed-page-count parts, and Compress PDF for image-heavy attachments. Extract Pages keeps chosen sheets; Remove Pages discards chosen sheets while preserving the remaining order. Rotate PDF changes page orientation, while Reverse Pages reverses the complete sequence.",
          "Other implemented jobs include page numbering, text watermarks, cropping visible edges, removing supported annotations, editing four metadata fields, unlocking with the appropriate password, extracting selectable text, rebuilding readable PDFs, comparing selectable text, and redacting matching selectable text into an image-only copy. Check each tool’s limits rather than treating that list as a full editor."
        ],
        "links": [
          {
            "label": "Merge PDFs offline",
            "href": "/tools/merge-pdf"
          },
          {
            "label": "Compress a PDF locally",
            "href": "/tools/compress-pdf"
          }
        ]
      },
      {
        "heading": "A worked decision: assemble a review packet",
        "paragraphs": [
          "Suppose the task is to combine a cover note, an agreement, and an appendix without sending those files to a processing website. In DipperPDF, open Merge PDFs, add the finished PDFs, and put the cover first. Prepare the combined result and review the transitions before saving. If page numbers are needed, import the saved combined copy into Add Page Numbers.",
          "If the task changes to converting the agreement into Word for rewriting, the decision changes too. DipperPDF does not implement that conversion. Local processing is useful only when the local tool also produces the output you need. Do not choose a merge tool and expect it to reconstruct an editable authoring document."
        ]
      },
      {
        "heading": "When DipperPDF is the worse choice",
        "paragraphs": [
          "DipperPDF is a worse choice when you are not on a Mac, cannot install a native app, or need an unimplemented conversion. The iLovePDF website lists Office conversion, OCR, protection, and signing in addition to shared PDF jobs. That wider list matters if one of those capabilities is your actual task.",
          "It is also a worse choice if the available redaction method is unsuitable: its text search needs selectable words and its output is image-only. For a task requiring editable page text, preserved interactive forms, or scan recognition, choose a workflow that expressly supports those needs."
        ],
        "sources": [
          {
            "label": "iLovePDF current tool navigation",
            "url": "https://www.ilovepdf.com/help/security"
          }
        ]
      },
      {
        "heading": "Start with the operation you actually need",
        "paragraphs": [
          "Describe the job as an input and an output before choosing software. For example, two finished PDFs becoming one document is a merge job; an existing report becoming a plain text file is text extraction. A phrase such as “PDF editing” can also mean changing a paragraph, completing a form, or converting a file, which are different capabilities. DipperPDF should be selected for an implemented operation, rather than assumed to cover every meaning of editing.",
          "If the input is encrypted, Unlock PDF is the dedicated entry point and requires the password and permissions needed by the document. Save an authorized unencrypted copy before using another tool. When several operations are needed, save each result and import that copy into the next tool. Page selection and range settings refer to the document being opened at that step, so assembly and numbering order deserve attention."
        ]
      },
      {
        "heading": "Check a representative document",
        "paragraphs": [
          "Use a non-sensitive example that resembles your real file before settling on a workflow. Include the features you care about: images, dense footers, selectable text, or review markup. Prepare the result and reopen the saved file. Check the pages at the boundaries of a selection and confirm the output format. A successful operation on one example is evidence about that example, not a promise about every unusual PDF.",
          "DipperPDF saves results separately and keeps imported originals unchanged. Retain the source when exact document structure or advanced features matter. A rewritten PDF can behave differently from its source, and the visible page is only one part of a document. Choose the smallest operation that solves the task, then inspect the result for that purpose."
        ]
      },
      {
        "heading": "Download and inspect the local toolkit",
        "paragraphs": [
          "DipperPDF is free and open source, with no account, subscription, trial period, or paid upgrade. Get the DMG from GitHub Releases, drag the app into Applications, and open it on your Mac. The repository specifies macOS 14 or later. Downloading requires internet access; using the installed PDF tools works offline. You can read the source on GitHub to examine the app’s local processing and separate-output behavior."
        ]
      }
    ],
    "table": {
      "other": "iLovePDF website",
      "rows": [
        [
          "Where the file goes",
          "Stays on the Mac",
          "Uploaded for website processing"
        ],
        [
          "Offline",
          "Yes, after installation",
          "Website workflow uses online processing"
        ],
        [
          "Tools that overlap",
          "Merge, split, compress, rotate, extract and remove pages",
          "These jobs appear in the current tool list"
        ],
        [
          "Worse fit",
          "Non-Mac use or missing conversion/OCR/signing",
          "An upload workflow conflicts with a no-upload requirement"
        ]
      ],
      "source": {
        "label": "iLovePDF security and tool list",
        "url": "https://www.ilovepdf.com/help/security"
      }
    },
    "related": "merge-pdf"
  },
  {
    "slug": "smallpdf-alternative-offline",
    "kind": "compare",
    "query": "smallpdf alternative offline",
    "h1": "An offline Smallpdf alternative for PDF tasks on Mac",
    "title": "Smallpdf alternative offline on Mac | DipperPDF",
    "description": "Use a free native Mac app for offline PDF tasks. Compare DipperPDF with Smallpdf’s web workflow and see which jobs need another tool.",
    "intro": "If you need a Smallpdf alternative offline on a Mac, DipperPDF runs its implemented PDF tools locally without uploads or an account. It can merge, split, compress, and organize PDFs after installation. It does not provide Office conversion, OCR, or signing. This comparison covers Smallpdf’s web tools and distinguishes its separate offline product.",
    "sections": [
      {
        "heading": "Compare the web workflow with an installed app",
        "paragraphs": [
          "Smallpdf’s current merge page instructs users to upload files and describes cloud-based processing. It also points to a Windows app for offline work. DipperPDF supplies a native Mac workflow, so the distinction is where this particular operation runs, not a blanket assertion that Smallpdf never has offline options.",
          "A no-upload requirement is easiest to assess at the operation level. In DipperPDF, open the document from your Mac and prepare the result locally. You can disconnect after installation and still use the tools. The native app needs no login or in-app tracking. A website’s privacy policy and a local processing boundary answer different questions."
        ],
        "sources": [
          {
            "label": "Smallpdf merge workflow and offline Windows option, checked October 11, 2026",
            "url": "https://smallpdf.com/merge-pdf"
          }
        ]
      },
      {
        "heading": "Choose a matching local operation",
        "paragraphs": [
          "Merge PDFs combines complete input documents in the order you choose. Split PDF makes fixed-size groups of consecutive pages. Compress PDF uses three image-compression settings and avoids offering a larger result when the source is already optimized. These are different outputs, so choose according to the job rather than the name of the service you used previously.",
          "The toolkit also supports selective extraction or removal, right-angle rotation, full page reversal, visible numbering, text watermarks, margin cropping, review-markup removal, metadata editing, authorized unlocking, text extraction, readable-PDF repair, selectable-text comparison, and text-search redaction. None of those names should be stretched into an unsupported conversion or scan-recognition claim."
        ],
        "links": [
          {
            "label": "Split a PDF offline",
            "href": "/tools/split-pdf"
          },
          {
            "label": "Compress a PDF offline",
            "href": "/tools/compress-pdf"
          }
        ]
      },
      {
        "heading": "A worked decision: an image-heavy attachment",
        "paragraphs": [
          "Suppose a slide deck has large photographs and needs a smaller sharing copy. Open Compress PDF in DipperPDF, choose Balanced, and prepare the result. Compare the sizes and inspect small labels within the images. If the detail is acceptable, save the new file. If the original is already optimized, the result may stay the same size.",
          "If size is still a problem and the recipient can accept several documents, save fixed-page-count parts with Split PDF. Check the boundaries so a table or section is not unintentionally hard to read. This sequence solves a local attachment problem without assuming a guaranteed compression percentage or identical sizes across the parts."
        ]
      },
      {
        "heading": "When DipperPDF is the worse choice",
        "paragraphs": [
          "Smallpdf’s current tool collection includes Office conversion, OCR, forms, and signing. DipperPDF does not implement those jobs, so it is a worse choice when they are the reason you opened a PDF service. It is also a worse fit if you need a browser workflow or do not have a Mac available.",
          "Do not confuse plain text extraction with Word conversion. DipperPDF exports existing selectable text as .txt and does not preserve the document layout. Similarly, its comparison report covers selectable words rather than image and formatting changes. Use the tool pages to check the exact result before deciding that a local substitute covers your whole workflow."
        ],
        "sources": [
          {
            "label": "Smallpdf current tools",
            "url": "https://smallpdf.com/pdf-tools"
          }
        ]
      },
      {
        "heading": "Start with the operation you actually need",
        "paragraphs": [
          "Describe the job as an input and an output before choosing software. For example, two finished PDFs becoming one document is a merge job; an existing report becoming a plain text file is text extraction. A phrase such as “PDF editing” can also mean changing a paragraph, completing a form, or converting a file, which are different capabilities. DipperPDF should be selected for an implemented operation, rather than assumed to cover every meaning of editing.",
          "If the input is encrypted, Unlock PDF is the dedicated entry point and requires the password and permissions needed by the document. Save an authorized unencrypted copy before using another tool. When several operations are needed, save each result and import that copy into the next tool. Page selection and range settings refer to the document being opened at that step, so assembly and numbering order deserve attention."
        ]
      },
      {
        "heading": "Check a representative document",
        "paragraphs": [
          "Use a non-sensitive example that resembles your real file before settling on a workflow. Include the features you care about: images, dense footers, selectable text, or review markup. Prepare the result and reopen the saved file. Check the pages at the boundaries of a selection and confirm the output format. A successful operation on one example is evidence about that example, not a promise about every unusual PDF.",
          "DipperPDF saves results separately and keeps imported originals unchanged. Retain the source when exact document structure or advanced features matter. A rewritten PDF can behave differently from its source, and the visible page is only one part of a document. Choose the smallest operation that solves the task, then inspect the result for that purpose."
        ]
      },
      {
        "heading": "Download and inspect the local toolkit",
        "paragraphs": [
          "DipperPDF is free and open source, with no account, subscription, trial period, or paid upgrade. Get the DMG from GitHub Releases, drag the app into Applications, and open it on your Mac. The repository specifies macOS 14 or later. Downloading requires internet access; using the installed PDF tools works offline. You can read the source on GitHub to examine the app’s local processing and separate-output behavior."
        ]
      }
    ],
    "table": {
      "other": "Smallpdf web tools",
      "rows": [
        [
          "Where the file goes",
          "Stays on the Mac",
          "Merge page describes upload and cloud processing"
        ],
        [
          "Offline",
          "Yes, after installation",
          "Web workflow is online; separate Windows app is offered"
        ],
        [
          "Tools that overlap",
          "Merge, split, compress, rotate, extract and remove pages",
          "Listed in the current web tool collection"
        ],
        [
          "Worse fit",
          "Browser use, conversion, OCR, or signing",
          "Web upload workflow conflicts with a no-upload requirement"
        ]
      ],
      "source": {
        "label": "Smallpdf merge workflow",
        "url": "https://smallpdf.com/merge-pdf"
      }
    },
    "related": "compress-pdf"
  },
  {
    "slug": "adobe-acrobat-alternative-free-mac",
    "kind": "compare",
    "query": "free adobe acrobat alternative mac",
    "h1": "A free Acrobat alternative for everyday PDF jobs on Mac",
    "title": "Free Adobe Acrobat alternative for Mac | DipperPDF",
    "description": "DipperPDF covers specific everyday PDF jobs for free on Mac. See the overlap with Acrobat and where a full editor remains necessary.",
    "intro": "For a free Adobe Acrobat alternative on a Mac, DipperPDF covers specific everyday PDF jobs: merging, splitting, compression, page changes, and other implemented tools. It is a local toolkit with no uploads or account. It is not a full replacement for Acrobat’s page-text editing, signing, conversion, or broader document workflows.",
    "sections": [
      {
        "heading": "A toolkit can replace a job, not every editor feature",
        "paragraphs": [
          "Adobe’s feature page lists text and image editing, merging, splitting, page organization, rotation, cropping, conversion, and signing. The overlap makes a comparison useful, but the difference in scope is substantial. Select DipperPDF if its operation matches the task; do not interpret “alternative” as feature equivalence.",
          "DipperPDF runs natively on a Mac, processes documents locally, and saves separate outputs. The repository is available for inspection. This is not a claim that Acrobat desktop always uploads documents: Adobe has several products and workflows. The practical question is whether your particular job needs a full editor or a smaller local operation."
        ],
        "sources": [
          {
            "label": "Adobe Acrobat features, checked October 11, 2026",
            "url": "https://www.adobe.com/acrobat/features.html"
          }
        ]
      },
      {
        "heading": "The meaningful overlapping jobs",
        "paragraphs": [
          "For assembly, DipperPDF can merge finished PDFs, split a source into regular page groups, extract selected sheets, remove unwanted sheets, or rotate pages. Its cropping changes the visible margins. Compression focuses on image data and does not promise a fixed percentage reduction. These are concrete outputs you can inspect before saving.",
          "Other available tools add visible page numbers or text watermarks, remove supported annotations, edit four metadata fields, unlock with the required password, extract existing text, reverse the page sequence, repair readable structure, compare selectable text, and redact matching text into page images. The comparison and redaction methods have narrower scope than a general editor label might suggest."
        ],
        "links": [
          {
            "label": "Compare selectable PDF text",
            "href": "/tools/compare-pdf"
          },
          {
            "label": "Redact PDF text locally",
            "href": "/tools/redact-pdf"
          }
        ]
      },
      {
        "heading": "A worked decision: compare two contract drafts",
        "paragraphs": [
          "Suppose two contract PDFs have matching page positions and selectable text. Open Compare PDF, add the earlier version as Original and the later one as Revised, then prepare the report. Read the added and removed lines, and open the source PDFs to interpret each change in context. The report is saved as a separate PDF.",
          "That workflow can support a text review, but it does not compare the signature images, formatting, or metadata. If the revision inserted an early page, later numbered page pairs may no longer represent corresponding sections. Decide whether positional text comparison is adequate rather than treating a short report as proof that every difference was found."
        ]
      },
      {
        "heading": "When DipperPDF is the worse choice",
        "paragraphs": [
          "DipperPDF is the worse choice when you need to edit existing paragraph text on the page, sign documents, fill forms, convert to an Office format, or work on Windows. Those are outside the implemented toolkit. Adobe’s broader feature set includes editing, conversion, and signing, so a full editor may be the appropriate category.",
          "It is also a poor substitute when redaction must retain searchable text or interactive features. DipperPDF’s redaction searches selectable text and writes an image-only PDF; its patterns can miss material. If your requirements demand another method or a specialized review process, choose that workflow. Preserve signed originals, because rewriting a document can invalidate signatures."
        ],
        "sources": [
          {
            "label": "Adobe editing, conversion, and signing features",
            "url": "https://www.adobe.com/acrobat/features.html"
          }
        ]
      },
      {
        "heading": "Start with the operation you actually need",
        "paragraphs": [
          "Describe the job as an input and an output before choosing software. For example, two finished PDFs becoming one document is a merge job; an existing report becoming a plain text file is text extraction. A phrase such as “PDF editing” can also mean changing a paragraph, completing a form, or converting a file, which are different capabilities. DipperPDF should be selected for an implemented operation, rather than assumed to cover every meaning of editing.",
          "If the input is encrypted, Unlock PDF is the dedicated entry point and requires the password and permissions needed by the document. Save an authorized unencrypted copy before using another tool. When several operations are needed, save each result and import that copy into the next tool. Page selection and range settings refer to the document being opened at that step, so assembly and numbering order deserve attention."
        ]
      },
      {
        "heading": "Check a representative document",
        "paragraphs": [
          "Use a non-sensitive example that resembles your real file before settling on a workflow. Include the features you care about: images, dense footers, selectable text, or review markup. Prepare the result and reopen the saved file. Check the pages at the boundaries of a selection and confirm the output format. A successful operation on one example is evidence about that example, not a promise about every unusual PDF.",
          "DipperPDF saves results separately and keeps imported originals unchanged. Retain the source when exact document structure or advanced features matter. A rewritten PDF can behave differently from its source, and the visible page is only one part of a document. Choose the smallest operation that solves the task, then inspect the result for that purpose."
        ]
      },
      {
        "heading": "Download and inspect the local toolkit",
        "paragraphs": [
          "DipperPDF is free and open source, with no account, subscription, trial period, or paid upgrade. Get the DMG from GitHub Releases, drag the app into Applications, and open it on your Mac. The repository specifies macOS 14 or later. Downloading requires internet access; using the installed PDF tools works offline. You can read the source on GitHub to examine the app’s local processing and separate-output behavior."
        ]
      }
    ],
    "table": {
      "other": "Adobe Acrobat",
      "rows": [
        [
          "Where the file goes",
          "Processed locally on the Mac",
          "Depends on the chosen Adobe product and workflow"
        ],
        [
          "Tools that overlap",
          "Merge, split, rotate, crop, page organization",
          "Listed on Adobe’s feature page"
        ],
        [
          "Worse fit",
          "Page-text editing, signing, Office conversion, or Windows",
          "Broader editor scope may exceed a simple task"
        ]
      ],
      "source": {
        "label": "Adobe Acrobat feature scope",
        "url": "https://www.adobe.com/acrobat/features.html"
      }
    },
    "related": "compare-pdf"
  },
  {
    "slug": "preview-app-pdf-tools",
    "kind": "compare",
    "query": "mac preview pdf tools limits",
    "h1": "Mac Preview PDF tools: when they are enough",
    "title": "Mac Preview PDF tools and limits | DipperPDF",
    "description": "Preview already handles many Mac PDF jobs. Compare it with DipperPDF’s focused tools and choose according to the output you need.",
    "intro": "Mac Preview already combines PDFs, rotates pages, and adds markup, so many simple PDF jobs need no additional app. DipperPDF is useful when you want an implemented focused operation such as whole-document page reversal, configurable text watermarking, metadata editing, or a selectable-text comparison report. Both can be part of a local Mac workflow.",
    "sections": [
      {
        "heading": "Begin with the tools already on your Mac",
        "paragraphs": [
          "Apple documents combining PDFs and annotating a PDF in Preview. Its user guide also lists cropping, rotation, and file-size reduction. Do not assume that needing one of those jobs automatically means Preview is insufficient. For a one-page markup, Preview may already be the simplest tool you know how to use."
        ],
        "sources": [
          {
            "label": "Apple: combine PDFs in Preview",
            "url": "https://support.apple.com/guide/preview/combine-pdfs-prvw43696/mac"
          },
          {
            "label": "Apple: annotate a PDF in Preview",
            "url": "https://support.apple.com/guide/preview/annotate-a-pdf-prvw11580/mac"
          },
          {
            "label": "Apple Preview user guide",
            "url": "https://support.apple.com/guide/preview/welcome/mac"
          }
        ],
        "links": [
          {
            "label": "DipperPDF’s merge workflow",
            "href": "/tools/merge-pdf"
          },
          {
            "label": "DipperPDF’s rotation workflow",
            "href": "/tools/rotate-pdf"
          }
        ]
      },
      {
        "heading": "Where a focused operation can help",
        "paragraphs": [
          "DipperPDF offers a complete-sequence Reverse Pages tool: the last page becomes the first without changing page rotation. Add Watermark exposes text, placement, opacity, angle, and a page range. Edit PDF Metadata exposes title, author, subject, and keywords. These are specific operations, not a claim that Preview has no way to achieve any related result.",
          "For compression, DipperPDF offers Light, Balanced, and Strong and keeps the original bytes when recompression would enlarge the output. Remove Annotations clears supported review markup across the document while retaining links and form fields. Compare PDF generates a selectable-text report. Repair PDF rebuilds only readable pages, and Redact PDF produces an image-only copy from found text matches."
        ],
        "links": [
          {
            "label": "Reverse the complete page order",
            "href": "/tools/reverse-pdf"
          },
          {
            "label": "Add a configurable text watermark",
            "href": "/tools/watermark-pdf"
          }
        ]
      },
      {
        "heading": "A worked decision: fix a backwards scan",
        "paragraphs": [
          "Imagine a scanner created a six-page PDF in the sequence six, five, four, three, two, one. In DipperPDF, Reverse Pages performs the full reversal as one operation. Review the complete prepared sequence and save a separate copy. If one page is also sideways, import the saved reversed copy into Rotate PDF and turn that page.",
          "The important decision is whether full reversal is actually the right transformation. A packet whose cover is correct but whose appendix is reversed has a different structure. The tool does not detect chapter boundaries or reason about printed page numbers. Keep the source until you have confirmed that the new sequence matches the intended reading order."
        ]
      },
      {
        "heading": "When DipperPDF is the worse choice",
        "paragraphs": [
          "For a quick note or highlight on one page, Preview is the better fit: Apple documents those markup controls, while DipperPDF is a processing toolkit and does not implement adding review annotations. If you already know Preview’s workflow for the job, another installation may not help.",
          "Preview also documents filling and signing forms. DipperPDF does not implement either capability. When that is the task, use a supported form or signing workflow. For changing existing page text or performing unsupported conversion, choose the appropriate editor rather than assuming either toolkit name guarantees the output you need."
        ],
        "sources": [
          {
            "label": "Apple markup instructions",
            "url": "https://support.apple.com/guide/preview/annotate-a-pdf-prvw11580/mac"
          },
          {
            "label": "Apple Preview form and signing overview",
            "url": "https://support.apple.com/guide/preview/welcome/mac"
          }
        ]
      },
      {
        "heading": "Keep presentation changes separate from data removal",
        "paragraphs": [
          "DipperPDF’s Crop PDF changes what is visible without deleting hidden content. Metadata editing affects four properties, and annotation removal affects supported markup objects. None of those operations alone establishes that a PDF is safe to disclose. If redaction is needed, read the dedicated tool’s selectable-text and image-only-output limits, and review every page before sharing."
        ]
      },
      {
        "heading": "Start with the operation you actually need",
        "paragraphs": [
          "Describe the job as an input and an output before choosing software. For example, two finished PDFs becoming one document is a merge job; an existing report becoming a plain text file is text extraction. A phrase such as “PDF editing” can also mean changing a paragraph, completing a form, or converting a file, which are different capabilities. DipperPDF should be selected for an implemented operation, rather than assumed to cover every meaning of editing.",
          "If the input is encrypted, Unlock PDF is the dedicated entry point and requires the password and permissions needed by the document. Save an authorized unencrypted copy before using another tool. When several operations are needed, save each result and import that copy into the next tool. Page selection and range settings refer to the document being opened at that step, so assembly and numbering order deserve attention."
        ]
      },
      {
        "heading": "Check a representative document",
        "paragraphs": [
          "Use a non-sensitive example that resembles your real file before settling on a workflow. Include the features you care about: images, dense footers, selectable text, or review markup. Prepare the result and reopen the saved file. Check the pages at the boundaries of a selection and confirm the output format. A successful operation on one example is evidence about that example, not a promise about every unusual PDF.",
          "DipperPDF saves results separately and keeps imported originals unchanged. Retain the source when exact document structure or advanced features matter. A rewritten PDF can behave differently from its source, and the visible page is only one part of a document. Choose the smallest operation that solves the task, then inspect the result for that purpose."
        ]
      },
      {
        "heading": "Download and inspect the local toolkit",
        "paragraphs": [
          "DipperPDF is free and open source, with no account, subscription, trial period, or paid upgrade. Get the DMG from GitHub Releases, drag the app into Applications, and open it on your Mac. The repository specifies macOS 14 or later. Downloading requires internet access; using the installed PDF tools works offline. You can read the source on GitHub to examine the app’s local processing and separate-output behavior."
        ]
      }
    ],
    "table": {
      "other": "Apple Preview",
      "rows": [
        [
          "Where the file goes",
          "Local Mac processing",
          "Local Mac app workflow"
        ],
        [
          "Offline",
          "Yes, after installation",
          "Local PDF operations"
        ],
        [
          "Tools that overlap",
          "Merge, rotate, crop, compress",
          "Apple documents these operations"
        ],
        [
          "Worse fit",
          "One-page markup, form filling, or signing",
          "Choose according to the particular focused operation"
        ]
      ],
      "source": {
        "label": "Apple Preview user guide",
        "url": "https://support.apple.com/guide/preview/welcome/mac"
      }
    },
    "related": "reverse-pdf"
  },
  {
    "slug": "edit-pdf-without-uploading",
    "kind": "guides",
    "query": "edit pdf without uploading",
    "h1": "Edit a PDF without uploading the file",
    "title": "Edit PDF without uploading | DipperPDF",
    "description": "Keep PDF processing local on your Mac. Choose the implemented tool for merging, page changes, compression, or text work, and check its limits.",
    "intro": "To edit a PDF without uploading it, choose a local tool that performs the specific change you need. On a Mac, DipperPDF can merge, split, compress, change pages, and perform other implemented operations offline. It saves a separate result. It does not edit existing paragraph text, recognize scanned words, fill forms, or sign documents.",
    "sections": [
      {
        "heading": "Define the output before choosing an app",
        "paragraphs": [
          "“Edit a PDF” describes several different jobs. Joining an agreement and an appendix produces a combined PDF. Taking a schedule from a report produces an extract. Rewriting a paragraph requires a page-text editor. The no-upload requirement tells you where processing should happen, but it does not tell you which output format or editing capability you need.",
          "Start with the original file and the intended result. Decide whether the whole visual document must remain a PDF, whether only some pages are needed, or whether existing selectable words should become a text file. Then choose the operation that makes that result. DipperPDF’s implemented toolkit should not be treated as conversion or full page-text editing just because it works locally."
        ]
      },
      {
        "heading": "Keep assembly and page changes local",
        "paragraphs": [
          "Merge PDFs combines complete documents in the file order you choose. Split PDF produces fixed-page-count groups. Extract Pages saves selected pages as one PDF in original order, while Remove Pages saves the remaining pages after discarding your selection. These tools solve different selection problems; choosing the right one makes the result easier to verify.",
          "Rotate PDF turns selected pages in right-angle steps. Reverse Pages reverses the complete sequence. Crop PDF changes visible margins on a consecutive range, but hidden content remains recoverable and cropping must not be used to redact. If a document has several independent problems, save one result and import that copy into the next tool."
        ],
        "links": [
          {
            "label": "Merge PDFs locally",
            "href": "/tools/merge-pdf"
          },
          {
            "label": "Extract selected pages",
            "href": "/tools/extract-pdf"
          },
          {
            "label": "Remove unwanted pages",
            "href": "/tools/remove-pdf"
          },
          {
            "label": "Crop visible margins",
            "href": "/tools/crop-pdf"
          }
        ]
      },
      {
        "heading": "Prepare a separate sharing copy",
        "paragraphs": [
          "Compress PDF uses three image-compression levels. It can help with image-heavy documents, but there is no guaranteed reduction. If processing would create a larger file, the original bytes become the result. Check small labels and image detail before sharing. Add Page Numbers draws visible numbers over a chosen range; Add Watermark adds configurable text rather than access protection.",
          "Remove Annotations clears supported review markup while keeping links and form fields. Edit PDF Metadata changes title, author, subject, and keywords. Neither operation is a complete sanitization pass. Unlock PDF uses the appropriate password and permissions to create an unencrypted copy; it does not recover forgotten passwords or create new password protection."
        ],
        "links": [
          {
            "label": "Compress an image-heavy PDF",
            "href": "/tools/compress-pdf"
          },
          {
            "label": "Remove review annotations",
            "href": "/tools/annotations-pdf"
          },
          {
            "label": "Unlock with an authorized password",
            "href": "/tools/unlock-pdf"
          }
        ]
      },
      {
        "heading": "Work with existing text, not guessed scan recognition",
        "paragraphs": [
          "Extract Text exports the existing selectable text layer as a UTF-8 .txt file, with pages separated by blank lines. It does not preserve layout. Compare PDF pairs the original and revised documents by page number and reports added and removed selectable-text lines. Images, formatting, and metadata need separate review.",
          "Redact PDF searches selectable phrases or supported patterns and writes a fresh image-only PDF with matching regions covered. It does not search image-only scans, and patterns can miss details. The result loses selectable text and interactive document features. Repair PDF is a separate best-effort rebuild from pages macOS can already read; it cannot restore missing content."
        ],
        "links": [
          {
            "label": "Extract existing PDF text",
            "href": "/tools/text-pdf"
          },
          {
            "label": "Compare selectable text",
            "href": "/tools/compare-pdf"
          },
          {
            "label": "Read the redaction limits",
            "href": "/tools/redact-pdf"
          },
          {
            "label": "Repair a readable PDF",
            "href": "/tools/repair-pdf"
          }
        ]
      },
      {
        "heading": "A worked local workflow",
        "paragraphs": [
          "Suppose you have an agreement and a separate appendix, and need one review copy with visible page numbers. Install the DMG from GitHub Releases, open Merge PDFs, and add the two finished PDFs in the intended order. Prepare the combined document and check the boundary between them. Save it separately so the original files remain available.",
          "Import the saved combined file into Add Page Numbers. Choose the content range, starting number, and bottom placement. Inspect the first and last numbered sheets and any page with a dense footer. Save that result as the review copy. This is a manual sequence of two supported operations, not an automatic workflow builder."
        ],
        "links": [
          {
            "label": "Add visible page numbers",
            "href": "/tools/number-pdf"
          }
        ]
      },
      {
        "heading": "What no upload does and does not tell you",
        "paragraphs": [
          "DipperPDF processes the document on your Mac, with no account or in-app tracking, and works offline after installation. The source code is public so the processing boundary can be checked. Downloading the app and browsing this website still require internet access; those activities are separate from processing your file.",
          "Local processing does not make every output suitable for every purpose. Keep signed originals, inspect rewritten files, and verify that the tool covers the required job. If you need OCR, Office conversion, page-text editing, signing, or form filling, choose an application that implements it. A no-upload workflow is useful only when it also produces the right result."
        ],
        "links": [
          {
            "label": "Choose offline PDF tools for Mac",
            "href": "/guides/offline-pdf-tools-mac"
          }
        ]
      }
    ],
    "related": "merge-pdf"
  },
  {
    "slug": "offline-pdf-tools-mac",
    "kind": "guides",
    "query": "offline pdf tools for mac",
    "h1": "Offline PDF tools for your Mac",
    "title": "Offline PDF tools for Mac | DipperPDF",
    "description": "Choose from 17 free, open-source PDF tools that run natively on Mac. Download the DMG, process files offline, and save separate outputs.",
    "intro": "For offline PDF tools on a Mac, DipperPDF provides 17 implemented operations in a native app. Download the DMG from GitHub Releases, install it, and process PDFs locally without uploads or an account. Results are saved separately. The repository specifies macOS 14 or later; downloading requires internet, but the installed tools work offline.",
    "sections": [
      {
        "heading": "Install the native app once",
        "paragraphs": [
          "Download DipperPDF.dmg from the latest GitHub Release. Open the disk image, drag DipperPDF into Applications, and launch the app from Applications. The app is free and open source, with no subscription, trial, or paid upgrade. Consult the actual release notes for signing information rather than assuming a status from the fact that a DMG exists.",
          "Choose a PDF tool and open the document from your Mac. You can use the installed operations without a network connection. This website is an information and download site, not a browser PDF processor. The app has no account or in-app tracking; the website has a separate optional analytics policy described on its privacy pages."
        ]
      },
      {
        "heading": "Organize the document without online processing",
        "paragraphs": [
          "The organization tools are Merge PDFs, Split PDF, Extract Pages, Remove Pages, Rotate PDF, and Reverse Pages. Merge combines complete input documents in the chosen file order. Split creates consecutive groups with a fixed number of pages per output. Extraction saves chosen pages as one PDF; removal saves the pages left after discarding a selection.",
          "Rotation and reversal address different problems. Rotate turns selected pages in 90-degree increments, while Reverse changes the full sequence from last to first. Decide whether your scanner output is sideways, backwards, or a mixture before choosing a tool. A whole-document reversal will not detect a correctly ordered cover attached to a reversed appendix."
        ],
        "links": [
          {
            "label": "Merge PDFs",
            "href": "/tools/merge-pdf"
          },
          {
            "label": "Split PDF",
            "href": "/tools/split-pdf"
          },
          {
            "label": "Extract Pages",
            "href": "/tools/extract-pdf"
          },
          {
            "label": "Remove Pages",
            "href": "/tools/remove-pdf"
          },
          {
            "label": "Rotate PDF",
            "href": "/tools/rotate-pdf"
          },
          {
            "label": "Reverse Pages",
            "href": "/tools/reverse-pdf"
          }
        ]
      },
      {
        "heading": "Prepare the appearance and sharing copy",
        "paragraphs": [
          "Compress PDF targets image data with Light, Balanced, and Strong settings; an optimized input may not shrink. Crop PDF trims visible margins while retaining hidden content. Add Page Numbers places visible numbers in a chosen range, and Add Watermark draws configurable text. Both numbering and watermarking deserve a check against existing page content.",
          "Remove Annotations clears supported comments and review objects across the document while keeping links and form fields. Edit PDF Metadata changes four properties: title, author, subject, and keywords. Those operations are limited changes, not a guarantee that all identifying information has been removed. Keep the source and inspect the particular output you plan to share."
        ],
        "links": [
          {
            "label": "Compress PDF",
            "href": "/tools/compress-pdf"
          },
          {
            "label": "Crop PDF",
            "href": "/tools/crop-pdf"
          },
          {
            "label": "Add Page Numbers",
            "href": "/tools/number-pdf"
          },
          {
            "label": "Add Watermark",
            "href": "/tools/watermark-pdf"
          },
          {
            "label": "Remove Annotations",
            "href": "/tools/annotations-pdf"
          },
          {
            "label": "Edit PDF Metadata",
            "href": "/tools/metadata-pdf"
          }
        ]
      },
      {
        "heading": "Access, inspect, and redact within the implemented limits",
        "paragraphs": [
          "Unlock PDF uses a password and the required copying or assembly permissions to save an unencrypted copy. Extract Text exports an existing selectable text layer as plain text. Repair PDF rebuilds the document from readable pages. These operations do not recover a lost password, recognize words from a scan, or restore missing page content.",
          "Compare PDF creates a report of selectable-text changes in pages paired by number. It does not compare images or layout. Redact PDF finds selectable text or supported patterns and generates a fresh image-only copy with matches blacked out. Review every page because patterns may miss material and the output changes searchability and interactive features."
        ],
        "links": [
          {
            "label": "Unlock PDF",
            "href": "/tools/unlock-pdf"
          },
          {
            "label": "Extract Text",
            "href": "/tools/text-pdf"
          },
          {
            "label": "Repair PDF",
            "href": "/tools/repair-pdf"
          },
          {
            "label": "Compare PDF",
            "href": "/tools/compare-pdf"
          },
          {
            "label": "Redact PDF",
            "href": "/tools/redact-pdf"
          }
        ]
      },
      {
        "heading": "A worked offline session",
        "paragraphs": [
          "Suppose a scanned handout has a sideways page and an unnecessary blank sheet. After installing the app, open Rotate PDF, select the sideways page, turn it to the intended orientation, and prepare the result. Save a new PDF, then import that saved copy into Remove Pages. Select the blank sheet, check that a useful page remains, and save the shortened output.",
          "Open the finished file and read through it before sending it. Keep both the original scan and the intermediate copy until you have checked the result. If the scanner produced image-only pages, they can still be rotated or removed, but text extraction cannot read their words without an existing text layer. Offline processing does not create unimplemented OCR."
        ]
      },
      {
        "heading": "Choose another tool when the output requires it",
        "paragraphs": [
          "DipperPDF is a toolkit for the 17 listed jobs, not a full page-text editor. The repository does not implement Office or image conversion, OCR, signing, form filling, password protection, or a Windows, iOS, or browser edition. An existing local app may also be sufficient for a simple task; the Preview comparison explains that choice.",
          "Choose according to the actual input and output, preserve originals, and review saved results. A local operation can be the right privacy boundary while still being the wrong editing method. For the category-level decision, read the guide to editing without uploads; for a specific job, use the dedicated tool page and its worked example."
        ],
        "links": [
          {
            "label": "Edit a PDF without uploading",
            "href": "/guides/edit-pdf-without-uploading"
          },
          {
            "label": "When Preview is enough",
            "href": "/compare/preview-app-pdf-tools"
          }
        ]
      }
    ],
    "related": "rotate-pdf"
  }
];
export const DOWNLOAD_URL = "https://github.com/nshntarora/dipperpdf/releases/latest/download/DipperPDF.dmg";
export const REPOSITORY_URL = "https://github.com/nshntarora/dipperpdf";
export const READING_PAGES = SEARCH_PAGES.filter(page => page.kind !== "tools");
export function searchPath(page: Pick<SearchPage, "kind" | "slug">) {
  return `/${page.kind}/${page.slug}`;
}
