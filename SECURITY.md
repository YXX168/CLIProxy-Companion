# Security Policy

## Reporting a vulnerability

Please do not disclose security vulnerabilities, real Management API addresses, management keys, tokens, account details, or unredacted logs in a public Issue.

Use GitHub's private vulnerability reporting feature when available. If it is unavailable, open an Issue containing only a non-sensitive summary and wait for a maintainer to provide a private contact method.

## Deployment guidance

- Connect only to CLIProxyAPI instances you trust.
- Prefer HTTPS and restrict access to the Management API at the network layer.
- Use a dedicated management key and rotate it if exposure is suspected.
- Review screenshots and logs before sharing them publicly.
- Keep the Android app and CLIProxyAPI server updated.

The application stores the configured Management API address and management key using Android-backed secure storage. It does not ship with a preconfigured private endpoint or credential.
