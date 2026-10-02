# Responsible Disclosure Policy

**This policy is non-negotiable. All agents must follow it.**

## Core Principles

1. **90-day coordinated disclosure** — timeline starts from maintainer acknowledgment
2. **Never exploit production systems** — PoCs run locally only
3. **Use the project's preferred security contact** — check SECURITY.md first
4. **Don't publish before the fix is released** or the deadline expires
5. **Credit the maintainer** for prompt response
6. **Be professional and respectful** in all communications

## Disclosure Timeline

| Day | Action |
|-----|--------|
| 0 | Discovery — document everything |
| 1-3 | Verify finding, build PoC, write report |
| 3-7 | Send initial disclosure to maintainer (use email-disclosure.md template) |
| 7-14 | Follow up if no acknowledgment received |
| 14-30 | Provide full details once acknowledged, review proposed fix if offered |
| 30-60 | Coordinate fix release timing |
| 60-90 | Final reminder if no fix has been released |
| 90+ | Public disclosure permitted (with final 7-day notice to maintainer) |

## Contact Priority Order

1. **HackerOne / Bug Bounty platform** — if program exists (tracked, paid, CVE auto-requested)
2. **GitHub Security Advisory** — preferred for open source (GHSA → CVE assignment, coordinated)
3. **security@project.com** or SECURITY.md contact — direct email
4. **GitHub Issue** — last resort only, and do NOT include full PoC in public issues

## Initial Contact Rules

- Send brief description only — no full PoC in first contact
- Include: vulnerability type, affected version, severity estimate
- Ask for their preferred disclosure process
- Never threaten public disclosure as leverage
- If maintainer is unresponsive after 30 days, try alternative contacts (GitHub org members, npm maintainers)

## What NOT to Do

- Do not post PoC code in public GitHub issues
- Do not discuss unpatched vulnerabilities publicly (Twitter, Discord, etc.)
- Do not sell vulnerability details to third parties
- Do not access data belonging to other users during testing
- Do not perform denial of service against production infrastructure
- Do not use automated scanning tools against production servers without permission

## After Fix is Released

- Confirm the fix actually resolves the vulnerability
- Allow reasonable time for users to update before full disclosure
- Credit the maintainer team in any public writeup
- Request CVE assignment if not already done
