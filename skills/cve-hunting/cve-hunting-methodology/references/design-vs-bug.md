# Distinguishing Design Decisions from Security Bugs

**Not every dangerous capability is a vulnerability. Learn the difference.**

## The Core Question

> Would a reasonable developer using this library as documented be surprised by this behavior?

- **YES** → Likely a security bug
- **NO** → Likely by design

## Decision Framework

Ask these questions in order. Stop at the first definitive answer:

### 1. Does the README/docs describe this behavior?
- **Yes** → Almost certainly by design. Stop here unless the docs are clearly wrong.
- **No** → Continue to question 2.

### 2. Would a reasonable developer expect this behavior?
- A shell execution library is expected to execute shells
- A CSV parser is NOT expected to execute shells
- A template engine compiling user templates is expected (but compiling user DATA as templates is not)

### 3. Does triggering this require privileges that already grant equivalent access?
- Admin can already run arbitrary commands → command injection in admin panel is NOT a new vulnerability
- Low-privilege user can escalate → this IS a vulnerability
- **Key test**: Does the vulnerability give the attacker something they didn't already have?

### 4. Is the input source explicitly documented as "trusted only"?
- If the README says "do not use with untrusted input" → Gray area
- Check: do real users actually pass untrusted input? (Search GitHub for usage patterns)
- If the library is commonly used with untrusted input despite the warning → still worth reporting with the caveat

### 5. Does the tool explicitly warn against untrusted input?
- Some libraries have clear warnings about code execution with untrusted input
- If warning exists AND there's no reasonable untrusted use case → probably not a CVE
- If warning exists BUT the library is widely used with untrusted input → report it, but expect pushback

## Examples

### Design (NOT a vulnerability)
| Scenario | Why it's design |
|----------|-----------------|
| Code execution in a REPL tool | The tool is designed to run code |
| Shell injection in a task runner | Task runners execute shell commands by design |
| File read in an admin panel with admin auth | Admins already have system access |
| MongoDB `$where` operator in a MongoDB client | It's implementing the MongoDB spec |
| Template compilation in a template engine | That's what template engines do |

### Bug (IS a vulnerability)
| Scenario | Why it's a bug |
|----------|---------------|
| Shell injection via CSV column headers | CSV parsers should not execute commands |
| Path traversal in a file upload handler | Upload handlers should restrict paths |
| SQL injection in a query builder | Query builders should parameterize |
| XSS in a markdown renderer's output | Renderers should sanitize output |
| Code execution via JSON schema validation | Schema validators should not run code |

### Gray Area (requires judgment)
| Scenario | Consideration |
|----------|---------------|
| Prototype pollution in deep-merge utility | Is it used in security-sensitive contexts? |
| ReDoS in input validation library | Depends on where regexes are exposed |
| SSRF in URL fetching library | Does it document private IP filtering? |
| Template injection when user controls template string | Does the API distinguish template from data? |

## When in Doubt

1. **Search for real-world usage** — search GitHub code for how the library is actually used
2. **Check similar CVEs** — has this class of bug been assigned CVEs in similar libraries?
3. **Ask**: if I were a developer using this library, would this behavior alarm me?
4. **Report with context** — include the design consideration in your report, let the maintainer decide
