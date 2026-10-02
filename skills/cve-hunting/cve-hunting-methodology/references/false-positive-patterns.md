# Common False Positive Patterns — Lessons Learned

Common false positive patterns in security research. Every pattern here can waste hours of work. Learn to recognize them early.

This is a security research knowledge base document for educational purposes.

---

## Pattern 1: Package Download Does Not Equal Code Execution

### The Mistake
Found a plugin manager that downloads npm packages from user-specified URLs. Reported as RCE because "attacker-controlled packages can contain install scripts that execute arbitrary code."

### Why It Was Wrong
The plugin manager downloads and extracts packages but does NOT run install scripts (`preinstall`, `postinstall`, `prepare`). It only loads the JavaScript entry point. Downloading a package is not the same as running `npm install` — the dangerous lifecycle scripts are not executed.

### The Lesson
Verify the ENTIRE attack chain. "User controls package URL" only matters if the download mechanism also executes package lifecycle scripts. Read the actual download implementation — does it run `npm install`, or does it just extract files?

### How to Check
- Read the download/install implementation code
- Check if lifecycle scripts (`preinstall`, `postinstall`) are executed
- Test: create a package with a `postinstall` script that writes a marker file. Does the marker appear?
- Look for `child_process` calls in the package manager's install flow

---

## Pattern 2: Capability Already Exists at Required Privilege Level

### The Mistake
Found path traversal in an admin panel that allowed reading arbitrary files. Reported as HIGH severity — admin can read `/etc/passwd` through the file browser.

### Why It Was Wrong
Admin users already had access to an inline command execution feature (like a web terminal). An admin who can run `cat /etc/passwd` through the terminal gains nothing new from a path traversal in the file browser.

### The Lesson
Always ask: "Does this give the attacker access to something they couldn't already do at their current privilege level?" If the answer is no, the finding has no security impact.

### How to Check
- List ALL capabilities of the required privilege level
- Check for: inline command execution, file management, plugin installation, configuration editing
- Ask: "What can this role already do through legitimate features?"
- If admin can already execute commands, file read/write via another vector is redundant

---

## Pattern 3: Testing the Wrong Library Version

### The Mistake
Found SSRF bypass via IPv6-mapped addresses in a localhost-checking library. Reported with detailed PoC showing `[::ffff:127.0.0.1]` bypassing the blocklist.

### Why It Was Wrong
The version installed (v2.0.0) already blocked ALL localhost variants including IPv6-mapped addresses. The bypass only worked in v1.x. The vulnerable behavior had been fixed before the report.

### The Lesson
ALWAYS verify the exact installed version. Not "the latest version", not "the version on GitHub's default branch" — the actual version in the lockfile.

### How to Check
- Read `package.json` or lockfile for exact version
- Search NVD/GHSA for that specific version
- If version is X.Y.Z, check CHANGELOG for security fixes between the version you tested and the current one
- Run `npm ls <package>` or equivalent to see the resolved version
- Test against the installed version, not a cloned repo on a potentially different branch

---

## Pattern 4: Runtime-Level Protections Block the Attack

### The Mistake
Found CRLF injection in HTTP header values — user input flows into response headers without sanitizing carriage return/line feed characters. Reported as header injection (HTTP response splitting).

### Why It Was Wrong
Node.js (since v8.x) rejects CRLF characters in HTTP headers at the runtime level. The `http` module throws a `TypeError` if you try to set a header value containing `\r` or `\n`. The application code doesn't need to sanitize because the runtime prevents it.

### The Lesson
Check runtime-level protections before reporting. Modern runtimes (Node.js, Go, Python 3) have built-in security measures that prevent many classic attack vectors.

### How to Check
- **HTTP headers**: Node.js rejects CRLF since v8.x. Go's net/http rejects them too.
- **SQL**: Modern ORMs use parameterized queries by default
- **Process spawning**: `execFile` with array arguments prevents shell injection
- **URL parsing**: Modern URL parsers reject many malformed inputs
- Test the actual exploit, not just the code path. If the runtime blocks it, it's not exploitable.

---

## Pattern 5: Hardened Sandbox Variant Blocks the Attack

### The Mistake
Found a Node.js application using a VM sandbox for user code execution. Attempted the standard constructor chain escape and reported it as sandbox escape (RCE).

### Why It Was Wrong
The application used a hardened sandbox variant (not plain `node:vm`) that specifically blocks constructor chain traversal. The `constructor` property was intercepted by a Proxy that prevented access to the Function constructor.

### The Lesson
Not all sandboxes are equal. Plain `node:vm` is trivially escapable, but hardened variants (vm2, isolated-vm, custom Proxy-based sandboxes) may block known escape vectors.

### How to Check
- Identify the EXACT sandbox implementation: plain `vm`, `vm2`, `isolated-vm`, or custom
- Check if `constructor` access is blocked (Proxy, Object.defineProperty)
- Test the actual escape in the actual sandbox, not in a vanilla `vm.runInContext()`
- Read the sandbox's README for documented security properties
- Check the sandbox version against known bypasses (e.g., vm2 had multiple bypass CVEs)

---

## Pattern 6: Intentional Design Behavior

### The Mistake
Found that an image processing service allowed setting extreme transformation parameters (resize to 50000x50000, quality=0.001). Reported as resource exhaustion DoS.

### Why It Was Wrong
The service intentionally clamps parameters to safe ranges. Setting `width=50000` is silently clamped to `width=4096`. The behavior is documented and the result is identical to requesting `width=4096`. No resource exhaustion occurs.

