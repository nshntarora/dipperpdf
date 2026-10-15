"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";

export function WorkflowCarousel({ children }: { children: ReactNode }) {
  const viewport = useRef<HTMLDivElement>(null);
  const direction = useRef(1);
  const [playing, setPlaying] = useState(true);
  const [hovered, setHovered] = useState(false);
  const [focused, setFocused] = useState(false);
  const [reducedMotion, setReducedMotion] = useState(true);

  useEffect(() => {
    const preference = window.matchMedia("(prefers-reduced-motion: reduce)");
    const update = () => setReducedMotion(preference.matches);
    update();
    preference.addEventListener("change", update);
    return () => preference.removeEventListener("change", update);
  }, []);

  useEffect(() => {
    if (!playing || hovered || focused || reducedMotion) return;
    const element = viewport.current;
    if (!element) return;
    let frame: number;
    let previous = 0;
    let position = element.scrollLeft;
    const advance = (time: number) => {
      if (previous && !document.hidden) {
        const maximum = element.scrollWidth - element.clientWidth;
        position += direction.current * Math.min(time - previous, 50) * 0.018;
        if (position >= maximum) {
          position = maximum;
          direction.current = -1;
        } else if (position <= 0) {
          position = 0;
          direction.current = 1;
        }
        element.scrollLeft = position;
      }
      previous = time;
      frame = requestAnimationFrame(advance);
    };
    frame = requestAnimationFrame(advance);
    return () => cancelAnimationFrame(frame);
  }, [playing, hovered, focused, reducedMotion]);

  function move(step: number) {
    setPlaying(false);
    const element = viewport.current;
    const card = element?.firstElementChild;
    if (!element || !card) return;
    const gap = Number.parseFloat(getComputedStyle(element).columnGap) || 0;
    element.scrollBy({
      left: step * (card.getBoundingClientRect().width + gap),
      behavior: reducedMotion ? "instant" : "smooth",
    });
  }

  return (
    <div
      className="home-workflow-carousel"
      role="region"
      aria-roledescription="carousel"
      aria-labelledby="workflows-title"
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onFocusCapture={() => setFocused(true)}
      onBlurCapture={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget)) setFocused(false);
      }}
    >
      <div className="home-carousel-controls">
        <button type="button" aria-controls="workflow-cards" onClick={() => move(-1)} aria-label="Previous tool">←</button>
        <button type="button" aria-controls="workflow-cards" onClick={() => move(1)} aria-label="Next tool">→</button>
      </div>
      <div
        className="home-workflows"
        id="workflow-cards"
        ref={viewport}
        tabIndex={0}
        aria-label="All PDF tools. Scroll to explore."
        onPointerDown={() => setPlaying(false)}
        onWheel={() => setPlaying(false)}
        onKeyDown={(event) => {
          if (event.target !== event.currentTarget) return;
          if (event.key === "ArrowLeft" || event.key === "ArrowRight") {
            event.preventDefault();
            move(event.key === "ArrowLeft" ? -1 : 1);
          }
        }}
      >
        {children}
      </div>
    </div>
  );
}
