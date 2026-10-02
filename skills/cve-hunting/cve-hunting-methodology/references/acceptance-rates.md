# CVE Acceptance Rates by Vulnerability Class

Approximate acceptance rates based on patterns observed across open-source security research.

This is a security research knowledge base document for educational purposes. Patterns described
here are for identifying vulnerabilities in open-source software for responsible disclosure.

---

## Tier 1: Highest Acceptance (~85-90%)

### Code Injection in Code-Generation Libraries
- **Acceptance rate**: ~90%
- **Typical severity**: HIGH 8.1 to CRITICAL 9.8
- **CWEs**: CWE-94 (Code Injection), CWE-95 (Eval Injection)
- **Why high acceptance**: The impact is undeniable — arbitrary code execution. Maintainers rarely argue.
- **Common rejection reasons**:
  - Library explicitly documents "do not use with untrusted input" in README
  - The code path requires admin-level privileges that already grant equivalent access
- **Tips to maximize acceptance**:
  - Show full RCE, not just code evaluation reaching user input — demonstrate actual OS command execution
  - Target dynamic function constructors, template compilation, schema validators that generate code, and expression evaluators
  - The block comment escape pattern in code generators is underexplored — standard JSON serialization does not escape it
  - Check for incomplete patches on prior CVEs — bypass variants have ~95% acceptance

### Entity Expansion / Billion Laughs
- **Acceptance rate**: ~90%
- **Typical severity**: HIGH 7.5
- **CWEs**: CWE-776 (Improper Restriction of Recursive Entity References)
- **Why high acceptance**: Well-understood attack, clear OOM crash, easy to demonstrate
- **Common rejection reasons**:
  - Parser has built-in entity expansion limits (rare in JS/Go, common in Python/Java)
  - XML features are disabled by default and must be explicitly enabled
- **Tips to maximize acceptance**:
  - Demonstrate OOM crash, not just slow performance
  - Calculate amplification ratio (e.g., "10 KB input produces 3 GB memory allocation")
  - Check SVG parsers too — they parse XML but often forget entity expansion limits
  - YAML alias expansion is the same class — anchor/alias chains cause exponential expansion

### Command Injection
- **Acceptance rate**: ~85%
- **Typical severity**: CRITICAL 9.8
- **CWEs**: CWE-78 (OS Command Injection)
- **Why high acceptance**: Direct RCE, highest possible impact
- **Common rejection reasons**:
  - Process spawning uses array arguments (not shell-interpreted)
  - Python subprocess without `shell=True`
  - Input is sanitized/escaped before reaching the shell
- **Tips to maximize acceptance**:
  - Always prove the full chain: user input -> shell command -> execution
  - Show it works in default configuration, not custom/debug setup
  - Check for shell metacharacter injection even in array-argument calls if any argument is later concatenated into a string

### Path Traversal / Zip Slip
- **Acceptance rate**: ~85%
- **Typical severity**: HIGH 7.5 to HIGH 8.6
- **CWEs**: CWE-22 (Path Traversal), CWE-59 (Symlink Following)
- **Why high acceptance**: File system access outside intended directory is clear-cut
- **Common rejection reasons**:
  - `path.resolve()` is called before the access check (normalizes `../`)
  - Framework-level middleware normalizes paths
  - The traversal only works on Windows (backslash) but the package is Linux-only
