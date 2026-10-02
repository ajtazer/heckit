# Known-Clean Code Patterns — Skip These

Patterns that look dangerous but are actually safe in practice. Recognizing these
saves hours of investigation time. Skip during review unless you spot an edge case.

This is a security research knowledge base document for educational purposes.
Code examples below illustrate safe patterns and their edge cases.

---

## 1. Parameterized SQL Queries (ORM Bound Parameters)

### What it looks like
```python
# Python — parameterized query (safe)
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# Node.js — parameterized query (safe)
db.query("SELECT * FROM users WHERE id = $1", [userId]);
```

### Why it's safe
The database driver sends the query structure and parameters separately. The parameter
is never interpolated into the SQL string — it's bound at the protocol level. SQL injection
is impossible because the parameter cannot change the query structure.

### What to check anyway
- **String concatenation BEFORE parameterization**: if the table name is dynamically inserted via concatenation, it's still injectable
- **ORM raw query methods**: `.raw()`, `.query()`, `.execute()` may bypass parameterization
- **Dynamic column/table names**: These can't be parameterized and must be validated separately
- **LIKE patterns**: parameterized LIKE is safe from SQL injection, but may cause performance issues (not a security vuln)

### When it CAN be vulnerable
- When the query string itself is dynamically constructed from user input
- When using stored procedures that internally concatenate strings
- When the ORM has a documented bypass mode

---

## 2. Process Spawning with Array Arguments

### What it looks like
```javascript
// Node.js — array arguments (safe)
const { execFile } = require('child_process');
execFile('git', ['log', '--oneline', '-n', userInput]);
```
```python
# Python — list arguments without shell (safe)
import subprocess
subprocess.run(['git', 'log', '--oneline', '-n', user_input])
```

### Why it's safe
When arguments are passed as an array/list, each element becomes a separate argument to the
program. Shell metacharacters are NOT interpreted because the shell is not involved — the
program is executed directly via the operating system's exec syscall.

### What to check anyway
- **`shell=True` in Python**: re-enables shell interpretation even with list args
- **`shell: true` in Node.js options**: re-enables shell interpretation
- **Argument injection**: Even without shell injection, some programs interpret arguments dangerously. Git with `--upload-pack` or `--config` options can lead to code execution. Curl with `-o` can write files.
- **Concatenation before array**: If arguments are concatenated before being put in the array, the protection is bypassed

### When it CAN be vulnerable
- When `shell: true` or `shell=True` is passed as an option
- When the program itself interprets arguments as commands (e.g., `find -exec`, `git --config`)
- When arguments are joined into a string before being split back into an array

---

## 3. YAML Safe Loading

### What it looks like
```python
import yaml
data = yaml.safe_load(user_input)
```

### Why it's safe
`yaml.safe_load()` only constructs basic Python types (str, int, float, list, dict, bool, None).
It does NOT construct arbitrary Python objects, preventing deserialization attacks.

### What to check anyway
- **`yaml.load()` without SafeLoader**: The unsafe variant
- **`yaml.unsafe_load()`**: Explicitly unsafe
- **Custom constructors**: If the code registers custom YAML constructors, they may re-enable dangerous deserialization
- **Billion Laughs**: `yaml.safe_load()` may still be vulnerable to alias/anchor expansion bombs depending on the YAML library version

### When it CAN be vulnerable
- Go YAML libraries may not have a "safe" mode and may expand aliases without limits
- Custom YAML tags registered via `add_constructor()` bypass safe loading
- Anchor/alias expansion can still cause DoS even in safe mode

---

## 4. JSON.parse

### What it looks like
```javascript
const data = JSON.parse(userInput);
```

### Why it's safe
`JSON.parse` creates plain JavaScript objects. It does NOT:
- Execute code
- Access the prototype chain (despite `__proto__` keys appearing in output)
- Cause prototype pollution (the `__proto__` key becomes a regular own property, not a prototype link)
- Trigger getters/setters

### What to check anyway
- **What happens AFTER parsing**: If the parsed object is merged into another object via deep merge, `__proto__` keys can cause pollution
- **Large inputs**: JSON.parse can consume significant memory for very large inputs, but this is operational, not security

### When it CAN be vulnerable
- The vulnerability is never in JSON.parse itself — it's in what the application does with the parsed result
- Deep merge of parsed objects can cause prototype pollution
- If the parsed object's properties are used to construct shell commands, SQL queries, or file paths

---

## 5. Template Literals for Display with Auto-Escaping

### What it looks like
```jsx
// React — auto-escaped (safe)
return <div>{userInput}</div>;
```
```html
<!-- Vue — auto-escaped (safe) -->
<template><p>{{ userInput }}</p></template>
```

