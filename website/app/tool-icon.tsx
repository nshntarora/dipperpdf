export type IconName =
  | "compress"
  | "merge"
  | "rotate"
  | "split"
  | "extract"
  | "remove"
  | "reverse"
  | "crop"
  | "number"
  | "watermark"
  | "annotations"
  | "text"
  | "metadata"
  | "unlock"
  | "repair"
  | "compare"
  | "redact";

const paths: Record<IconName, React.ReactNode> = {
  repair: <path d="M14 4a5 5 0 0 0-6 6L3 15l6 6 5-5a5 5 0 0 0 6-6l-4 4-4-4 4-4z" />,
  compare: <><path d="M3 3h7v18H3zM14 3h7v18h-7zM5 8h3m8 0h3M5 12h3m8 0h3M5 16h3m8 0h3" /></>,
  redact: <><path d="M5 3h14v18H5zM8 7h8M8 17h8" /><path d="M7 10h10v4H7z" fill="currentColor" /></>,
  compress: (
    <>
      <path d="M4 4l6 6M4 9V4h5m11 16l-6-6m6 1v5h-5M14 10h4V6M10 14H6v4" />
    </>
  ),
  merge: (
    <>
      <path d="M9 3H4v14h5m3-10h8v14h-8zM8 10l4 4-4 4m-4-4h8" />
    </>
  ),
  rotate: (
    <>
      <path d="M20 8a8 8 0 1 0 0 8M20 3v5h-5" />
      <rect x="8" y="8" width="7" height="9" rx="1" />
    </>
  ),
  split: (
    <>
      <path d="M10 4H4v16h6m4-16h6v16h-6M12 2v3m0 3v3m0 3v3m0 3v2" />
    </>
  ),
  extract: (
    <>
      <rect x="4" y="3" width="11" height="15" rx="1" />
      <path d="M9 7h11v14H9m3-10h5m-5 4h5" />
    </>
  ),
  remove: (
    <>
      <path d="M14 21H5V3h9l5 5v5M14 3v5h5m-5 10h7" />
    </>
  ),
  reverse: (
    <>
      <path d="M8 21V3L4 7m4-4l4 4m4-4v18l4-4m-4 4l-4-4" />
    </>
  ),
  crop: (
    <>
      <path d="M7 2v15h15M2 7h15v15M11 3h10v10" />
    </>
  ),
  number: (
    <>
      <path d="M10 3L6 21M18 3l-4 18M3 9h18M2 15h18" />
    </>
  ),
  watermark: (
    <>
      <path d="M6 21H3V3h13l5 5v5M16 3v5h5M9 20l4-9 4 9m-7-3h6m3 1h4m-2-2v4" />
    </>
  ),
  annotations: (
    <>
      <path d="M4 20h17M4 14L14 4l7 7-9 9H9zm4-4l7 7" />
    </>
  ),
  text: (
    <>
      <path d="M14 3H5v18h14V8zm0 0v5h5M8 12h8m-8 4h6" />
    </>
  ),
  metadata: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v6m0-10v.2" />
    </>
  ),
  unlock: (
    <>
      <rect x="5" y="10" width="14" height="11" rx="2" />
      <path d="M8 10V6a4 4 0 0 1 7-2m-3 11v2" />
    </>
  ),
};

export function ToolIcon({ name }: { name: IconName }) {
  return (
    <svg
      viewBox="0 0 24 24"
      width="24"
      height="24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  );
}
