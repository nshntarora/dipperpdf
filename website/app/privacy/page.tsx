import { ContactDetails, LegalPage, legalContactEmail, legalMetadata } from "../legal";

export const metadata = legalMetadata(
  "Privacy Policy",
  "How DipperPDF handles information on its website and in the native app.",
  "/privacy",
);

export default function PrivacyPage() {
  return (
    <LegalPage title="Privacy Policy">
      <p>
        Artery Ventures, LLP ("we", "us", or "our") operates DipperPDF, its
        website, and its native macOS app (collectively, the "Service"). This
        Privacy Policy explains how we handle personal information in connection
        with the Service.
      </p>

      <h2>1. The app processes PDFs locally</h2>
      <p>
        DipperPDF is designed to process your documents on your Mac. In the
        ordinary app workflow, PDFs and their contents are not uploaded to us,
        and we do not run a DipperPDF backend that receives or stores them.
        Files you open, passwords you enter, and exported results remain under
        the control of your device and the storage locations you choose.
      </p>

      <h2>2. Information we may collect</h2>
      <p>
        If you contact us, we may receive your name, email address, and the
        contents of your message. When you visit the website, hosting and
        security providers may process technical request information such as
        IP address, browser type, referring page, pages visited, and similar
        log data needed to serve and secure the site.
      </p>
      <p>
        Website analytics are disabled by default. If we enable them, we use
        PostHog to understand general website traffic and selected marketing
        interactions such as download clicks. We configure it for page views
        and explicit events, with autocapture and session recording disabled;
        it does not track how you use the Mac app or process your PDFs.
      </p>

      <h2>3. How we use information</h2>
      <p>We may use information we control to:</p>
      <ul>
        <li>respond to support requests and feedback;</li>
        <li>operate, secure, and improve the website and Service;</li>
        <li>understand aggregated website usage; and</li>
        <li>comply with legal obligations and enforce our agreements.</li>
      </ul>

      <h2>4. Sharing and disclosures</h2>
      <p>
        We do not sell your personal information. We may share information with
        service providers that help host, secure, or analyze the website, with
        professional advisers where necessary, or where disclosure is required
        by law. Those providers process information under their own terms and
        privacy policies. We may also transfer information as part of a merger,
        acquisition, or transfer of our business, subject to applicable law.
      </p>

      <h2>5. Retention and security</h2>
      <p>
        We retain correspondence and website information only as long as needed
        for the purposes described here, including responding to inquiries,
        maintaining records, resolving disputes, and meeting legal obligations.
        We use reasonable safeguards for information we control, but no method
        of transmission or storage is completely secure. You are responsible
        for protecting your Mac and the files stored on it.
      </p>

      <h2>6. Your choices and rights</h2>
      <p>
        You can clear website cookies and similar browser storage through your
        browser settings. You can stop using the app and delete app-created
        files or settings from your Mac. To request access to, correction of,
        deletion of, or restriction on personal information we hold, or to
        withdraw consent where consent is the basis for processing, email us at{" "}
        <a href={`mailto:${legalContactEmail}`}>{legalContactEmail}</a>.
      </p>

      <h2>7. International visitors</h2>
      <p>
        Website providers may process information in countries other than yours.
        Where we act as a controller of personal information for visitors in the
        European Economic Area or United Kingdom, we rely on consent, contract,
        legal obligations, or legitimate interests as appropriate. You may have
        the right to complain to your local data-protection authority.
      </p>

      <h2>8. Children and third-party links</h2>
      <p>
        The Service is not intended for children under 18, and we do not
        knowingly collect their personal information. The Service may link to
        third-party sites such as GitHub. Their privacy practices are governed
        by their own policies.
      </p>

      <h2>9. Changes and contact</h2>
      <p>
        We may update this Policy by posting a revised version with a new date.
        If you have questions, concerns, or a privacy request, contact us at:
      </p>
      <ContactDetails />
    </LegalPage>
  );
}
