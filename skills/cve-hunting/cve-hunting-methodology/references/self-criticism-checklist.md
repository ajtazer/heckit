# 7-Point Pre-Submission Self-Check

Run this checklist BEFORE every submission. Each item has killed at least one real
submission. Skip none.

This is a security research knowledge base document for educational purposes.

---

## The Checklist

### 1. Read the README and Documentation

**What to check**: Does the library explicitly warn about untrusted input?

**Search the docs for**:
- "untrusted"
- "security"
- "warning"
- "caution"
- "note"
- "sanitize"
- "validate"
- "do not use"

**Red flags that your finding may be "by design"**:
- README says: "This library is not intended for use with untrusted input"
- Function is documented as "raw", "unsafe", or "dangerous"
- There's a separate "safe" variant of the same function
- The docs explicitly describe the behavior you're about to report
- There's a configuration option to enable/disable the behavior

**Example scenario**: Submitted a code injection report against an expression evaluator. The README's second paragraph said "paths are not intended for untrusted input." Maintainer rejected immediately. Cost: 3 hours of wasted work.

**Decision**: If the README clearly warns about untrusted input, this is likely "by design." Consider whether downstream users are affected despite the warning before proceeding.

---

### 2. Is This Documented or Intended Behavior?

**What to check**: Is the behavior you found a feature, not a bug?

**How to verify**:
- Read the API documentation for the specific function
- Check if there are tests that explicitly test for this behavior
- Search GitHub Issues for the behavior — has anyone requested it as a feature?
- Check CHANGELOG — was this behavior intentionally added?

**Common "features" mistaken for vulnerabilities**:
- `$where` operator in MongoDB-compatible libraries (intentional query capability)
- Template helpers that access system objects (documented template features)
- Configuration options that enable shell execution (intentional for build tools)
- Image processing parameters with extreme ranges (clamped internally)

**Example scenario**: Reported a query operator that evaluates expressions as code injection. The operator was a documented MongoDB compatibility feature. The author had even added a safety flag showing awareness of the implications.

**Decision**: If the behavior is documented and intentionally implemented, it's not a vulnerability. Move on.

---

### 3. Does the Library Already Handle This Gracefully?

**What to check**: Does the error you trigger actually crash the process, or is it caught and handled?

**How to verify**:
- Read the error handling code around the vulnerable function
- Check if there's a try/catch wrapping the operation
- Test: does the process crash (exit code non-zero, signal 9/11) or does it return an error?
- Check if the error is a catchable exception (RangeError, TypeError) or an uncatchable crash (OOM, segfault)

**Impact hierarchy**:
1. **OOM / Segfault**: Process crashes. Signal 9 (SIGKILL) or 11 (SIGSEGV). Highest impact. Always accepted.
2. **Uncaught exception**: Process crashes because the error propagates to top level. High impact.
3. **Caught exception**: Library catches the error and returns it to the caller. Lower impact.
4. **Graceful degradation**: Library detects the issue and returns a safe default. Not a vulnerability.

**Example scenario**: Reported recursion DoS causing RangeError. The calling application caught RangeError and returned a 400 error. No crash. Maintainer: "This is handled gracefully."

**Decision**: If the error is caught and handled, the impact may be too low for a CVE. Verify actual process crash.

---

### 4. Is This Alpha, Beta, or Pre-release Software?

**What to check**: Is the software in a pre-release state?

**How to verify**:
- Check `package.json` version: does it contain `-alpha`, `-beta`, `-rc`, `-next`?
- Check PyPI: is it marked as a pre-release?
- Check the README: does it say "experimental", "work in progress", "not ready for production"?
- Check npm: `npm info <package> dist-tags` — is `latest` different from the version you tested?

**Why this matters**:
- Maintainers rarely issue CVEs for pre-release software
- The code may change significantly before stable release
- The vulnerability may be known and on their roadmap to fix
- Security researchers lose credibility reporting pre-release issues

**Example scenario**: Found code injection in a schema validator's v7 alpha. Maintainer acknowledged the bug but said: "This is alpha software. We appreciate the report but won't issue a CVE. We'll fix it before stable release."

**Decision**: If pre-release, note the finding and re-check after stable release. Do not submit.

---

### 5. How Many Recent CVEs Does This Package Have?

**What to check**: Is this package already heavily audited by other researchers?

**How to verify**:
- Search NVD: `https://nvd.nist.gov/vuln/search` with the package name
- Search GHSA: `https://github.com/advisories?query=<package>`
- Check the Security tab on the GitHub repository
- Count CVEs from the past 12 months

**Risk levels**:
- **0-2 prior CVEs**: Good target. Under-audited.
- **3-5 prior CVEs**: Moderate. Other researchers are looking. Move fast.
- **6-10 prior CVEs**: High competition. Your finding may already be reported privately.
- **10+ prior CVEs**: Very high competition. Unless you have a novel vector, consider a different target.

