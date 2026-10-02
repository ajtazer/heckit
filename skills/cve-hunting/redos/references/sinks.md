# ReDoS Sinks -- Regex-Heavy Libraries and Known Patterns

## Validation Libraries (Highest Risk)

| Library | Language | Risk Level | Notes |
|---------|----------|------------|-------|
| `validator.js` | JS | HIGH | Email, URL, IP validators use complex regex |
| `joi` | JS | MEDIUM | Custom regex in `.pattern()` |
| `yup` | JS | MEDIUM | `.matches()` with user patterns |
| `zod` | JS | LOW | Mostly uses built-in JS checks, less regex |
| `ajv` | JS | MEDIUM | `pattern` keyword in JSON Schema |
| `express-validator` | JS | HIGH | Wraps validator.js |
| `Django validators` | Python | MEDIUM | URLValidator, EmailValidator use regex |
| `WTForms` | Python | MEDIUM | Custom validators may use regex |
| `Cerberus` | Python | MEDIUM | `regex` rule type |

## Parsing Libraries (High Risk)

| Library | Language | Risk Level | Notes |
|---------|----------|------------|-------|
| `marked` | JS | MEDIUM | Markdown link/emphasis regex |
| `markdown-it` | JS | LOW | Mostly safe, well-audited |
| `highlight.js` | JS | HIGH | Language-specific regex patterns |
| `prismjs` | JS | HIGH | Language grammar regex |
| `chrono-node` | JS | HIGH | Date parsing with many regex patterns |
| `postcss` | JS | MEDIUM | CSS selector parsing |
| `css-what` | JS | MEDIUM | CSS selector regex |
| `semver` | JS | MEDIUM | Version string parsing |
| `glob` / `minimatch` | JS | MEDIUM | Glob-to-regex conversion |
| `picomatch` | JS | MEDIUM | Glob matching engine |
| `path-to-regexp` | JS | HIGH | Express route pattern matching (CVE history) |

## URL/Email Parsing

| Library | Language | Risk Level | Notes |
|---------|----------|------------|-------|
| `normalize-url` | JS | MEDIUM | URL normalization regex |
| `is-email` | JS | HIGH | Email validation regex |
| `url-regex` | JS | HIGH | Known ReDoS history |
| `ip-regex` | JS | MEDIUM | IP address matching |
| `email-validator` | Python | MEDIUM | Email regex patterns |

## Known Vulnerable Patterns from Real CVEs

| CVE | Package | Pattern Description | Fix |
|-----|---------|-------------------|-----|
| CVE-2018-16487 | lodash | `trimEnd` nested quantifier | Replaced regex |
| CVE-2021-27292 | ua-parser-js | User-Agent parsing regex | Simplified patterns |
| CVE-2020-7660 | serialize-javascript | Regex in serialization | Removed regex |
| CVE-2022-25883 | semver | Version range parsing | Bounded input |
| CVE-2024-4068 | braces | Expansion parsing | Added depth limit |
| CVE-2022-3517 | minimatch | Glob pattern matching | Input sanitization |
| CVE-2021-21317 | uap-core | UA string regex | Anchored patterns |

## Safe Alternatives

| Instead of | Use | Why |
|-----------|-----|-----|
| Custom email regex | `validator.js isEmail()` (post-fix) | Well-tested |
| Custom URL regex | `new URL()` (built-in) | Parser, not regex |
| `path-to-regexp` (old) | `path-to-regexp` v8+ | Fixed ReDoS |
| PCRE in Go | Go `regexp` (stdlib) | RE2, linear time |
| `re` module (Python) | `google-re2` | Linear time guarantee |
| Complex regex validation | State machine parser | No backtracking |

## User-Controlled Regex (Always Critical)

Any code that passes user input to regex construction:

```js
// ALWAYS VULNERABLE -- user controls the pattern
new RegExp(req.query.pattern)
new RegExp(req.body.search)
string.match(new RegExp(userInput))
string.replace(new RegExp(userInput), replacement)
```

```python
# ALWAYS VULNERABLE
re.compile(user_input)
re.search(user_input, target_string)
```

Even a simple `.*` with user-controlled quantifiers can be made exponential. If user input reaches `RegExp()` or `re.compile()`, it is ReDoS regardless of the pattern.
