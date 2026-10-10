import { DOCS_PAGES } from "../../config/docs";
import { DocsContentPage, docsPageMetadata } from "../../components/docs/DocsContentPage";

export const metadata = docsPageMetadata(DOCS_PAGES[0]);
export default function DocsPage() { return <DocsContentPage page={DOCS_PAGES[0]} />; }