**Why this matters**:
- More prior CVEs = more researchers watching = higher duplicate risk
- Fix branches may already be in progress for the exact issue you found
- The maintainer may have "CVE fatigue" and be less responsive
- Your finding may be a variant of something already reported privately

**Decision**: If >10 recent CVEs, verify your finding is truly novel before investing time in a full report.

---

### 6. For Clobbering/Pollution Claims: Can You Show REAL Impact?

**What to check**: Does setting `__proto__` or overwriting methods via your vulnerability cause a REAL crash or security impact?

**The "JSON.parse defense"**:
`JSON.parse('{"__proto__": {"x": 1}}')` creates a plain object with a `__proto__` key. It does NOT pollute `Object.prototype`. Many parsers behave identically to JSON.parse.

**To demonstrate real impact, you must show one of**:
1. **Real prototype pollution**: `({}).polluted === true` after parsing malicious input (proves Object.prototype was modified)
2. **Method clobbering crash**: Setting `toString` or `valueOf` as a non-function causes TypeError when the object is later used in string concatenation or comparison
3. **Security bypass**: A polluted property changes the behavior of authentication, authorization, or sanitization code
4. **Gadget chain**: The polluted property is read by downstream code that performs a dangerous operation

**Test this BEFORE submitting**:
```
// After parsing malicious input:
const result = parse(malicious_input);

// Test 1: Is this real pollution?
console.log(({}).polluted);  // undefined = NOT real pollution

// Test 2: Does method clobbering cause a crash?
try {
  String(result);  // TypeError if toString was clobbered
  JSON.stringify(result);  // TypeError if toJSON was clobbered
} catch (e) {
  console.log("CRASH:", e.message);  // This is real impact
}
```

**Example scenario**: Submitted proto pollution for a utility library. Maintainer responded: "JSON.parse does the same thing. We match JSON semantics by design."

**Decision**: If you can only set `__proto__` as a property key (not modify the actual prototype chain), and can't demonstrate a crash or security bypass, this is probably not CVE-worthy.

---

### 7. For Recursion/DoS Claims: OOM or Just RangeError?

**What to check**: Does the recursive input cause a process-killing OOM, or just a catchable RangeError?

**How to distinguish**:

| Outcome | How to Detect | CVE-worthiness |
|---------|--------------|----------------|
| OOM (SIGKILL) | Process exit code 137 (128 + 9), `Killed` in output | HIGH - almost always accepted |
| Segfault (SIGSEGV) | Process exit code 139 (128 + 11) | HIGH - almost always accepted |
| Uncaught RangeError | Stack trace with "Maximum call stack size exceeded", process exits | MEDIUM - accepted if shows server crash |
| Caught RangeError | Error returned to caller, process continues | LOW - rarely accepted |
| Slow performance | No crash, just takes a long time | VERY LOW - rarely accepted as security |

**Test methodology**:
```
# Run with memory limit to detect OOM quickly
node --max-old-space-size=512 poc.js

# Check exit code
echo $?
# 137 = OOM (SIGKILL), 139 = SIGSEGV, 1 = uncaught exception, 0 = graceful

# Monitor memory during execution
# On macOS:
top -pid $(pgrep -f poc.js) -l 1
# On Linux:
/usr/bin/time -v node poc.js 2>&1 | grep "Maximum resident"
```

**Example scenario**: Reported recursion DoS claiming "process crash." The actual behavior was a RangeError caught by the framework, returning a 500 error. The server continued running. Maintainer: "This is not a DoS — the server handles the error."

**Decision**: If it's only a caught RangeError with no process crash, this is probably not CVE-worthy. Escalate by showing OOM, uncaught exception in a server context, or chain with another vulnerability.

---

## Quick Reference Card

Before clicking "Submit", answer all 7:

| # | Question | Bad Answer | Good Answer |
|---|----------|-----------|-------------|
| 1 | Does README warn about untrusted input? | "I didn't check" | "No warning found" |
| 2 | Is this documented behavior? | "Maybe, I didn't read the docs" | "Not documented, undocumented side effect" |
| 3 | Is the error handled gracefully? | "It throws an error" | "Process crashes with SIGKILL" |
| 4 | Is this pre-release? | "I think so" | "v3.2.1 stable, latest on npm" |
| 5 | How many recent CVEs? | "Lots" | "2 CVEs in 2024, none matching my finding" |
| 6 | Real crash from clobbering? | "I can set __proto__" | "TypeError crash in string coercion" |
| 7 | OOM or RangeError? | "Stack overflow" | "OOM at 2GB, exit code 137" |

If ANY answer is in the "Bad Answer" column, investigate further before submitting.

---

## The Meta-Question

After all 7 checks pass, ask yourself:

> "If I were the maintainer receiving this report, would I think this is a legitimate security issue worth fixing urgently? Or would I think the reporter doesn't understand my library?"

If the answer is the latter, reconsider.
