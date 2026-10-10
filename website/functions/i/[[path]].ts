/**
 * First-party PostHog proxy. The browser only talks to /i; this function
 * relays SDK assets to PostHog's assets host and event ingestion to its API.
 */

type Context = {
  request: Request;
  params: { path?: string | string[] };
};

export async function onRequest({ request, params }: Context): Promise<Response> {
  const path = Array.isArray(params.path)
    ? params.path.join("/")
    : params.path ?? "";
  const origin = path.startsWith("static/") || path.startsWith("array/")
    ? "https://us-assets.i.posthog.com"
    : "https://us.i.posthog.com";
  const target = new URL(`/${path}`, origin);
  target.search = new URL(request.url).search;

  return fetch(new Request(target, request));
}