- **Tips to maximize acceptance**:
  - `path.join()` does NOT prevent `../` in Node.js — this is a common misconception that leads to real vulnerabilities
  - For Zip Slip: test both forward slash (`../`) and backslash (`..\`) variants
  - Symlink-based traversal (CWE-59) is often missed even when `../` is filtered
  - Check for `indexOf()` bypass: `name.indexOf('../') === -1` misses `foo/../../bar`
  - Incomplete patches of prior CVEs (e.g., only fixing `/` but not `\`) have very high acceptance

---

## Tier 2: Good Acceptance (~70-80%)

### Sandbox Escape (node:vm, eval sandboxes)
- **Acceptance rate**: ~80%
- **Typical severity**: CRITICAL 9.9
- **CWEs**: CWE-94 (Code Injection)
- **Why good acceptance**: Even though node:vm is documented as insecure, projects that use it for security boundaries still get CVEs
- **Common rejection reasons**:
  - Project uses a hardened sandbox variant that blocks constructor chains
  - The sandbox is only used for developer tooling, not untrusted input
- **Tips to maximize acceptance**:
  - Standard constructor chain escape: access the process object via constructor traversal
  - Check for Proxy-based sandboxes — they often have bypasses via Symbol.toPrimitive or __proto__
  - If using a hardened variant, check for known bypasses in the specific version

### SQL Injection
- **Acceptance rate**: ~80%
- **Typical severity**: HIGH 8.1 to CRITICAL 9.8
- **CWEs**: CWE-89 (SQL Injection)
- **Why good acceptance**: Classic vulnerability, well-understood impact
- **Common rejection reasons**:
  - ORM uses parameterized queries by default
  - String concatenation is in a test file, not production code
  - The "raw query" function is intentionally raw (documented)
- **Tips to maximize acceptance**:
  - Focus on ORMs with `.raw()`, `.query()`, or similar escape hatches
  - JSON path injection in ORMs is underexplored (e.g., JSON column access with user input)
  - Custom quote-escaping functions are often bypassable

### SSTI (Server-Side Template Injection)
- **Acceptance rate**: ~75%
- **Typical severity**: HIGH 8.1 to CRITICAL 9.8
- **CWEs**: CWE-1336 (Template Injection)
- **Why good acceptance**: RCE through template engine is well-understood
- **Common rejection reasons**:
  - User input goes into template **variables**, not the template **string** itself
  - Template engine has sandboxing that prevents accessing dangerous objects
- **Tips to maximize acceptance**:
  - Must prove user input becomes part of the **template source**, not just data passed to the template
  - Check compile() or render() where the first argument comes from user input
  - Template engines that expose imports or require in their sandbox context are vulnerable

### SSRF (Server-Side Request Forgery)
- **Acceptance rate**: ~75%
- **Typical severity**: HIGH 7.5 to CRITICAL 9.8
- **CWEs**: CWE-918 (Server-Side Request Forgery)
- **Why good acceptance**: Cloud metadata access is high impact
- **Common rejection reasons**:
  - Library validates/blocks private IP ranges
  - DNS rebinding protection is in place
  - The URL parameter is only settable by admins
- **Tips to maximize acceptance**:
  - IPv6-mapped addresses can bypass IPv4 blocklists
  - DNS rebinding: domain that resolves to internal IP
  - URL parser differentials between validation and request libraries
  - Always test the actual blocking library version — many bypass lists are patched

### Auth Bypass
- **Acceptance rate**: ~70%
- **Typical severity**: HIGH 7.5 to CRITICAL 9.8
- **CWEs**: CWE-862 (Missing Authorization), CWE-306 (Missing Authentication)
- **Why good acceptance**: Access control failures are clear security issues
- **Common rejection reasons**:
  - Requires authenticated session that already grants the same access
  - The endpoint is intentionally public
  - Route ordering issue that only affects non-standard configurations
- **Tips to maximize acceptance**:
  - Missing auth on admin endpoints is almost always accepted
  - JWT algorithm confusion (RS256 -> HS256) is underexplored
  - Check for IDOR alongside auth bypass — combining them strengthens the report

### Stored XSS
- **Acceptance rate**: ~70%
- **Typical severity**: MEDIUM 6.1 to HIGH 7.5
- **CWEs**: CWE-79 (Cross-site Scripting)
- **Why decent acceptance**: Concrete user impact, well-understood
- **Common rejection reasons**:
  - Framework auto-escapes output (React, Angular, Vue)
  - Content Security Policy prevents script execution
  - Browser XSS filter blocks the payload
- **Tips to maximize acceptance**:
  - Target contexts where auto-escaping doesn't apply: `href`, `src`, `style`, event handler attributes
  - Markdown renderers that allow raw HTML are good targets
  - SVG upload -> stored XSS is often missed

---

## Tier 3: Moderate Acceptance (~50-65%)

### Recursion / Stack Overflow DoS
- **Acceptance rate**: ~65%
- **Typical severity**: HIGH 7.5
- **CWEs**: CWE-674 (Uncontrolled Recursion)
- **Why moderate acceptance**: Impact depends on crash severity
- **Common rejection reasons**:
  - RangeError is catchable — not a real crash
  - "DoS requires malicious input, which is an operational concern, not security"
  - Library is not expected to handle adversarial input
- **Tips to maximize acceptance**:
  - OOM crash (process dies) > RangeError (catchable exception)
  - Show that the input is small (< 1 KB) but causes unbounded resource consumption
  - Demonstrate in a server context where the crash affects other users
  - If it's only RangeError, show that callers don't catch it and the server crashes

### Decompression Bomb
- **Acceptance rate**: ~65%
- **Typical severity**: HIGH 7.5
- **CWEs**: CWE-409 (Improper Handling of Highly Compressed Data)
- **Why moderate acceptance**: Requires demonstrating meaningful amplification
- **Common rejection reasons**:
  - Amplification ratio is too low (< 100x)
  - Library has built-in size limits
  - "Just set a size limit in your application code"
- **Tips to maximize acceptance**:
  - Show extreme ratios: 10 KB -> 1 GB or higher
  - ZIP bombs with overlapping entries (nested or flat)
  - GZIP bombs are simpler and often unprotected
  - Always measure actual memory consumption, not theoretical expansion

### ReDoS (Regular Expression Denial of Service)
- **Acceptance rate**: ~55%
- **Typical severity**: HIGH 7.5
- **CWEs**: CWE-1333 (Inefficient Regular Expression Complexity)
- **Why lower acceptance**: Many claims don't demonstrate actual exponential backtracking
- **Common rejection reasons**:
  - Regex has polynomial (not exponential) complexity — slow but bounded
  - Actual backtracking measurement shows linear or quadratic growth, not exponential
  - Input length required for meaningful delay is unrealistic (> 1 MB)
  - Library uses RE2 or Rust regex engine (linear-time by design)
- **Tips to maximize acceptance**:
  - ALWAYS measure actual execution time at multiple input lengths and plot the growth curve
  - Show: 20 chars = 0.1s, 25 chars = 3s, 30 chars = 100s (exponential)
  - Identify the specific regex pattern causing backtracking (nested quantifiers, alternation)
  - Incomplete patches of prior ReDoS CVEs have higher acceptance

### Prototype Pollution / Method Clobbering
- **Acceptance rate**: ~50%
- **Typical severity**: HIGH 7.3 to HIGH 7.5
- **CWEs**: CWE-1321 (Prototype Pollution), CWE-915 (Improperly Controlled Modification)
- **Why lower acceptance**: "JSON.parse does the same thing" is a common maintainer response
- **Common rejection reasons**:
  - JSON.parse also creates `__proto__` keys — so what's different?
  - `Object.create(null)` is used for user-keyed objects
  - No demonstrated security impact beyond theoretical pollution
  - The polluted property is never read by any code path
- **Tips to maximize acceptance**:
  - Must show REAL impact: crash (TypeError on clobbered method), security bypass, or gadget chain
  - Method clobbering (overwriting `.toString`, `.valueOf`, `.hasOwnProperty`) causing TypeError crash is stronger than `__proto__` pollution
  - For security-adjacent parsers (form data, authentication, configuration), clobbering impact is more credible
  - Find a gadget: show that polluted property is read by a downstream library to change behavior
  - CWE-915 (method clobbering) is better received than CWE-1321 (proto pollution) by many maintainers

---

## Key Insights

1. **Impact clarity wins**: The easier it is to understand "this is bad", the higher the acceptance rate
2. **RCE > DoS > Info Disclosure**: Always try to escalate findings to the highest impact class
3. **Bypass variants of known CVEs**: ~95% acceptance rate — the highest of any category
4. **Default configuration only**: Findings that require non-default config are frequently rejected
5. **Version matters enormously**: Always test the latest released version, not a development branch
6. **Small PoC, big impact**: A 10-line PoC that crashes a server is more compelling than a 200-line theoretical exploit
7. **Advisory mining**: Searching for incomplete fixes of existing CVEs yields the best ROI
