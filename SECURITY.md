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

## Official Android signing certificate

CLIProxy v1 releases use the following SHA-256 signing certificate fingerprint:

```text
E5:D0:2E:42:C3:C2:10:6B:39:91:3E:11:03:13:C0:B9:5B:2F:28:00:A7:CE:26:09:3B:F8:75:F8:A8:FD:23:BB
```
