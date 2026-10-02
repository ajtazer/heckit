---
name: cross-pollination
description: "Cross-pollination multiplier technique: find a vulnerability in one package, then search for the same pattern across all similar packages to multiply findings."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
  bashPattern:
    - "grep.app"
    - "grep -r"
    - "rg.*--glob"
  priority: 72
---

# Cross-Pollination -- Multiplying Findings

## When to Use

After confirming a vulnerability in package-A, use this technique to find the same vulnerable pattern in packages B through Z. One finding can multiply into 5-20 findings.

## The Multiplier Effect

| Starting Finding | Pattern | Typical Yield |
|-----------------|---------|--------------|
| Entity expansion in XML parser A | All XML parsers with no entity limit | 3-8 findings |
| Zip Slip in archive lib A | All archive extraction libs | 2-5 findings |
| Proto pollution in merge lib A | All deep merge/clone libs | 5-10 findings |
| ReDoS in validator A | All validators using same regex pattern | 3-7 findings |
| Code injection in schema validator A | All schema validators with code gen | 2-5 findings |
| Recursion DoS in serializer A | All recursive serializers | 5-15 findings |
| Method clobbering in parser A | All parsers creating objects from input | 3-8 findings |

## Process

### Step 1: Confirm the Original Finding

Before cross-pollinating, ensure the original finding is confirmed:
- PoC works
- fp-check passes
- Submitted or ready to submit

### Step 2: Extract the Vulnerable Pattern

Identify the core vulnerable code pattern as a regex:

```
# Example: recursive function without depth limit
Pattern: function\s+\w+\(.*\)\s*\{.*\w+\(  (self-call without depth check)

# Example: new Function with template literal
Pattern: new\s+Function\s*\(.*\$\{

# Example: path.join without startsWith check
Pattern: path\.join\(.*req\.(params|body|query)
```

### Step 3: Search via grep.app

```
https://grep.app/search?q=PATTERN&regexp=true&filter[lang][0]=JavaScript
```

Tips:
- Start with a specific pattern, then broaden if too few results
- Filter by language to reduce noise
- Look at file context, not just the matching line
- Skip node_modules, test files, documentation

### Step 4: Evaluate Each Match

For each match:
1. Is this a different package? (not a fork/copy of the original)
2. Does user input reach this code? (trace the data flow)
3. Is the pattern actually vulnerable in this context? (check for mitigations)
4. Does the package have enough usage to warrant a CVE? (check downloads)
5. Does a CVE already exist for this package? (check NVD)

### Step 5: Submit Findings

For each confirmed vulnerable package:
1. Apply fp-check
2. Build PoC adapted to this package
3. Submit via appropriate channel (GHSA, email, HackerOne)

## grep.app Usage

### URL Format
```
https://grep.app/search?q=QUERY&regexp=true&filter[lang][0]=LANGUAGE
```

### Parameters
- `q`: Search query (URL-encoded)
- `regexp`: true/false for regex mode
- `filter[lang][0]`: Language filter (JavaScript, Python, Go, Ruby, etc.)
- `page`: Pagination

### Useful Regex Patterns

```
# new Function with interpolation
new\s+Function\s*\(.*\$\{

# eval with concatenation
eval\s*\(.*\+

# Recursive function without depth
function\s+\w+.*\{[^}]*\1\(

# path.join with user input
path\.join\(.*req\.(params|body|query)

# XML parser without entity config
new\s+XMLParser\s*\(\s*\)

# Deep merge without proto check
function\s+\w*merge.*for.*in.*source.*\[key\]
```

## Local Cross-Repo Search

If you have multiple repos cloned locally:
```bash
# Search across all cloned repos
rg "PATTERN" targets/ --type js --glob '!node_modules'

# Count matches per repo
rg "PATTERN" targets/ --type js --glob '!node_modules' --count
```

## Scaling: Processing Many Matches

When grep.app returns 50+ matches:

1. **First pass**: Quick filter by download count (skip < 100K weekly)
2. **Second pass**: Check for existing CVEs (skip if already reported)
3. **Third pass**: Verify user input reaches the pattern
4. **Fourth pass**: Build PoC for confirmed cases
5. **Batch submit**: Submit findings in batches, not all at once

## References

- [Category Mapping](references/category-mapping.md) -- Package families by vuln class
- [grep.app Usage](references/grep-app-usage.md) -- Detailed search guide
