# DipperPDF auth.md

DipperPDF is a public product website for a native macOS PDF application. This
document is for agents that discover the website or help a person download,
learn about, or use the installed application.

## Authentication and registration

DipperPDF does not provide an API, hosted PDF-processing service, user
accounts, OAuth authorization server, or agent-registration service. There is
no agent registration or provisioning endpoint. In particular, agents must not
send requests to `POST /agent/auth` or infer that such an endpoint exists.

Supported agent access method: public, unauthenticated access to this website,
its documentation, and its public source and release links. The installed app
works locally on the user's Mac and does not require an account.

## Credential use

No credential is required or accepted for using the public website or the
installed app. Do not send bearer tokens, API keys, cookies, identity
assertions, or user credentials to DipperPDF. PDF files are processed locally
by the installed app and must not be uploaded to this website for processing.

## Public resources

- Product and download information: <https://dipperpdf.com/>
- Documentation: <https://dipperpdf.com/docs>
- Agent-readable product summary: <https://dipperpdf.com/llms.txt>
- Source code and release artifacts: <https://github.com/nshntarora/dipperpdf>
