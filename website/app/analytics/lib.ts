/**
 * Marketing-site analytics (PostHog). Disabled unless explicitly configured
 * at build time, so local builds and previews do not collect events by default.
 */

const DEFAULT_PROXY_PATH = "/i";
const UI_HOST = "https://us.posthog.com";

export type AnalyticsConfig =
  | { enabled: false }
  | { enabled: true; apiKey: string; apiHost: string };

function trim(value: string | undefined): string {
  return typeof value === "string" ? value.trim() : "";
}

function normalizeProxyPath(path: string): string {
  const withLeading = path.startsWith("/") ? path : `/${path}`;
  return withLeading.replace(/\/+$/, "") || DEFAULT_PROXY_PATH;
}

export function getAnalyticsConfig(): AnalyticsConfig {
  if (trim(process.env.NEXT_PUBLIC_ANALYTICS_ENABLED) !== "true") {
    return { enabled: false };
  }

  const apiKey = trim(process.env.NEXT_PUBLIC_ANALYTICS_KEY);
  if (!apiKey) {
    return { enabled: false };
  }

  return {
    enabled: true,
    apiKey,
    apiHost: normalizeProxyPath(
      trim(process.env.NEXT_PUBLIC_ANALYTICS_PROXY_PATH) || DEFAULT_PROXY_PATH,
    ),
  };
}

export interface AnalyticsClient {
  init(): void;
  capturePageview(url: string): void;
  capture(event: string, properties?: Record<string, unknown>): void;
}

const noopClient: AnalyticsClient = {
  init() {},
  capturePageview() {},
  capture() {},
};

type PostHogJs = typeof import("posthog-js").default;

function createPostHogClient(apiKey: string, apiHost: string): AnalyticsClient {
  let posthog: PostHogJs | null = null;
  let initStarted = false;
  const pending: Array<(client: PostHogJs) => void> = [];

  function withClient(callback: (client: PostHogJs) => void) {
    if (posthog) {
      callback(posthog);
      return;
    }
    pending.push(callback);
  }

  return {
    init() {
      if (typeof window === "undefined" || initStarted) return;
      initStarted = true;

      void import("posthog-js").then(({ default: client }) => {
        if (!client.__loaded) {
          client.init(apiKey, {
            api_host: apiHost,
            ui_host: UI_HOST,
            capture_pageview: false,
            capture_pageleave: true,
            person_profiles: "identified_only",
            autocapture: false,
            disable_session_recording: true,
          });
        }
        posthog = client;
        pending.splice(0).forEach((callback) => callback(client));
      });
    },

    capturePageview(url) {
      withClient((client) => client.capture("$pageview", { $current_url: url }));
    },

    capture(event, properties) {
      withClient((client) => client.capture(event, properties));
    },
  };
}

export function createAnalyticsClient(
  config: AnalyticsConfig = getAnalyticsConfig(),
): AnalyticsClient {
  return config.enabled
    ? createPostHogClient(config.apiKey, config.apiHost)
    : noopClient;
}
