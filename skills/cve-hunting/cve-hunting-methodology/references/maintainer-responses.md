# Common Maintainer Responses and How to Handle Them

Professional, respectful guidance for handling every type of maintainer response.
The goal is always: get the vulnerability fixed, get users protected, maintain good relationships.

This is a security research knowledge base document for educational purposes.

---

## Core Principles

1. **Maintainers are volunteers.** Most open-source maintainers are unpaid. Respect their time.
2. **Assume good faith.** If they push back, assume they have context you don't.
3. **Be specific, not argumentative.** Concrete evidence > persuasive rhetoric.
4. **One follow-up maximum.** If two messages don't resolve it, use alternative channels.
5. **Always thank them.** Even for rejections. Especially for rejections.

---

## Response Type 1: "Won't Fix — Documented Behavior"

### What they say
- "This is documented behavior. See [docs link]."
- "Our README explicitly states not to use this with untrusted input."
- "This is by design."

### How to respond
```
Thank you for the quick response. I understand this is documented behavior.

A few users of your library may not be aware of this, particularly since
[specific scenario where users likely pass untrusted input]. Would you
consider any of the following?

1. A more prominent warning in the README (e.g., a security section)
2. An optional "safe mode" parameter that restricts dangerous behavior
3. A runtime warning when potentially dangerous input is detected

I appreciate your time regardless. Happy to help if any of these are of interest.
```

