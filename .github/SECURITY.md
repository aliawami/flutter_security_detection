# Security Policy

## Supported Versions

Only the latest minor release on the `0.x` line receives security updates.
Once `1.0.0` is published, the policy will be updated to cover the two most recent minor versions.

| Version | Supported          |
|---------|--------------------|
| 0.1.x   | ✅ Active support  |
| < 0.1   | ❌ No longer supported |

---

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub Issues.**

Security issues in `flutter_security_detection` — including bypasses of detection logic, false-negative conditions, or supply-chain concerns — should be reported privately so a fix can be prepared before any public disclosure.

### How to report

**Email:** [aliAlawami@proton.me](mailto:aliAlawami@proton.me)  
**Subject line:** `[SECURITY] flutter_security_detection — <brief description>`

Alternatively, use [GitHub's private vulnerability reporting](https://github.com/aliawami/flutter_security_detection/security/advisories/new) (Settings → Security → Advisories → New draft advisory).

### What to include

- Package version affected
- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept (even partial)
- Any suggested mitigations if you have them

### Response timeline

| Milestone | Target |
|-----------|--------|
| Initial acknowledgement | Within **48 hours** |
| Triage & severity assessment | Within **5 business days** |
| Fix or mitigation published | Within **30 days** for critical/high severity |
| CVE / advisory published | After fix is available |

If a confirmed vulnerability is accepted, you will be credited in the release notes and the GitHub advisory (if you wish). If a report is declined, you will receive an explanation.

---

## Scope

This policy covers the `flutter_security_detection` package itself. It does **not** cover:

- Third-party packages that `flutter_security_detection` depends on (report those to their respective maintainers)
- The example app under `example/`
- Vulnerabilities in Flutter or Dart itself (report to [flutter.dev/security](https://flutter.dev/security))

---

## Disclosure Policy

This project follows [Coordinated Vulnerability Disclosure (CVD)](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerability_Disclosure_Cheat_Sheet.html). Researchers are asked to give the maintainer reasonable time to patch before any public disclosure.
