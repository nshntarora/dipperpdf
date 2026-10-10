import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

// Render during the build so Cloudflare Pages can serve the exported PNG.
export const dynamic = "force-static";
export const alt =
  "DipperPDF — Private PDF tools, right on your Mac. No uploads. Works offline. Free and open source.";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function OpenGraphImage() {
  const [serif, sans, icon] = await Promise.all([
    readFile(join(process.cwd(), "public/fonts/instrument-serif.ttf")),
    // ImageResponse needs a static font; the site's variable font is unsupported.
    readFile(join(process.cwd(), "public/fonts/hanken-grotesk-regular.ttf")),
    readFile(join(process.cwd(), "public/app-icon.png")),
  ]);

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "54px 64px",
          background: "#f7f5ef",
          color: "#292b26",
          fontFamily: "Hanken Grotesk",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", fontSize: 36 }}>
          <span>DipperPDF</span>
          <span style={{ color: "#b74327" }}>.</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 38 }}>
          <div style={{ display: "flex", flexDirection: "column", flex: 1 }}>
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                fontFamily: "Instrument Serif",
                fontSize: 90,
                lineHeight: 1.05,
                letterSpacing: -2,
              }}
            >
              <span>Private PDF tools.</span>
              <span style={{ color: "#b74327" }}>Right on your Mac.</span>
            </div>
            <div style={{ display: "flex", marginTop: 28, fontSize: 28 }}>
              No uploads. Works offline.
            </div>
          </div>
          <img
            src={`data:image/png;base64,${icon.toString("base64")}`}
            width={250}
            height={250}
            alt=""
          />
        </div>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            borderTop: "1px solid #dcdcd0",
            paddingTop: 24,
            fontSize: 22,
          }}
        >
          <span>PDF tools. All local.</span>
          <span style={{ color: "#b74327" }}>Free. Open source. Built for Mac.</span>
        </div>
      </div>
    ),
    {
      ...size,
      fonts: [
        { name: "Instrument Serif", data: serif, weight: 400, style: "normal" },
        { name: "Hanken Grotesk", data: sans, weight: 400, style: "normal" },
      ],
    },
  );
}