### Why it's safe
Modern frontend frameworks (React, Vue, Angular) auto-escape template interpolations.
Script tags in user input are rendered as text, not executed as HTML. The framework
converts special characters to HTML entities.

### What to check anyway
- **Raw HTML rendering directives**: React's raw HTML prop, Vue's `v-html`, Angular's `[innerHTML]` with trust bypass
- **`href` attributes with user input**: allows `javascript:` protocol URLs in some frameworks
- **Server-side rendering (SSR)**: Template rendering on the server may not auto-escape
- **`style` attributes**: CSS injection via style attributes can exfiltrate data

### When it CAN be vulnerable
- When the framework's escape mechanism is explicitly bypassed
- When user input goes into URL contexts (`href`, `src`, `action`)
- When rendering happens server-side without a framework
- When user input controls attribute names (not just values)

---

## 6. path.resolve() Before Access Check

### What it looks like
```javascript
const safePath = path.resolve(baseDir, userInput);
if (!safePath.startsWith(baseDir)) {
  throw new Error('Access denied');
}
fs.readFile(safePath, callback);
```

### Why it's safe
`path.resolve()` normalizes the path, resolving `..` components. After resolution,
`../../etc/passwd` becomes an absolute path that fails the `startsWith(baseDir)` check.

### What to check anyway
- **`path.join()` alone without the check**: `path.join()` does NOT prevent traversal on its own
- **Symlinks**: `path.resolve()` does NOT follow symlinks. If the resolved path passes the check but contains a symlink pointing outside the base, the file read escapes. Use `fs.realpath()` for symlink-aware resolution.
- **Unicode/encoding issues**: Null bytes, URL encoding, double encoding may bypass the check
- **Case sensitivity**: On case-insensitive filesystems (macOS, Windows), different cases of the same path may bypass startsWith
- **Trailing slash**: `baseDir` should end with `/` to prevent prefix matching like `/base-other/`

### When it CAN be vulnerable
- No `startsWith` check after `path.resolve()`
- Symlink traversal after the path check
- Case-sensitivity mismatch on macOS/Windows
- Base directory without trailing separator

---

## 7. Object.create(null) for User-Keyed Objects

### What it looks like
```javascript
const store = Object.create(null);
store[userKey] = userValue;
```

### Why it's safe
`Object.create(null)` creates an object with NO prototype chain. There's no
`__proto__`, no `toString`, no `constructor`. Setting `store['__proto__']` or
`store['constructor']` just creates regular properties — no prototype pollution.

### What to check anyway
- **Regular object literals used elsewhere**: If SOME objects use `Object.create(null)` but others use `{}`, the regular objects are still vulnerable
- **Spreading into regular objects**: `const result = {...store}` copies properties into a regular object, potentially including `__proto__`
- **Method calls on the null-prototype object**: `store.hasOwnProperty(key)` will throw TypeError because the method doesn't exist

### When it CAN be vulnerable
- Only when the null-prototype object's properties are later merged into a regular object

---

## 8. RE2 / Rust Regex (Linear-Time Matching)

### What it looks like
```javascript
const RE2 = require('re2');
const pattern = new RE2(userPattern);
```

### Why it's safe
RE2 and Rust's regex engine guarantee linear-time matching. They achieve this by
not supporting features that cause catastrophic backtracking: backreferences,
lookahead, lookbehind (in most cases). ReDoS is impossible.

### What to check anyway
- **Fallback to native regex**: Some libraries use RE2 for some patterns and fall back to native regex for patterns with unsupported features
- **Compilation DoS**: Creating a very complex RE2 pattern can be slow during compilation (not matching)
- **Memory**: Very large regex patterns can consume significant memory during compilation

### When it CAN be vulnerable
- When the library silently falls back to a backtracking engine for unsupported features
- When user input controls the regex PATTERN (not just the input string) — compilation may be slow

---

## 9. Cryptographically Secure Random Number Generation

### What it looks like
```javascript
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
```
```python
import secrets
token = secrets.token_hex(32)
```

### Why it's safe
These use the operating system's cryptographic random number generator (e.g., `/dev/urandom`).
The output is unpredictable — knowing previous outputs doesn't help predict future ones.

### What to check anyway
- **`Math.random()` used alongside**: If session tokens use crypto but other tokens use Math.random(), the latter are predictable
- **Insufficient entropy length**: `crypto.randomBytes(4)` is only 32 bits — brute-forceable
- **Seeded PRNGs**: Some libraries accept a seed for reproducibility. If the seed is predictable, the output is too
- **Token reuse**: Secure generation doesn't matter if the token is reused, stored in logs, or sent in URLs

