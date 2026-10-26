import { execFileSync } from "node:child_process";

export function contentLastModified(...files: string[]): string | undefined {
  try {
    return execFileSync("git", ["log", "-1", "--format=%cI", "--", ...files], {
      cwd: process.cwd(),
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    }).trim() || undefined;
  } catch {
    // Source archives can build without Git; omit dates we cannot establish.
    return undefined;
  }
}