### The Lesson
Distinguish between "the parameter is accepted" and "the parameter causes the claimed impact." Many libraries accept extreme inputs but handle them gracefully through clamping, truncation, or defaults.

### How to Check
- Read the actual processing code — does it clamp, truncate, or default extreme values?
- Measure actual resource consumption, don't assume from the parameter value
- Check documentation for parameter limits
- Test: does `width=50000` actually create a 50000px image, or is it clamped?

---

## Pattern 7: Browser vs. Library Responsibility Boundary

### The Mistake
Found a sanitization library that didn't filter a specific XSS vector. Created a PoC showing the unsanitized HTML. Reported as XSS bypass.

### Why It Was Wrong
The specific XSS vector was one that browsers already prevent. The library's job was to sanitize HTML for display — but the test vector relied on browser behavior that no modern browser supports (e.g., `<img src=x onerror>` variants that only work in IE6). The library is not responsible for preventing attacks that the browser already blocks.

### The Lesson
Understand the boundary between library-level and browser-level security. If the browser prevents the attack regardless of what the library does, it's not a library vulnerability.

### How to Check
- Test the PoC in an actual modern browser (Chrome, Firefox, Safari)
- Check if the attack vector requires legacy browser behavior
- Understand what the library is designed to protect against vs. what the browser handles
- Read the library's security documentation for scope/threat model

---

## Pattern 8: Assuming Regex Backtracking Without Measuring

### The Mistake
Found a regex with nested quantifiers (e.g., `(a+)+$`). Reported as ReDoS based on the pattern structure alone, claiming "exponential backtracking."

### Why It Was Wrong
The actual backtracking growth was quadratic (O(n^2)), not exponential. At realistic input lengths (< 1000 chars), the execution time was under 100ms. The input needed to cause a 1-second delay was over 10MB — unrealistic for the library's use case.

### The Lesson
ALWAYS measure actual execution time at multiple input lengths. "The regex has nested quantifiers" is not sufficient evidence of exploitable ReDoS. You must demonstrate exponential growth.

### How to Check
- Create test inputs of increasing length: 10, 15, 20, 25, 30 characters
- Measure execution time for each
- Plot the growth curve: is it linear? Quadratic? Exponential?
- Exponential: doubling time every ~1-2 additional characters
- Quadratic: 2x input = 4x time (still bad at large scale, but often not CVE-worthy)
- Consider: is the required input length realistic for the library's use case?

---

## Pattern 9: Testing Already-Patched Exact Version

### The Mistake
Found prototype pollution in a popular utility library. Wrote a detailed report with PoC, CVSS score, and CWE number. Submitted.

### Why It Was Wrong
The exact version tested (v6.14.2) already contained the fix. The vulnerable code was removed in v6.14.0. The PoC was tested against v6.13.x but the version number in the report said v6.14.2.

### The Lesson
Test against the EXACT version you're reporting. Copy-pasting a version number from `npm info` while testing an older checkout leads to embarrassing rejections.

### How to Check
- `npm ls <package>` or `pip show <package>` to see the actual installed version
- `git log --oneline -20` in the cloned repo to verify which commit you're on
- Check the `version` field in the package's own `package.json` / `setup.py`
- Compare your test version against the latest release — if they differ, retest on latest

---

## Pattern 10: "JSON.parse Does the Same Thing"

### The Mistake
Found that a data parsing library allows setting `__proto__` properties via crafted input. Reported as prototype pollution (CWE-1321).

### Why It Was Wrong
`JSON.parse('{"__proto__": {"polluted": true}}')` creates a plain object with a `__proto__` key — it does NOT pollute `Object.prototype`. The parsing library behaves identically to JSON.parse. The "pollution" only exists on the parsed object itself, not on the prototype chain.

### The Lesson
For clobbering and pollution claims, you must demonstrate impact BEYOND what JSON.parse already does. The question is not "can I set `__proto__`?" but "does setting `__proto__` via this library actually modify `Object.prototype` or cause a real crash?"

### How to Check
- Parse your malicious input, then check: `({}).polluted === true`? If not, it's not real pollution.
- Check if the library assigns to `target[key]` where `target` is a new object (safe) or an existing/shared object (dangerous)
- Test for method clobbering: does setting `toString` cause `TypeError` when the result is later used in string concatenation?
- If the impact is "an object has an extra property," that's JSON.parse behavior, not a vulnerability

---

## Meta-Patterns (Patterns About Patterns)

### The Confirmation Bias Trap
- LLMs (including AI assistants) are biased toward seeing vulnerabilities everywhere
- "This code looks dangerous" is not the same as "this code is exploitable"
- Always ask: "Am I seeing a vulnerability because the pattern LOOKS dangerous, or because I've proven it IS dangerous?"

### The Theoretical vs. Practical Gap
- Theoretical: "If user input reaches this function, it could be dangerous"
- Practical: "User input reaches this function through endpoint X, bypasses sanitization Y, and causes impact Z"
- CVEs are assigned for practical vulnerabilities, not theoretical ones

### The "First Impression" Trap
- Finding a dangerous-looking code pattern creates an emotional investment in reporting it
- The more time you spend writing the report, the harder it is to admit it's a false positive
- Run the self-criticism checklist BEFORE writing the report, not after

### Recovery Time
- A false positive submission costs 2-4 hours (research, writing, correspondence)
- A false positive damages credibility with that maintainer for future reports
- Spending 15 minutes on verification saves hours of wasted effort
