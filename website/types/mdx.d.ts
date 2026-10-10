declare module "*.mdx" {
  import type { ComponentType } from "react";
  export const toc: { id: string; label: string; level: 2 | 3 }[];
  const Content: ComponentType;
  export default Content;
}
