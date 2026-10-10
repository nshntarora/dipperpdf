"use client";

import { useEffect, useState } from "react";

export function HeroHeadline({ operations }: { operations: string[] }) {
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const motionPreference = window.matchMedia(
      "(prefers-reduced-motion: reduce)",
    );
    let interval: ReturnType<typeof setInterval> | undefined;

    function updateRotation() {
      clearInterval(interval);
      if (!motionPreference.matches && operations.length > 1) {
        interval = setInterval(() => {
          setActiveIndex((index) => (index + 1) % operations.length);
        }, 2800);
      }
    }

    updateRotation();
    motionPreference.addEventListener("change", updateRotation);
    return () => {
      clearInterval(interval);
      motionPreference.removeEventListener("change", updateRotation);
    };
  }, [operations.length]);

  return (
    <h1 id="hero-title" className="hero-headline reveal">
      <span className="hero-headline-accessible">
        Privacy-first tools to work with PDFs.
      </span>
      <span aria-hidden="true" className="hero-headline-copy">
        Privacy-first PDF tools to{" "}
        <span className="hero-operation">
          {operations.map((operation, index) => (
            <span
              key={operation}
              className={`hero-operation-word${index === activeIndex ? " is-active" : ""}`}
            >
              {operation}.
            </span>
          ))}
        </span>
      </span>
    </h1>
  );
}
