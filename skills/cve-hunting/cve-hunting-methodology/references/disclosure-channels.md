# Disclosure Channels — When to Use Which

Complete guide to responsible disclosure channels for open-source vulnerabilities.

This is a security research knowledge base document for educational purposes.

---

## Channel Comparison

| Channel | Best For | CVE Assignment | Response Time | Tracking | Payment |
|---------|----------|----------------|---------------|----------|---------|
| GitHub Security Advisory (GHSA) | Open source on GitHub | Yes (GitHub CNA) | 3-14 days | Built-in | No |
| HackerOne | Projects with bounty programs | Yes (HackerOne CNA) | 1-7 days | Built-in | Yes |
| security@project.com | Direct contact | Manual (via MITRE) | 1-30 days | None | Rarely |
| GitHub Issue (public) | Last resort only | No | Hours | Public | No |
| MITRE CVE Request | No other channel works | Yes | 30-90 days | CVE ID only | No |

---

## Channel 1: GitHub Security Advisory (GHSA)

### When to use
- Open-source project hosted on GitHub
- No bug bounty program
- Maintainer has not specified a preferred channel
- You want CVE assignment through a formal process

### Advantages
- GitHub acts as a CNA (CVE Numbering Authority) — can assign CVE IDs directly
- Private fork for developing fixes collaboratively
- Structured advisory format with CVSS scoring
- Maintainer gets notified and can manage the timeline
- Third-party researchers can submit advisories
- Advisories are indexed in the GitHub Advisory Database

### Disadvantages
- Triage depends on maintainer responsiveness
- No mediation if maintainer disagrees
- No payment
- Some maintainers ignore GHSA notifications

### Step-by-step Process
1. Navigate to the repository on GitHub
2. Click "Security" tab -> "Advisories" -> "New draft security advisory"
3. Fill in:
   - **Title**: `[Vuln Type] in [Component] allows [Impact]`
   - **Description**: Full technical details, reproduction steps, impact
   - **Severity**: Select CVSS score (GitHub provides a calculator)
   - **Affected versions**: Specify the version range
   - **CWE**: Select the appropriate CWE ID
   - **CVE ID**: Check "Request CVE ID"
4. Submit the advisory
5. Wait for maintainer response
6. If fix is developed, the maintainer can create a private fork through the advisory

### Tips
- Include a complete PoC in the description
- Use the GHSA markdown format — it renders well
- If the maintainer doesn't respond in 14 days, GitHub's security team may assist
- You can submit a GHSA even if you're not a contributor to the project

### Advisory Title Format
```
[CWE-XXX] Vulnerability type in component_name allows impact_description
```
Examples:
- `[CWE-78] Command injection in build handler allows arbitrary command execution`
- `[CWE-22] Path traversal in file extraction allows writing outside target directory`
- `[CWE-776] Entity expansion in XML parser allows denial of service`

---

## Channel 2: HackerOne

### When to use
- The project has an active HackerOne program
- You want payment for your finding
- The project scope includes the vulnerability type you found
- You need mediation support for disputed findings

### Advantages
- Payment for valid findings
- Formal triage process with SLAs
- Mediation if researcher and maintainer disagree
- CVE assignment through HackerOne's CNA
- Reputation system and leaderboards
- Structured communication timeline

### Disadvantages
- Scope disputes are common
- Triage can be slow (especially for lower-tier programs)
- Some programs have narrow scope that excludes DoS, info disclosure, etc.
- Duplicate risk is higher (more researchers watching)
- Payment amounts vary wildly

### Step-by-step Process
1. Search HackerOne directory: https://hackerone.com/directory
2. Read the program scope document CAREFULLY
3. Verify your finding is in scope (vulnerability type + affected component)
4. Write your report following their template:
   - **Title**: Clear, specific vulnerability description
   - **Severity**: CVSS vector and score
   - **Description**: Technical details of the vulnerability
   - **Steps to Reproduce**: Numbered list, reproducible by anyone
   - **Impact**: What an attacker can achieve
   - **Supporting Material**: PoC scripts, screenshots, videos
5. Submit the report
6. Wait for triage (typically 1-7 days for active programs)

### Report Template
```
## Summary
[One paragraph describing the vulnerability]

## Severity
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H = 9.8 CRITICAL

## Steps to Reproduce
1. Install [package] version [X.Y.Z]
2. Create a file `poc.py` with the following content:
   [code block]
3. Run: `python3 poc.py`
4. Observe: [specific output showing the vulnerability]

## Impact
An attacker can [specific impact] by [specific action], resulting in
[confidentiality/integrity/availability impact].

## Affected Versions
- Tested: vX.Y.Z
- Estimated affected range: >= vA.B.C, < vX.Y.Z

## Suggested Fix
[Brief description of the fix approach]
```

### Common Pitfalls
- Submitting out-of-scope findings (always read the policy)
- Submitting without a working PoC (instant rejection at many programs)
- Claiming severity higher than justified (hurts credibility)
- Not checking for duplicates (search closed reports if available)

---

## Channel 3: Direct Email (security@project.com)

### When to use
- The project has a SECURITY.md with an email address
- No GHSA or HackerOne program
- The maintainer prefers direct communication
- You want a fast, informal initial contact

### Advantages
- Direct line to the maintainer
- Fast response from responsive maintainers
- Flexible format
- Good for initial contact before formal submission

