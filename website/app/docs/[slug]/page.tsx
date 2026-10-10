import { notFound } from "next/navigation";
import { DOCS_PAGES } from "../../../config/docs";
import { DocsContentPage, docsPageMetadata } from "../../../components/docs/DocsContentPage";

type Props = { params: Promise<{ slug: string }> };
export const dynamicParams = false;
export function generateStaticParams() { return DOCS_PAGES.filter(page => page.slug).map(({slug}) => ({slug})); }
export async function generateMetadata({ params }: Props) {
  const {slug} = await params;
  const page = DOCS_PAGES.find(page => page.slug === slug);
  return page ? docsPageMetadata(page) : notFound();
}
export default async function DocsSlugPage({ params }: Props) {
  const {slug} = await params;
  const page = DOCS_PAGES.find(page => page.slug === slug);
  if (!page) notFound();
  return <DocsContentPage page={page} />;
}
