"use client";

import { useState } from "react";
import { ToolIcon, type IconName } from "./tool-icon";

const modes = [
  {
    name: "Compress",
    icon: "compress",
    title: "A lighter attachment.",
    description: "Choose how much to compress your PDF.",
  },
  {
    name: "Merge",
    icon: "merge",
    title: "Better together.",
    description: "Bring your documents into one PDF.",
  },
  {
    name: "Rotate",
    icon: "rotate",
    title: "The right way up.",
    description: "Turn a page. Get a fresh perspective.",
  },
] as const;
const levels = {
  Light: "A gentle reduction. Keep more image detail.",
  Balanced: "A little smaller. A little easier to share.",
  Strong: "Smaller images for a more compact file.",
};
type Level = keyof typeof levels;

export function AppPreview() {
  const [mode, setMode] = useState<(typeof modes)[number]>(modes[0]);
  const [level, setLevel] = useState<Level>("Balanced");
  const [rotation, setRotation] = useState(0);
  return (
    <figure className="preview-figure">
      <div className="app-window">
        <div className="window-titlebar">
          <div className="traffic-lights" aria-hidden="true">
            <i />
            <i />
            <i />
          </div>
          <span>DipperPDF</span>
          <ToolIcon name="split" />
        </div>
        <div className="app-body">
          <div className="app-sidebar">
            <div className="sidebar-label">YOUR TOOLKIT</div>
            <div
              className="preview-tabs"
              role="tablist"
              aria-label="Preview a PDF tool"
              aria-orientation="vertical"
            >
              {modes.map((item) => (
                <button
                  type="button"
                  role="tab"
                  aria-selected={mode.name === item.name}
                  aria-controls="preview-panel"
                  id={`tab-${item.name}`}
                  key={item.name}
                  className={mode.name === item.name ? "selected" : ""}
                  onClick={() => setMode(item)}
                  onKeyDown={(event) => {
                    if (
                      [
                        "ArrowDown",
                        "ArrowUp",
                        "ArrowRight",
                        "ArrowLeft",
                        "Home",
                        "End",
                      ].includes(event.key)
                    ) {
                      event.preventDefault();
                      const index = modes.findIndex(
                        (value) => value.name === item.name,
                      );
                      const next =
                        event.key === "Home"
                          ? 0
                          : event.key === "End"
                            ? modes.length - 1
                            : (index +
                                (["ArrowUp", "ArrowLeft"].includes(event.key)
                                  ? -1
                                  : 1) +
                                modes.length) %
                              modes.length;
                      setMode(modes[next]);
                      document
                        .getElementById(`tab-${modes[next].name}`)
                        ?.focus();
                    }
                  }}
                  tabIndex={mode.name === item.name ? 0 : -1}
                >
                  <ToolIcon name={item.icon} />
                  {item.name}
                </button>
              ))}
            </div>
            <div className="sidebar-other" aria-hidden="true">
              {(
                [
                  ["Extract pages", "extract"],
                  ["Split PDF", "split"],
                  ["Page numbers", "number"],
                ] as [string, IconName][]
              ).map(([name, icon]) => (
                <span key={name}>
                  <ToolIcon name={icon} />
                  {name}
                </span>
              ))}
              <span className="sidebar-more">+ 8 more tools</span>
            </div>
            <div className="sidebar-bottom">
              <span className="status-dot" /> All on your Mac
            </div>
          </div>
          <div
            className="app-content"
            id="preview-panel"
            role="tabpanel"
            aria-labelledby={`tab-${mode.name}`}
            tabIndex={0}
          >
            <div className="preview-heading">
              <div className="preview-tool-icon">
                <ToolIcon name={mode.icon} />
              </div>
              <h2>{mode.title}</h2>
              <p>{mode.description}</p>
            </div>
            <div
              className={`document-stage stage-${mode.name.toLowerCase()}`}
              aria-hidden="true"
            >
              <div className="document document-back">
                <span>FIELD NOTES</span>
                <i />
                <i />
                <i />
                <div className="document-image" />
              </div>
              <div
                className="document document-front"
                style={
                  mode.name === "Rotate"
                    ? { transform: `rotate(${rotation}deg)` }
                    : undefined
                }
              >
                <div className="document-top">
                  <span>FIELD NOTES</span>
                  <span>01</span>
                </div>
                <h3>
                  A little
                  <br />
                  breathing
                  <br />
                  <em>room.</em>
                </h3>
                <div className="document-landscape">
                  <div className="landscape-sun" />
                  <div className="landscape-hill hill-one" />
                  <div className="landscape-hill hill-two" />
                </div>
                <div className="document-lines">
                  <i />
                  <i />
                  <i />
                </div>
                <div className="document-footer">
                  <span>THE EVERYDAY COLLECTION</span>
                  <span>2026</span>
                </div>
              </div>
              {mode.name === "Merge" && <div className="merge-mark">+</div>}
            </div>
            <div className="preview-controls">
              {mode.name === "Compress" ? (
                <>
                  <div
                    className="compression-options"
                    role="group"
                    aria-label="Illustrative compression level"
                  >
                    {(Object.keys(levels) as Level[]).map((value) => (
                      <button
                        type="button"
                        key={value}
                        onClick={() => setLevel(value)}
                        aria-pressed={level === value}
                        className={level === value ? "active" : ""}
                      >
                        {value}
                      </button>
                    ))}
                  </div>
                  <p aria-live="polite">{levels[level]}</p>
                </>
              ) : mode.name === "Rotate" ? (
                <>
                  <button
                    type="button"
                    className="rotate-button"
                    onClick={() => setRotation(rotation + 90)}
                  >
                    <ToolIcon name="rotate" /> Rotate page 90°
                  </button>
                  <p aria-live="polite">
                    {rotation % 360}° rotation · original untouched
                  </p>
                </>
              ) : (
                <>
                  <div className="merge-files">
                    <span>Notes.pdf</span>
                    <span>Ideas.pdf</span>
                    <span>Plans.pdf</span>
                  </div>
                  <p>Three documents. One tidy PDF.</p>
                </>
              )}
            </div>
          </div>
        </div>
      </div>
      <figcaption>
        Explore a workflow <span aria-hidden="true">↗</span>
        <span>Illustrative preview</span>
      </figcaption>
    </figure>
  );
}