### When it CAN be vulnerable
- When used with insufficient length (< 16 bytes for security tokens)
- When the token is exposed through a side channel (logs, URLs, error messages)

---

## 10. Strict Content Security Policy with Nonce

### What it looks like
```
Content-Security-Policy: default-src 'self'; script-src 'nonce-{random}'; style-src 'self'
```

### Why it's safe
A strict CSP with nonces prevents inline script execution. Even if XSS exists, the
attacker's injected script won't have the correct nonce and won't execute.

### What to check anyway
- **`unsafe-inline` in script-src**: Completely negates the protection
- **`unsafe-eval`**: Allows dynamic code execution which can bypass script-src restrictions
- **Base URI not restricted**: `<base>` tag can redirect relative URLs
- **Object/embed not restricted**: Plugins can bypass CSP
- **Nonce reuse**: If the nonce is the same on every page load, it can be predicted
- **CSP report-only mode**: Report-only header does NOT block, only reports

### When it CAN be vulnerable
- When `unsafe-inline` or `unsafe-eval` is present
- When the nonce is static (not regenerated per request)
- When CSS injection is possible (data exfiltration via CSS is not blocked by script-src)

---

## 11. HTTP-Only, Secure, SameSite Cookies

### What it looks like
```
Set-Cookie: session=abc123; HttpOnly; Secure; SameSite=Strict
```

### Why it's safe
- **HttpOnly**: JavaScript cannot access the cookie — XSS cannot steal session tokens
- **Secure**: Cookie only sent over HTTPS — no plain-text interception
- **SameSite=Strict**: Cookie not sent on cross-origin requests — CSRF is prevented

### What to check anyway
- **SameSite=Lax vs Strict**: Lax allows cookies on top-level navigations (GET requests), which may enable some CSRF via GET endpoints with side effects
- **Subdomain scope**: `Domain=.example.com` shares the cookie with all subdomains. XSS on any subdomain can access the session
- **Other cookies**: If the session cookie is HttpOnly but a CSRF token cookie is not, the CSRF token can be stolen via XSS
- **Cookie path restrictions**: `Path=/api` means the cookie is sent for `/api/*` requests but not for `/` — but this is easily bypassed with iframes

### When it CAN be vulnerable
- Subdomain XSS combined with `Domain=.example.com`
- GET endpoints with side effects combined with `SameSite=Lax`
- Other non-HttpOnly cookies containing sensitive data

---

## 12. Input Validation Libraries at the Boundary

### What it looks like
```javascript
const { body, validationResult } = require('express-validator');
app.post('/api/users',
  body('email').isEmail(),
  body('age').isInt({ min: 0, max: 150 }),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json(errors);
    // proceed with validated input
  }
);
```

### Why it's safe
Input validation at the boundary (route handler level) rejects malformed input before
it reaches any business logic. If the validation is correct, downstream code can trust
the input shape.

### What to check anyway
- **Missing validation on some endpoints**: One unvalidated endpoint is all it takes
- **Validation bypass via different content types**: JSON body is validated but URL query parameters are not
- **Incomplete validation**: Email format is validated but length is not (buffer overflow in downstream systems)
- **Validation vs. sanitization**: Validation rejects bad input. Sanitization modifies it. If the code sanitizes instead of rejecting, the modified input may still be dangerous

### When it CAN be vulnerable
- When validation is present on some routes but missing on others
- When the validated type is correct but the value range allows dangerous inputs
- When validation is applied to the wrong layer (client-side only)

---

## Summary Decision Table

| Pattern | Safe? | Check For |
|---------|-------|-----------|
| Parameterized SQL | YES | Dynamic table/column names, raw query methods |
| Array-arg process spawn | YES | shell: true option, argument injection in target program |
| yaml.safe_load | YES | Custom constructors, alias expansion bombs |
| JSON.parse | YES | What happens with the parsed result downstream |
| Framework auto-escape | YES | Raw HTML directives, href contexts |
| path.resolve + startsWith | YES | Symlinks, case sensitivity, trailing slash |
| Object.create(null) | YES | Spreading into regular objects |
| RE2 / Rust regex | YES | Fallback to native regex engine |
| Crypto random | YES | Insufficient length, token exposure |
| Strict CSP + nonce | YES | unsafe-inline, unsafe-eval, nonce reuse |
| HttpOnly + Secure + SameSite | YES | Subdomain scope, other non-HttpOnly cookies |
| Input validation at boundary | YES | Missing validation on other endpoints |

When reviewing a codebase, if you see these patterns used correctly, skip them and focus
your time on the code paths that DON'T have these protections.
