import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readdirSync, rmSync, utimesSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import sitemap, { dynamic } from "../app/sitemap";
import { siteUrlBase } from "../app/site-url";
import { DOCS_PAGES, docsPath } from "../config/docs";
import { SEARCH_PAGES, searchPath } from "../config/search-pages";
import { contentLastModified } from "../config/content-last-modified";

function timestamp(value: string | Date | undefined): number {
  assert.ok(value, "Every sitemap entry must have lastModified");
  return new Date(value).getTime();
}

test("sitemap remains compatible with static export", () => {
  assert.equal(dynamic, "force-static");
});

test("sitemap covers static routes and every registered docs and search page exactly once", () => {
  const staticPaths = readdirSync("app", { recursive: true })
    .filter((file): file is string => typeof file === "string")
    .filter(file => (file === "page.tsx" || file.endsWith("/page.tsx")) && !file.includes("["))
    .map(file => `/${file.replace(/(^|\/)page\.tsx$/, "")}`);
  const expectedPaths = new Set([
    ...staticPaths,
    ...DOCS_PAGES.map(page => docsPath(page.slug)),
    ...SEARCH_PAGES.map(searchPath),
  ]);
  const expectedUrls = [...expectedPaths].map(path => new URL(path, siteUrlBase).href);
  const actualUrls = sitemap().map(page => page.url);

  assert.equal(actualUrls.length, new Set(actualUrls).size, "No duplicate URLs");
  assert.deepEqual(actualUrls.sort(), expectedUrls.sort());
});

test("every entry has a canonical absolute URL and valid metadata", () => {
  const frequencies = new Set(["always", "hourly", "daily", "weekly", "monthly", "yearly", "never"]);
  for (const page of sitemap()) {
    const url = new URL(page.url);
    assert.equal(url.origin, siteUrlBase.origin);
    assert.ok(["http:", "https:"].includes(url.protocol));
    assert.equal(url.search, "");
    assert.equal(url.hash, "");
    assert.equal(page.url, new URL(url.pathname, siteUrlBase).href);
    assert.ok(Number.isFinite(timestamp(page.lastModified)), `Invalid date for ${page.url}`);
    assert.ok(timestamp(page.lastModified) <= Date.now(), `Future date for ${page.url}`);
    assert.ok(frequencies.has(page.changeFrequency!), `Invalid frequency for ${page.url}`);
    assert.equal(typeof page.priority, "number");
    assert.ok(page.priority! >= 0 && page.priority! <= 1, `Invalid priority for ${page.url}`);
  }
});

test("page groups retain their priorities and change frequencies", () => {
  const pages = new Map(sitemap().map(page => [new URL(page.url).pathname, page]));
  const home = pages.get("/")!;
  assert.equal(home.priority, 1);
  assert.equal(home.changeFrequency, "weekly");
  for (const path of ["/privacy", "/terms", "/cookies"]) {
    const legal = pages.get(path)!;
    assert.equal(legal.priority, 0.3);
    assert.equal(legal.changeFrequency, "yearly");
  }
  for (const doc of DOCS_PAGES) {
    const page = pages.get(docsPath(doc.slug))!;
    assert.equal(page.priority, doc.slug ? 0.7 : 0.8);
    assert.equal(page.changeFrequency, "monthly");
  }
  for (const search of SEARCH_PAGES) {
    const page = pages.get(searchPath(search))!;
    assert.equal(page.priority, search.kind === "tools" ? 0.8 : 0.7);
    assert.equal(page.changeFrequency, "monthly");
  }
});

test("documentation dates come from their content history, including the docs index", () => {
  const pages = new Map(sitemap().map(page => [new URL(page.url).pathname, page]));
  for (const doc of DOCS_PAGES) {
    const file = join("content/help", `${doc.slug || "index"}.mdx`);
    const committedDate = execFileSync("git", ["log", "-1", "--format=%cI", "--", file], { encoding: "utf8" }).trim();
    assert.equal(pages.get(docsPath(doc.slug))!.lastModified, committedDate);
  }
});

test("content dates track relevant commits and ignore checkout timestamps", () => {
  const originalCwd = process.cwd();
  const fixture = mkdtempSync(join(tmpdir(), "dipperpdf-sitemap-"));
  let commitDate = "2025-01-01T12:00:00Z";
  function git(...args: string[]) {
    return execFileSync("git", args, {
      cwd: fixture,
      env: {
        ...process.env,
        GIT_AUTHOR_NAME: "Sitemap Test",
        GIT_AUTHOR_EMAIL: "sitemap@example.com",
        GIT_COMMITTER_NAME: "Sitemap Test",
        GIT_COMMITTER_EMAIL: "sitemap@example.com",
        GIT_AUTHOR_DATE: commitDate,
        GIT_COMMITTER_DATE: commitDate,
      },
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim();
  }
  try {
    process.chdir(fixture);
    assert.equal(contentLastModified("page.tsx"), undefined, "Archives omit unknown dates");
    git("init");
    writeFileSync("page.tsx", "Initial content\n");
    git("add", "page.tsx");
    git("-c", "core.hooksPath=/dev/null", "commit", "--no-gpg-sign", "-m", "Add page");
    const initialDate = contentLastModified("page.tsx");
    assert.equal(timestamp(initialDate), Date.parse("2025-01-01T12:00:00Z"));
    utimesSync("page.tsx", new Date(), new Date());
    assert.equal(contentLastModified("page.tsx"), initialDate);
    commitDate = "2025-02-01T12:00:00Z";
    writeFileSync("unrelated.txt", "Other content\n");
    git("add", "unrelated.txt");
    git("-c", "core.hooksPath=/dev/null", "commit", "--no-gpg-sign", "-m", "Unrelated change");
    assert.equal(contentLastModified("page.tsx"), initialDate);
    commitDate = "2025-03-01T12:00:00Z";
    writeFileSync("page.tsx", "Updated content\n");
    git("add", "page.tsx");
    git("-c", "core.hooksPath=/dev/null", "commit", "--no-gpg-sign", "-m", "Update page");
    assert.equal(timestamp(contentLastModified("page.tsx")), Date.parse(commitDate));
    assert.equal(contentLastModified("missing.tsx"), undefined);
  } finally {
    process.chdir(originalCwd);
    rmSync(fixture, { recursive: true, force: true });
  }
});