### Disadvantages
- No tracking or SLAs
- May go to spam
- No mediation if maintainer is unresponsive
- CVE assignment requires separate MITRE request
- No proof of submission date

### First Contact Email Template
```
Subject: [Security] [SEVERITY] vulnerability in [Project] v[Version]

Hi [maintainer name],

I found a security vulnerability in [Project] that I'd like to report
through responsible disclosure.

Summary: [One sentence description]
Type: [CWE-XXX: Name]
Severity: [CVSS score and rating]
Affected: v[version range]

I have a complete PoC and detailed writeup ready. What is your
preferred channel for receiving the full report?

I follow a 90-day responsible disclosure timeline.

Best regards,
[Your name]
```

### Follow-up Email Template (Day 7)
```
Subject: Re: [Security] [SEVERITY] vulnerability in [Project] v[Version]

Hi [maintainer name],

Following up on my security report from [date]. I want to make sure
it reached you — please let me know if you'd like me to resend or
use a different channel.

Happy to provide any additional information.

Best regards,
[Your name]
```

### Finding the Right Email
1. Check SECURITY.md in the repository
2. Check the project's website for a security contact
3. Check the maintainer's GitHub profile for an email
4. Check npm/PyPI package metadata for maintainer email
5. Last resort: check git log for commit author emails

### Important Notes
- First email should be brief — no full PoC in first contact
- Wait for acknowledgment before sending details
- Use PGP encryption if the maintainer provides a public key
- BCC yourself for proof of send date

---

## Channel 4: GitHub Issue (Public)

### When to use
- ONLY as a last resort after all private channels have been exhausted
- After the 90-day disclosure window has passed with no response
- For informational findings with no security impact (e.g., dependency updates)

### Advantages
- Gets attention (public pressure)
- Creates a permanent record
- Other researchers can confirm

### Disadvantages
- Immediately exposes users to risk
- May anger the maintainer
- No confidentiality
- Generally considered irresponsible for active vulnerabilities
- No CVE assignment

### When it IS appropriate
- Vulnerability is already publicly known (e.g., dependency with published CVE)
- 90-day window has passed with no private response
- The finding is LOW severity with no meaningful exploit

### When it is NOT appropriate
- You haven't tried private channels first
- The vulnerability is exploitable (HIGH/CRITICAL)
- You're posting to pressure the maintainer before the 90-day window
- You're posting to gain attention/credit before the fix is available

---

## Channel 5: MITRE CVE Request (Direct)

### When to use
- No other channel provides CVE assignment
- The project is not on GitHub (or GHSA is not available)
- The maintainer has fixed the issue but won't request a CVE
- You need a CVE for a vulnerability in software without a dedicated security process

### Process
1. Go to https://cveform.mitre.org/
2. Select "Request a CVE ID"
3. Fill in all required fields:
   - Vulnerability type and CWE
   - Affected product and versions
   - Description of the vulnerability
   - References (advisory links, fix commits)
4. Submit and wait (MITRE's backlog can be 30-90 days)

### Tips
- Include as much detail as possible — MITRE reviews are manual
- Reference the fix commit or advisory if available
- Provide a clear, concise description suitable for the CVE entry
- Be patient — MITRE has a significant backlog

---

## Choosing the Right Channel — Decision Tree

```
Does the project have a HackerOne/Bugcrowd program?
  YES -> Is your finding in scope?
    YES -> Use HackerOne/Bugcrowd
    NO  -> Continue below
  NO  -> Continue below

Is the project on GitHub?
  YES -> Does the project accept security advisories?
    YES -> Use GitHub Security Advisory (GHSA)
    NO  -> Continue below
  NO  -> Continue below

Does the project have a SECURITY.md or security email?
  YES -> Use direct email
  NO  -> Continue below

Can you find the maintainer's email (git log, npm, PyPI)?
  YES -> Use direct email
  NO  -> File a GHSA (third-party advisory) or use MITRE
```

---

## Timeline Management

### Standard Responsible Disclosure (90 days)

| Day | Action |
|-----|--------|
| 0 | Submit report through chosen channel |
| 1-3 | Acknowledgment expected (send follow-up if not received) |
| 7 | First follow-up if no acknowledgment |
| 14 | Second follow-up or try alternative channel |
| 30 | Fix should be in progress. Check in on timeline. |
| 60 | Fix should be nearing completion. Final timeline check. |
| 90 | Disclosure window closes. You may publish. |

### Extensions
- If the maintainer is actively working on a fix and communicating, extend the window
- If the fix is complex and requires coordination, extend by 30 days
- If there's no communication despite multiple attempts, the 90-day window stands

### Early Disclosure (before 90 days)
Only acceptable if:
- The vulnerability is being actively exploited in the wild
- The maintainer has published a fix and advisory
- The maintainer explicitly agrees to early disclosure

---

## Post-Disclosure

### After CVE Assignment
1. Update your report with the CVE ID
2. If you have a security blog, publish a writeup (after fix is available)
3. Add the CVE to your portfolio
4. Thank the maintainer publicly for their responsiveness

### Credit
- Always ask to be credited as the finder/reporter
- Provide your preferred name and affiliation for the advisory
- Some projects credit researchers in CHANGELOG or SECURITY.md
- GitHub Security Advisories automatically credit the reporter
