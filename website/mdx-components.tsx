import { Children, isValidElement, type HTMLAttributes, type ReactNode } from "react";

function textFromChildren(children: ReactNode): string {
  return Children.toArray(children).map(child => {
    if (typeof child === "string" || typeof child === "number") return String(child);
    return isValidElement<{ children?: ReactNode }>(child) ? textFromChildren(child.props.children) : "";
  }).join("");
}

export function slugifyHeading(text: string): string {
  return text.toLowerCase().replace(/['’`]/g, "").replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

export function useMDXComponents() {
  return {
    h2: ({ children, id, ...props }: HTMLAttributes<HTMLHeadingElement>) =>
      <h2 id={id ?? slugifyHeading(textFromChildren(children))} {...props}>{children}</h2>,
    h3: ({ children, id, ...props }: HTMLAttributes<HTMLHeadingElement>) =>
      <h3 id={id ?? slugifyHeading(textFromChildren(children))} {...props}>{children}</h3>,
    blockquote: (props: HTMLAttributes<HTMLQuoteElement>) => <blockquote className="docs-callout" {...props} />,
  };
}
