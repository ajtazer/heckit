# False Positive Indicators — Code Injection

## When Code Injection is NOT a Real Bug

### 1. Input is From Trusted Source

The evaluated string comes from:
- Hardcoded constants or configuration files read at startup
- Compile-time generated code (build step output)
- Internal function calls with no external input path
- Database records set exclusively by admin users with full system access

**How to verify**: Trace the data flow backwards from the eval sink. If no path exists from HTTP request / CLI argument / file upload / user-controlled data to the eval'd string, it's not exploitable.

### 2. Sandboxed Execution

The code runs in a genuine security sandbox:
- `isolated-vm` — separate V8 isolate with no host object access
- WebAssembly — cannot access host memory or functions
- OS-level sandbox (seccomp, AppArmor, Docker with no host mount)
- Browser `<iframe sandbox>` with restricted permissions

**NOT a sandbox** (still vulnerable):
- `node:vm` — the Node.js docs explicitly state this is NOT for security
- `vm2` — deprecated due to multiple sandbox escapes (check version carefully)
- `with` statement scope restriction — trivially bypassable
- `"use strict"` mode — prevents some patterns but not code execution

### 3. Documented as Unsafe

The package README or API documentation explicitly warns:
- "Do not pass untrusted input to this function"
- "This function evaluates code — only use with trusted data"
- "Not designed for use with user-controlled input"

**Check self-criticism item 1**: Always read README/docs before reporting. If the package explicitly warns about untrusted input, CVE may be rejected. However, if the package is commonly used as a dependency where untrusted data flows through it indirectly, it may still be worth reporting.

### 4. Test-Only Code

The eval/Function call exists only in:
- Test files (`*.test.js`, `*.spec.js`, `__tests__/`)
- Development-only scripts (`scripts/dev.js`)
- Example/demo code (`examples/`, `demo/`)
- Benchmarking code (`bench/`, `benchmark/`)

**Caveat**: If test helpers are exported and used by consumers, they're still attack surface.

### 5. Input is Validated Against Strict Allowlist

The input undergoes validation that provably prevents injection:
- Regex that only allows alphanumeric characters: `/^[a-zA-Z0-9_]+$/`
- Enum/allowlist check: `if (!ALLOWED_TYPES.includes(input)) throw`
- Type coercion that strips dangerous characters: `Number(input)`, `parseInt(input)`

**NOT sufficient validation** (still vulnerable):
- Blocklist of dangerous characters (attackers find bypass)
- JSON.stringify alone (doesn't escape `*/`, `</script>`)
- HTML entity encoding (doesn't prevent JS execution in eval context)
- URL encoding/decoding (may introduce dangerous characters)

### 6. Generated Code is Never Executed

The code string is constructed but:
- Only used for display/debugging (logged, printed to console)
- Written to a file that is never loaded/required
- Returned to the user as source code (not evaluated server-side)

### 7. Alpha/Beta Package

- Package is in alpha/beta stage (pre-1.0)
- Very few weekly downloads (<1000)
- Maintainer may not issue CVE for pre-release software

**Note**: This doesn't make it a false positive — the vulnerability is real — but it affects submission strategy. Consider whether it's worth the effort.
