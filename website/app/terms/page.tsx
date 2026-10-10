import { ContactDetails, LegalPage, legalMetadata } from "../legal";

export const metadata = legalMetadata(
  "Terms of Service",
  "The terms governing use of DipperPDF and its website.",
  "/terms",
);

export default function TermsPage() {
  return (
    <LegalPage title="Terms of Service">
      <p>
        These Terms of Use are a legally binding agreement between you and
        Artery Ventures, LLP ("Company", "we", "us", or "our") governing
        your access to DipperPDF, the DipperPDF website, and related
        documentation (collectively, the "Service"). By downloading,
        installing, accessing, or using the Service, you agree to these Terms.
        If you do not agree, do not use the Service.
      </p>

      <h2>1. Description of service</h2>
      <p>
        DipperPDF is a native macOS application for working with PDF files and
        a website that describes and distributes the app. The app offers local
        PDF tools, including merging, splitting, rotating, compressing,
        extracting, cropping, and editing document details. DipperPDF is
        designed to process documents on your Mac. The website does not accept
        PDF uploads, and we do not operate a DipperPDF backend that receives
        or stores your PDFs as part of the app&apos;s ordinary workflow.
      </p>
      <p>
        We may modify, suspend, or discontinue any part of the Service at any
        time. We do not guarantee that the Service will always be available or
        that every feature will work with every PDF or macOS version.
      </p>

      <h2>2. Eligibility and acceptable use</h2>
      <p>You represent and warrant that you have the legal capacity to agree to these Terms and that:</p>
      <ol>
        <li>you will use the Service only for lawful purposes;</li>
        <li>you have the right to access and process every PDF you use with the Service;</li>
        <li>you will not use the Service to violate privacy, intellectual-property, or other rights;</li>
        <li>you will not interfere with, disrupt, or attempt unauthorized access to the website or its infrastructure; and</li>
        <li>you will not introduce malware or use the Service to distribute harmful material.</li>
      </ol>

      <h2>3. Local processing and your files</h2>
      <p>
        DipperPDF processes PDFs locally on your device. You remain responsible
        for your files, including keeping originals and backups before applying
        changes. Some operations create a new file, but you should review each
        result before relying on it. We do not claim ownership of your PDFs or
        their contents merely because you use DipperPDF.
      </p>
      <p>
        Your device, its storage, and the permissions you grant to the app are
        under your control. Protect your Mac and any sensitive documents,
        passwords, or credentials it contains.
      </p>

      <h2>4. Downloads, updates, and third parties</h2>
      <p>
        DipperPDF may be distributed through GitHub, our website, or other
        authorized channels. Those services, along with macOS and any other
        third-party websites linked from the Service, are governed by their own
        terms and privacy policies. We are not responsible for third-party
        services, availability, or their handling of information.
      </p>

      <h2>5. Intellectual property and open source</h2>
      <p>
        The DipperPDF name, branding, website content, and non-source materials
        we publish are owned by or licensed to us and are protected by applicable
        law. Subject to these Terms, we grant you a limited, non-exclusive,
        non-transferable licence to install and use the app for personal or
        internal business purposes.
      </p>
      <p>
        Source code made available in public repositories is governed by the
        applicable open-source licence and notices in that repository. An
        open-source licence does not grant a right to use our trademarks or
        hosted branding except as that licence expressly permits.
      </p>

      <h2>6. Feedback</h2>
      <p>
        If you send us feedback, suggestions, bug reports, or other submissions,
        you grant us a worldwide, royalty-free right to use them to operate,
        improve, and promote the Service. This does not transfer ownership of a
        contribution you make under a separate open-source contribution process.
      </p>

      <h2>7. Fees</h2>
      <p>
        DipperPDF is currently offered without a fee charged by us. You remain
        responsible for costs imposed by your device, internet provider, app
        distribution platform, or other third parties. If we introduce paid
        features, we will disclose applicable pricing before charging you.
      </p>

      <h2>8. Disclaimer</h2>
      <p>
        THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. TO THE
        FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR
        IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
        PARTICULAR PURPOSE, AND NON-INFRINGEMENT. PDF results can vary with the
        source document, fonts, encryption, and macOS environment. You are
        responsible for checking output before use.
      </p>

      <h2>9. Limitation of liability</h2>
      <p>
        TO THE FULLEST EXTENT PERMITTED BY LAW, WE WILL NOT BE LIABLE FOR ANY
        INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, EXEMPLARY, OR PUNITIVE
        DAMAGES, OR FOR LOSS OF DATA, DOCUMENTS, PROFITS, OR REVENUE ARISING
        FROM YOUR USE OF THE SERVICE. OUR TOTAL LIABILITY FOR ANY CLAIM WILL
        NOT EXCEED THE GREATER OF THE AMOUNT YOU PAID US FOR THE SERVICE IN THE
        THREE MONTHS BEFORE THE EVENT GIVING RISE TO THE CLAIM OR USD $100.
      </p>

      <h2>10. Indemnification</h2>
      <p>
        You agree to defend, indemnify, and hold harmless the Company and its
        affiliates, officers, employees, and agents from claims, damages, and
        expenses arising from your use of the Service, your breach of these
        Terms, or your violation of another person&apos;s rights.
      </p>

      <h2>11. Changes, termination, and governing law</h2>
      <p>
        We may update these Terms by posting a revised version with a new
        effective date. Your continued use after that date means you accept the
        revised Terms. You may stop using the Service at any time. We may limit
        or terminate access to the Service where permitted by law.
      </p>
      <p>
        These Terms are governed by the laws of India. The courts of competent
        jurisdiction in Mumbai, Maharashtra, India have exclusive jurisdiction
        over disputes arising from these Terms, subject to applicable mandatory
        consumer-protection laws.
      </p>

      <h2>12. Contact</h2>
      <p>For questions or complaints about the Service, contact us at:</p>
      <ContactDetails />
    </LegalPage>
  );
}
