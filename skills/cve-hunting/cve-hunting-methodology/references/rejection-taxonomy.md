# Why Findings Get Rejected — A Complete Taxonomy

Understanding why findings get rejected prevents wasted effort and improves submission quality.

This is a security research knowledge base document for educational purposes.

---

## Category 1: "By Design"

### Description
The behavior you found is documented and intentional. The maintainer designed it that way.

### Signs You're About to Hit This
- The README says "do not use with untrusted input"
- The function name contains "unsafe", "raw", or "dangerous"
- The docs explicitly describe the behavior you're reporting
- The library is a low-level utility meant to be wrapped by application code

### Examples
- **Expression evaluator**: README stated "paths are not intended for untrusted input." Maintainer responded: "This is documented behavior, not a vulnerability."
- **Data serialization library**: "JSON.parse has the same behavior. We are a serialization library, not a security boundary."
- **MongoDB-compatible query engine**: Query operator intentionally evaluates expressions. Author had a safety flag showing awareness of the security implications.

### How to Avoid
1. **Read the README first.** Search for: "untrusted", "security", "warning", "caution", "note"
2. **Check if there's a "safe" mode.** If there's `load()` and `safeLoad()`, reporting that `load()` is unsafe may be "by design"
3. **Look at the API name.** Functions with "raw", "unsafe", or "dangerous" in the name are intentional escape hatches

### What to Do If You Get This Response
- Thank the maintainer for clarifying
- Ask if they'd consider adding a safety option, input validation, or a more prominent warning
- If the behavior is dangerous and NOT well-documented, push back politely: "Many users may not realize this. Would a warning in the error message or a safe-by-default mode be reasonable?"
- Consider whether downstream users are affected — a library that says "don't do X" may have dependents that do X

---

## Category 2: "Already Fixed"

### Description
The exact version you tested already contains a fix for the issue you found.

### Signs You're About to Hit This
- The CHANGELOG mentions a security fix in a recent minor/patch release
- Recent commits touch the exact code path you're looking at
- The library has had multiple prior CVEs for similar issues

### Examples
- **Prototype pollution in query string parser**: Reported against v6.14.x, but that exact version already had the fix. The vulnerable code was in v6.13.x.
- **SSRF bypass via IPv6**: Reported against the IP-blocking library, but v2.0.0 already blocked ALL localhost variants including IPv6-mapped addresses. Only v1.x was vulnerable.

### How to Avoid
1. **Check the exact version number** in `package.json`, `requirements.txt`, `go.mod`, or `Gemfile.lock`
2. **Search NVD and GHSA** for the package name + vulnerability type before writing your report
3. **Read recent CHANGELOG entries** for "security", "fix", "patch", "CVE"
4. **Check git blame** on the specific vulnerable lines — if they were recently modified, the fix may already be in

### What to Do If You Get This Response
- Ask which version introduced the fix
- Check if the fix is complete — incomplete patches are common and have ~95% acceptance rate as new findings
- Check if the advisory was published — sometimes the fix is in the code but no CVE was requested

---

## Category 3: "Duplicate"

### Description
Another researcher reported the same issue first.

### Signs You're About to Hit This
- The package has recent security advisories on GHSA
- The package has active HackerOne reports
- The specific code path already has a "security" comment or TODO
- The package recently published a patch version with no feature changes

### Examples
- **Path traversal in file server**: Submitted GHSA, but another researcher had reported via private email 3 days earlier. Advisory was already in draft.
- **Decompression bomb in archive library**: Maintainer had received the same report from another researcher and already had a fix branch.

### How to Avoid
1. **Search GHSA** for the package before submitting
2. **Search NVD** with package name
3. **Check GitHub Issues** filtered by "security" label
4. **Move fast** — once you find something, submit within 24 hours
5. **Check for draft/unpublished advisories** — if you see a recent patch version bump with no features, someone may have already reported

### What to Do If You Get This Response
- Thank the maintainer
- Ask for the CVE ID for your records
- Ask if there are related areas they'd like audited — builds goodwill
- Move on to the next target

---

## Category 4: "Insufficient Impact"

### Description
The vulnerability is real, but the impact is too low to warrant a CVE.

### Signs You're About to Hit This
- The crash is a catchable exception (RangeError, TypeError) not an OOM/segfault
- Triggering requires privileges that already grant equivalent access
- The impact is only "slow performance", not a crash or data breach
- The finding requires a very large payload (> 1 MB of input) to trigger

### Examples
- **Admin file read**: Reported path traversal, but admin users could already read arbitrary files through an inline execution feature. The capability was not new.
- **RangeError in recursive parser**: The recursive call caused a RangeError that was caught by the calling code. No process crash. Maintainer: "This is handled gracefully."
- **Image processing parameter abuse**: Reported that transformation parameters could be set to extreme values. Maintainer: "We intentionally clamp these values. This is a feature."

### How to Avoid
1. **For DoS**: Verify OOM (process crash, signal 9) not just RangeError (catchable)
2. **For access control**: Check if the required privilege level already grants the same access via other means
3. **For resource consumption**: Show that small input (< 10 KB) causes disproportionate resource usage
4. **For crashes**: Confirm the error is NOT caught by a try/catch in the calling code

### How to Escalate Impact
- Can the DoS be triggered without authentication?
- Can the finding be chained with another vulnerability?
- Does the crash affect other users (shared server process)?
- Can the catchable error be used to leak information?

