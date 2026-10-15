import { notFound } from "next/navigation";
import { SEARCH_PAGES } from "../../../config/search-pages";
import { SearchContentPage, searchPageMetadata } from "../../../components/search/SearchPage";

type Props = { params: Promise<{ slug: string }> };
export const dynamicParams = false;
export function generateStaticParams() {
  return SEARCH_PAGES.filter(page => page.kind === "compare").map(({ slug }) => ({ slug }));
}
function findPage(slug: string) {
  const page = SEARCH_PAGES.find(page => page.kind === "compare" && page.slug === slug);
  if (!page) notFound();
  return page;
}
export async function generateMetadata({ params }: Props) {
  return searchPageMetadata(findPage((await params).slug));
}
export default async function Page({ params }: Props) {
  return <SearchContentPage page={findPage((await params).slug)} />;
}
