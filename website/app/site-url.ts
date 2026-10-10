const fallbackSiteUrl = "https://dipperpdf.pages.dev";

function normalizeSiteUrl(value: string | undefined): string {
  const trimmedValue = value?.trim();

  if (!trimmedValue) {
    return fallbackSiteUrl;
  }

  const url = trimmedValue.match(/^https?:\/\//i)
    ? trimmedValue
    : `https://${trimmedValue}`;

  try {
    return new URL(url).toString();
  } catch {
    return fallbackSiteUrl;
  }
}

export const siteUrl = normalizeSiteUrl(process.env.NEXT_PUBLIC_SITE_URL);
export const siteUrlBase = new URL(siteUrl);