### What to Do If You Get This Response
- Ask the maintainer what level of impact they'd consider CVE-worthy
- Try to escalate: chain with another finding, demonstrate in a more impactful context
- If legitimately low impact, accept it and move on

---

## Category 5: "Not a Security Bug"

### Description
The behavior is a bug or quality issue, but not a security vulnerability.

### Signs You're About to Hit This
- The bug only affects the user who triggers it (self-DoS)
- It's a robustness/reliability issue, not a confidentiality/integrity/availability issue
- The code path is only reachable in debug/test mode
- The behavior has no security consequence (e.g., incorrect output but no information leak)

### Examples
- **Browser XSS claim**: Reported XSS bypass in a sanitization library, but the actual protection was provided by the browser's built-in XSS filter, not the library. The library's job was different.
- **Debug-mode information disclosure**: Reported that debug mode exposed internal state. Maintainer: "Debug mode is for development. It's not meant to be run in production."
- **Operational DoS**: Reported that processing a malformed file was slow. Maintainer: "This is a bug in our parser, not a security vulnerability. We'll fix the parsing, but it's not a CVE."

### How to Avoid
1. **Ask**: "Can an attacker use this to affect ANOTHER user's data, session, or availability?"
2. **Distinguish**: Bug (incorrect behavior) vs. vulnerability (exploitable for security impact)
3. **Check scope**: Self-DoS is not a vulnerability. Cross-user impact is.
4. **Check context**: Test-only, debug-only, or development-only code paths are not security targets

### What to Do If You Get This Response
- Accept the distinction — maintainers know their threat model
- If you disagree, explain the threat scenario from an attacker's perspective with specific steps
- Reference similar CVEs in comparable projects as precedent

---

## Category 6: "Won't Fix"

### Description
The maintainer acknowledges the issue but will not fix it.

### Sub-categories

#### 6a: Deprecated/Unmaintained
- The package is no longer actively maintained
- The maintainer recommends migrating to an alternative
- No one is available to write or review a fix

#### 6b: Alpha/Beta/Pre-release
- The software is explicitly pre-release
- The maintainer does not consider pre-release software CVE-eligible
- "We'll address this before the stable release"

#### 6c: Threat Model Disagreement
- The maintainer disagrees that this is a realistic attack scenario
- "Our users don't pass untrusted input to this function"
- "This requires local access, which means the attacker already has control"

#### 6d: Breaking Change Required
- The fix would break backward compatibility
- The fix is planned for the next major version
- The maintainer is unwilling to make the breaking change

### Examples
- **Method clobbering in object utility**: Maintainer responded: "This is standard JavaScript property shadowing. We won't fix."
- **Code injection in schema validator alpha**: Maintainer confirmed the bug but said: "This is alpha software. We won't issue a CVE, but we'll fix it."
- **Recursion DoS in data serialization**: Maintainer responded: "JSON.parse has the same behavior. We match JSON semantics by design."

### How to Avoid
1. **Check maintenance status**: Last commit > 12 months? May be abandoned.
2. **Check release stage**: Alpha, beta, RC — maintainers rarely issue CVEs for these
3. **Check prior security responses**: If the maintainer has rejected similar reports before, they likely will again
4. **Validate threat model**: Is your attack scenario realistic for how the library is actually used?

### What to Do If You Get This Response
- For unmaintained packages: Consider filing a GHSA yourself (GitHub allows third-party advisories)
- For alpha/beta: Note it for later and re-check after stable release
- For threat model disagreement: Provide concrete evidence of real-world usage patterns
- For breaking changes: Ask about the timeline for the next major version
- Always remain professional and thank the maintainer for their time

---

## Cross-Category Patterns

### The "JSON.parse Defense"
Many maintainers of parsing/serialization libraries will respond with: "JSON.parse has the same behavior." This applies to:
- Prototype pollution via `__proto__` key
- Method clobbering via `toString`/`valueOf` keys
- Recursive structures causing stack overflow

**Counter-arguments**:
- "JSON.parse processes trusted API responses. Your library processes untrusted user uploads."
- "JSON.parse is a language built-in with broad documentation. Users may not expect your library to have the same risks."
- Demonstrate a REAL crash or security impact, not just the theoretical ability to set a property

### The "Admin Already Has Access" Defense
If exploiting the vulnerability requires admin privileges, ask:
- Does the admin role actually grant this level of access through intended features?
- Are there different admin roles with different privilege levels?
- Is the finding accessible to a lower-privileged role than intended?

### The "Operational, Not Security" Defense
When maintainers call it operational:
- Show cross-user impact (shared server process affected)
- Show unauthenticated triggering
- Show the asymmetry (small input, large impact)
- Reference similar CVEs that were accepted in comparable libraries

---

## Rejection Rate by Submission Channel

| Channel | Typical Rejection Rate | Notes |
|---------|----------------------|-------|
| GitHub Security Advisory (GHSA) | ~30% | Best for open source, formal process |
| HackerOne | ~40% | Higher bar, scope disputes common |
| Direct email | ~35% | Varies wildly by maintainer |
| GitHub Issue (public) | ~60% | Often dismissed, may anger maintainers |

These rates are for legitimate findings. Low-quality submissions (no PoC, wrong version, theoretical only) see 80%+ rejection regardless of channel.
