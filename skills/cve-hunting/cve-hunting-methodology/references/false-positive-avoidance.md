# False Positive Avoidance — Mandatory Pre-Submission Checks

**Every finding MUST pass ALL of these checks before submission. No exceptions.**

## Gate 1: fp-check Verification (6 Gates)

Run the fp-check skill. All 6 gates must pass:

| Gate | Question | FAIL means |
|------|----------|------------|
| 1. Process | Were all analysis phases completed with evidence? | Incomplete analysis |
| 2. Reachability | Can an attacker actually reach and control data at the vulnerable point? | Theoretical only |
| 3. Real Impact | Does exploitation lead to real security consequences? | No meaningful impact |
| 4. PoC Validation | Does the PoC demonstrate the actual attack path? | Unproven claim |
| 5. Math Bounds | Does mathematical analysis confirm the vulnerable condition? | Numbers don't add up |
| 6. Environment | Do environmental protections entirely prevent exploitation? | Blocked at runtime |

## Gate 2: Self-Criticism Checklist (7 Items)

Answer honestly. If ANY answer is "yes", investigate further before submitting:

1. **README warning?** — Does the README/docs warn against untrusted input?
2. **Intended behavior?** — Is this documented/designed behavior, not a bug?
3. **Already handled?** — Does the library already handle this gracefully?
4. **Alpha/beta?** — Is this pre-release? Will the maintainer issue a CVE?
5. **Over-researched?** — How many recent CVEs? Am I racing other researchers?
6. **JSON.parse equivalence?** — For clobbering: does JSON.parse do the same thing? Can I show a REAL crash?
7. **Error severity?** — For recursion: is it OOM (real DoS) or just RangeError (caught)?

## Gate 3: Version Verification

1. Read `package.json` / `requirements.txt` / `go.mod` for exact version
2. Search NVD for that exact version — may already be patched
3. Search GHSA and OSV.dev for existing advisories
4. Check CHANGELOG for "security fix" entries
5. Check git log for security-related commits since that version
6. **Test against the LATEST release**, not just whatever is in node_modules

## Gate 4: Default Configuration Test

- Only report vulnerabilities that exist in the **default configuration**
- If a non-default option must be enabled, the severity drops significantly
- Document any configuration requirements in the report

## Gate 5: PoC Execution (3x Minimum)

1. Run PoC against clean install of latest version
2. Run 3 times minimum — must succeed every time
3. **Fail 3 times = FALSE POSITIVE. Move on immediately. No exceptions.**
4. Evidence must match the claimed impact exactly

## Gate 6: Similar CVE Search

Before submitting, search all of:
- NVD (nvd.nist.gov) — `scripts/check-nvd.sh <package>`
- GitHub Advisory Database (github.com/advisories)
- OSV.dev — `scripts/check-osv.sh <ecosystem> <package>`
- Snyk vulnerability database (snyk.io/vuln)

If a similar CVE exists, determine:
- Is this the same issue? → DUPLICATE, do not submit
- Is this an incomplete fix of a prior CVE? → Document the prior CVE and explain what's still broken
- Is this a different vulnerability in the same component? → Proceed, reference the prior CVE

## Historical False Positives to Learn From

| Project | Claimed | Reality | Lesson |
|---------|---------|---------|--------|
| FUXA | RCE via npm install scripts | live-plugin-manager doesn't run install scripts | Package download != code execution |
| Rundeck | Path traversal file read | Admins can already read files via exec | Check if access is genuinely new |
| Strapi | SSRF via IPv6 bypass | v2.0.0 blocks ALL localhost variants | Test the actual library version |
| Payload CMS | CRLF header injection | Node.js rejects CRLF at runtime level | Check runtime protections |
| Flowise | NodeVM sandbox escape | @flowiseai/nodevm blocks constructor chains | Test actual implementation |
| sanitize-html | XSS bypass | Browser XSS protection, not library bug | Know library vs browser boundary |
| validator.js | ReDoS | No exponential backtracking confirmed | Measure actual regex growth rate |
| qs v6.14.2 | Prototype pollution | Already patched in this exact version | Always check exact version number |
