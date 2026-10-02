# False Positive Indicators -- Sandbox Escape

## When Sandbox Escape is NOT Exploitable

### 1. Uses Genuinely Isolated Sandbox

The code uses a REAL security sandbox:
- `isolated-vm` -- separate V8 isolate, no prototype chain access
- `quickjs-emscripten` -- separate engine in WebAssembly
- WebAssembly module -- cannot access host memory or APIs
- OS-level sandbox (seccomp, AppArmor, Docker with no host mount)

### 2. Sandbox Used for Non-Security Purpose

The package documentation explicitly states vm is NOT used for security:
- Used for module loading/compilation (like Node.js require internals)
- Used for context isolation in testing frameworks
- Used for server-side rendering where the code is trusted

### 3. Input is Trusted

Only admin/developer code runs in the sandbox:
- Plugin system restricted to admin users
- Code comes from package dependencies (trusted)
- Template compilation with developer-authored templates only

### 4. AST Allowlisting Before Execution

The code parses the input into an AST and validates against an allowlist before execution:
```js
const ast = acorn.parse(code);
// Walk AST, reject any node type not in allowlist
// Only then execute
```
This is much safer than regex-based filtering but check for completeness.

### 5. Python ast.literal_eval

`ast.literal_eval()` only evaluates Python literals. It cannot execute functions, access attributes, or import modules. It is SAFE by design.

### 6. vm2 with Specific Patches

vm2 >= 3.9.19 with all known escape patches applied. However, the library is DEPRECATED and no new patches will be released. Risk increases over time.

### 7. Read-Only Sandbox

The sandbox only evaluates expressions and returns values. No side effects possible. Even if the attacker can read `process.env`, no write access means limited impact (information disclosure vs RCE).