### When to push back
- The README warning is buried or missing entirely
- The library's most common use case (based on GitHub code search) involves untrusted input
- The documentation contradicts the behavior (e.g., docs say "sanitized" but it's not)

### When to accept
- The README has a clear, prominent security warning
- The function name itself indicates danger ("unsafe", "raw", "dangerous")
- The library is explicitly designed for trusted-input scenarios (e.g., build tools, dev utilities)

---

## Response Type 2: "This Is Intended Behavior"

### What they say
- "This is a feature, not a bug."
- "We intentionally allow this."
- "Users who need this behavior rely on it."

### How to respond
```
Thank you for explaining the design intent. I appreciate the context.

I'd like to share a concern from the user perspective: [describe realistic
scenario where this behavior creates a security risk]. In particular,
[package X with Y weekly downloads] uses your library and passes user input
to this function.

Would you be open to discussing a safe default with an opt-in for the
current behavior? This would protect users who aren't aware of the risk
while preserving the functionality for those who need it.
```

### When to push back
- Downstream packages demonstrably pass untrusted input to the function
- The behavior causes memory safety issues (OOM, segfault) not just incorrect output
- Similar behavior received CVEs in comparable libraries

### When to accept
- The behavior is clearly a feature that power users depend on
- Changing it would break legitimate use cases
- The security risk requires a contrived, unlikely scenario

---

## Response Type 3: "Can You Provide a PoC?"

### What they say
- "Can you demonstrate this?"
- "I need a reproducible example."
- "How exactly would an attacker exploit this?"

### How to respond
Always have a PoC ready BEFORE submitting. When they ask, send it immediately.

**PoC structure:**
```
Here's a complete reproduction:

Environment: Node.js v20.x, [library] v[version]

Steps:
1. Install: npm install [library]@[version]
2. Create test.js with the following content:
   [minimal reproduction code — under 20 lines]
3. Run: node test.js

Expected (safe) behavior: [what should happen]
Actual (vulnerable) behavior: [what happens — with output]

Impact: [concrete security consequence]
```

### Key rules
- PoC should be under 20 lines of code
- Must run with no external dependencies beyond the target package
- Must produce clear, unambiguous output showing the vulnerability
- Include expected vs. actual behavior
- Test the PoC yourself at least 3 times before sending

---

## Response Type 4: "We Need More Information"

### What they say
- "Can you provide more details?"
- "What's the severity?"
- "Which versions are affected?"

### How to respond
Provide a complete structured report:

```
Vulnerability Details:

Type: [CWE-XXX: Name]
Severity: [CVSS vector string] = [score] [rating]
Affected versions: [range, e.g., >=3.0.0, <3.5.2]
Fixed in: [version if known, or "not yet fixed"]

Root cause: [file:line — brief description of the flaw]
Attack vector: [how an attacker reaches the vulnerable code]
Impact: [what an attacker can achieve]

Reproduction: [link to PoC or inline code]

Suggested fix: [brief description or draft patch if available]
```

### Tips
- CVSS calculator: https://www.first.org/cvss/calculator/3.1
- Include the vector string, not just the score — shows you calculated it properly
- "Affected versions" should be a range, not "all versions" (test the boundaries)

---

## Response Type 5: "This Is a Duplicate"

### What they say
- "We've already received this report."
- "This is a known issue. See [CVE/GHSA link]."
- "Another researcher reported this."

### How to respond
```
Thank you for letting me know. Could you share the CVE ID or advisory
link for my records? I'd like to ensure I don't duplicate this in the future.

If there are other areas of the codebase you'd like reviewed, I'm happy
to take a look. I found this during a broader audit and may be able to
contribute further.
```

### Before assuming it's truly a duplicate
- Read the existing advisory carefully — is it the exact same root cause, or a similar-but-different issue?
- If your finding is a bypass of an existing fix, it's NOT a duplicate — it's a new CVE
- If the existing advisory covers a different code path, your finding may be separate

---

## Response Type 6: "We're Working on a Fix"

### What they say
- "Thanks, we're aware and working on a patch."
- "Fix is in progress."
- "We'll have this resolved in the next release."

### How to respond
```
Great to hear. A few things I can offer:

1. I'm happy to review the patch before release if that would be helpful
2. Would you like me to coordinate on disclosure timing?
3. I follow the standard 90-day responsible disclosure timeline from
   first acknowledgment

Please let me know if there's anything else I can contribute.
```

### Follow-up timeline
- If no update after 14 days: one polite follow-up asking about timeline
- If no update after 30 days: second follow-up, mention the 90-day window
- At 90 days: publish if no response (standard responsible disclosure)
- Be flexible — if they're actively working on it, extend the window

---

## Response Type 7: No Response

### Timeline
| Days since submission | Action |
|----------------------|--------|
| 7 days | Send one polite follow-up on the same channel |
| 14 days | Try an alternative channel (email if you used GHSA, or vice versa) |
| 21 days | Check if there's a security team or other contact (SECURITY.md) |
| 30 days | Consider filing a GHSA directly (GitHub allows third-party advisories) |
| 90 days | Standard disclosure timeline. You may publish. |

### Follow-up template (Day 7)
```
Hi [maintainer],

Just following up on the security report I sent on [date] regarding
[brief description]. I understand you may be busy — just want to make
sure it reached you.

Happy to provide any additional information or discuss the finding.

Best regards
```

### Important notes
- Never send more than 2 follow-ups on the same channel
- After 2 unanswered follow-ups, switch channels
- Do NOT post publicly until the 90-day window has passed
- Consider the possibility that your report went to spam

---

## Response Type 8: Hostile or Dismissive Response

### What they say
- "This is FUD."
- "You clearly don't understand our codebase."
- "Stop wasting our time."
- "This is not a real vulnerability, go away."

### How to respond
Stay completely professional. Do not match their tone.

```
I understand we may disagree on the severity. I'd like to share some
additional context that may be helpful:

1. This behavior maps to [CWE-XXX: Name], which is a recognized
   vulnerability class
2. Similar findings received [CVE-YYYY-XXXXX] in [comparable project]
3. [CVSS vector] produces a score of [X.X], which is [rating] severity

I'm sharing this in good faith to help protect your users. If you'd
prefer, I can file this through GitHub's Security Advisory process,
which provides a structured framework for evaluation.

Thank you for your time.
```

### When to escalate
- If the vulnerability is HIGH/CRITICAL severity and the maintainer is non-responsive
- File a GHSA directly — GitHub's security team will review independently
- If the project is on a bug bounty platform, use that platform's mediation process
- NEVER threaten public disclosure as leverage — that's coercive

---

## Response Type 9: "That's Not a Security Issue"

### What they say
- "This is an operational concern, not a security vulnerability."
- "This is a quality bug, not a security bug."
- "We don't consider DoS to be a security issue."

### How to respond
```
I appreciate the distinction. Let me explain why I believe this has
security implications:

1. Attack scenario: [specific steps an attacker would take]
2. Impact: [specific security consequence — data breach, service
   disruption affecting other users, etc.]
3. Precedent: [reference CWE and similar CVEs in comparable projects]
4. CVSS assessment: [vector string showing the security impact dimensions]

The key security dimension here is [confidentiality/integrity/availability]
impact on [other users / the system / data]. If this only affected the
attacker themselves, I would agree it's operational. However, [explanation
of cross-user or cross-system impact].
```

---

## Response Type 10: "Submit Via Our Bug Bounty"

### What they say
- "Please submit this through our HackerOne program."
- "We handle security reports through [platform]."
- "Our bug bounty program is the correct channel."

### How to respond
Always follow their preferred channel. Do not push back.

```
Thank you for directing me. I'll submit through your [platform] program
right away. I'll reference this conversation for context.
```

### Tips for bug bounty submissions
- Read the scope document CAREFULLY before submitting
- Include everything they ask for (even if your email report was accepted as-is elsewhere)
- Follow their template, not yours
- Be patient with triage — bounty programs often have longer response times
- If the scope explicitly excludes your finding type, ask before submitting

---

## General Communication Tips

### Do
- Lead with the impact, not the technical details
- Use the maintainer's preferred communication channel
- Include a PoC in every initial report
- Credit the maintainer's work — "I was reviewing your well-written library when..."
- Offer to help write a fix or review a patch
- Use CWE numbers — they add credibility and specificity

### Don't
- Threaten public disclosure
- CC unnecessary parties in private communications
- Post details publicly before the fix is released
- Argue about severity after two exchanges — escalate to GHSA instead
- Submit low-quality reports (no PoC, wrong version, theoretical-only)
- Be condescending or claim expertise over the maintainer's own code
- Send the same report to multiple channels simultaneously (confusing and annoying)

### Email Subject Line Format
```
[Security] [Severity] vulnerability in [Project] [Version]
```
Examples:
- `[Security] HIGH: Path traversal in file-handler v3.2.1`
- `[Security] CRITICAL: Code injection in template-engine v2.0.0`
