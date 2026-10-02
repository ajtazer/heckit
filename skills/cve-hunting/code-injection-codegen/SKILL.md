---
name: code-injection-codegen
description: "Detect code injection vulnerabilities in packages that dynamically generate or evaluate code via new Function(), eval(), vm.run*, or template literal interpolation."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.mjs"
  bashPattern:
    - "semgrep.*codegen"
    - "grep.*(eval|Function|vm\\.run)"
  priority: 95
---

# Code Injection via Code Generation

## When to Use

Audit any package that dynamically generates or evaluates code — schema validators, template engines, expression evaluators, serializers with code generation, JIT compilers, query builders that emit JavaScript.

This is the highest-yield vulnerability class for CVE hunting. ~90% acceptance rate when confirmed.

## Key Insight

Code generation packages often interpolate user-controlled values directly into generated code strings. Unlike template injection (where user input goes INTO a template), here user input becomes PART of the generated code itself.

## Process

### Step 1: Find Code Evaluation Sinks

Search for all dynamic code execution:

```
# JavaScript/TypeScript
grep -rn "new Function\(" .
grep -rn "eval(" .
grep -rn "vm\.run" .
grep -rn "vm\.compileFunction" .
grep -rn "setTimeout(" . | grep -v "setTimeout(function"
grep -rn "setInterval(" . | grep -v "setInterval(function"
grep -rn "new AsyncFunction" .
grep -rn "script\.runIn" .

# Python
grep -rn "eval(" .
grep -rn "exec(" .
grep -rn "compile(" . | grep -v "re.compile"

# Ruby
grep -rn "\.eval\b" .
grep -rn "instance_eval" .
grep -rn "class_eval" .

# PHP
grep -rn "eval(" .
grep -rn "assert(" .
grep -rn "create_function" .
grep -rn "preg_replace.*\/e" .
```

### Step 2: Trace Data Flow to Sink

For each sink found:

1. Identify what string is being evaluated
2. Trace backwards — is any part of that string derived from user input?
3. Check for template literals: `` new Function(`return ${userInput}`) ``
4. Check for string concatenation: `new Function("return " + userInput)`
5. Check for variable interpolation in generated code

### Step 3: Check for Block Comment Escape

JSON.stringify does NOT escape `*/`. If generated code wraps values in block comments:

```js
// VULNERABLE PATTERN:
let code = `/* ${JSON.stringify(userValue)} */ actual_code_here`;
// Attacker input: */ malicious_code /*
// Result: /* */ malicious_code /* */ actual_code_here
```

Search for this pattern:
```
grep -rn "\/\*.*JSON\.stringify" .
grep -rn "\/\*.*\$\{" .
```

### Step 4: Check for Incomplete Escaping

Common mistakes:
- Escaping single quotes but not backticks (template literals)
- Escaping backslash but not newlines (line injection)
- Using JSON.stringify but not escaping `</script>` in HTML context
- Escaping in the value but not in the key (object property names)

### Step 5: Verify Exploitability

1. Can the attacker control the interpolated value?
2. Does the generated code get executed (not just constructed)?
3. What is the execution context? (Node.js process = RCE, browser = XSS)
4. Is there any sandboxing? (node:vm is NOT security — see sandbox-escape skill)

## Vulnerable Patterns

### Pattern 1: Template Literal in new Function()
```js
// Schema validator generating validation function
function createValidator(schema) {
  const code = `return function(value) {
    if (typeof value !== "${schema.type}") throw new Error("invalid");
  }`;
  return new Function(code)();
}
// Exploit: schema.type = '"; }); process.mainModule.require("child_process").execSync("id"); //'
```

### Pattern 2: String Concatenation in eval()
```js
// Expression evaluator
function evaluate(expr) {
  return eval("(" + expr + ")");
}
```

### Pattern 3: Code Generation with Object Keys
```js
// Serializer generating accessor code
function createGetter(path) {
  return new Function("obj", `return obj.${path}`);
}
// Exploit: path = "x; process.mainModule.require('child_process').execSync('id'); //"
```

### Pattern 4: Block Comment Escape
```js
// Code generator with "safe" comments
function generateModule(config) {
  return `
    /* Config: ${JSON.stringify(config.name)} */
    module.exports = { value: ${JSON.stringify(config.value)} };
  `;
}
// Exploit: config.name = "*/ require('child_process').execSync('id'); /*"
```

### Pattern 5: sourceURL Injection
```js
// Debug source mapping
const code = `${generatedCode}\n//# sourceURL=${filename}`;
new Function(code)();
// Exploit: filename contains newline + malicious code
```

## CVSS Guidance

- Server-side code execution (Node.js): CRITICAL 9.8 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
- With authentication required: HIGH 8.8 (PR:L)
- Client-side only (browser): HIGH 7.5 (XSS equivalent)
- Requires specific configuration: reduce AC to H

## References

- [Sinks](references/sinks.md) — Code execution sinks by language
- [False Positive Indicators](references/false-positive-indicators.md) — When this isn't a real bug
- [PoC Skeleton](references/poc-skeleton.md) — Proof of concept template
