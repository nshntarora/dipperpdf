import { LegalPage, legalContactEmail, legalMetadata } from "../legal";

export const metadata = legalMetadata(
  "Cookies Policy",
  "How the DipperPDF website uses cookies and optional analytics.",
  "/cookies",
);

export default function CookiesPage() {
  return (
    <LegalPage title="Cookies Policy">
      <p>
        This Cookies Policy explains how Artery Ventures, LLP uses cookies and
        similar technologies on the DipperPDF website. It applies to the
        website only; the DipperPDF macOS app does not use website cookies to
        process PDFs or report app usage to us.
      </p>

      <h2>1. What cookies are</h2>
      <p>
        Cookies are small text files placed on your device when you visit a
        website. Similar technologies include local storage and browser storage.
        They can support site operation, remember preferences, and help site
        owners understand general usage.
      </p>

      <h2>2. How we use them</h2>
      <p>
        We aim to keep website tracking minimal. Our hosting and security
        providers may use strictly necessary cookies or similar technologies to
        deliver and protect the site. These are not used for advertising.
      </p>
      <p>
        Analytics are disabled by default. When enabled, the website uses
        PostHog through a first-party <code>/i</code> proxy to measure page
        views and selected interactions, such as download clicks. The analytics
        configuration disables autocapture and session recording. We do not use
        it to track DipperPDF&apos;s local document processing or to build profiles
        from your PDFs.
      </p>

      <h2>3. What we do not do</h2>
      <p>
        We do not use the website&apos;s cookies or analytics for behavioural
        advertising, and we do not sell personal information collected through
        them. The app does not upload your PDFs to us as part of normal use.
      </p>

      <h2>4. Your choices</h2>
      <p>
        Most browsers let you block or delete cookies and clear site data in
        their settings. You may also use browser privacy features or extensions
        that limit tracking. Blocking some technologies may affect website
        functionality or prevent optional analytics from loading.
      </p>

      <h2>5. Changes and contact</h2>
      <p>
        We may update this Policy by posting a revised version with a new date.
        For questions, contact us at{" "}
        <a href={`mailto:${legalContactEmail}`}>{legalContactEmail}</a>.
      </p>
    </LegalPage>
  );
}
