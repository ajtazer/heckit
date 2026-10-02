---
name: entity-expansion
description: "Detect XML/SVG/YAML entity expansion (Billion Laughs) vulnerabilities in parsers that allow unbounded entity definitions."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
    - "**/*.go"
    - "**/*.rb"
  bashPattern:
    - "semgrep.*xml"
    - "grep.*(parseXML|DOMParser|yaml\\.load)"
  priority: 93
---

# Entity Expansion (Billion Laughs) Detection

## When to Use

Audit any package that parses XML, SVG, HTML with entity support, or YAML with alias/anchor support. This includes:
- XML/SVG parsing libraries
- Document processors (DOCX, XLSX, RSS, Atom, SOAP)
- YAML parsers with alias expansion
- Configuration file parsers

~90% CVE acceptance rate when confirmed.

## Key Insight

Many parsers have NO default entity expansion limit. A 1KB XML payload with recursive entity definitions can expand to 1GB+ in memory, crashing the process with an OOM kill (uncatchable — process dies).

## Entity Expansion Types

### 1. Billion Laughs (Internal Entity Recursion)
```xml
<?xml version="1.0"?>
<!DOCTYPE lolz [
  <!ENTITY lol "lol">
  <!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
  <!ENTITY lol3 "&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;&lol2;">
  ...
  <!ENTITY lol9 "&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;&lol8;">
]>
<root>&lol9;</root>
```
Each level multiplies by 10. Level 9 = 10^9 = 1 billion "lol" strings.

### 2. Quadratic Blowup (Single Entity Repeated)
```xml
<!DOCTYPE foo [
  <!ENTITY a "AAAAAAAAAA..."> <!-- 50KB entity -->
]>
<root>&a;&a;&a;&a;&a;...&a;</root> <!-- 50000 references -->
```
Less dramatic but still effective — 50KB entity × 50000 refs = 2.5GB.

### 3. YAML Alias Expansion
```yaml
a: &anchor
  x: *anchor
  y: *anchor
```
Recursive alias references can cause exponential expansion in some YAML parsers.

## Process

### Step 1: Find XML/YAML Parsing

```
# JavaScript
grep -rn "xml2js\|fast-xml-parser\|xmldom\|sax\|DOMParser\|cheerio" .
grep -rn "\.parseString\|\.parse(" . --include="*.js" --include="*.ts"
grep -rn "yaml\.load\|yaml\.parse\|YAML\.parse" .

# Python
grep -rn "xml\.etree\|lxml\|minidom\|xml\.sax\|defusedxml" .
grep -rn "yaml\.load\|yaml\.safe_load\|yaml\.unsafe_load" .

# Go
grep -rn "xml\.Decoder\|xml\.Unmarshal\|encoding/xml" .
grep -rn "yaml\.Unmarshal\|gopkg.in/yaml" .

# Ruby
grep -rn "Nokogiri\|REXML\|Ox\.\|LibXML" .

# PHP
grep -rn "simplexml\|DOMDocument\|XMLReader\|xml_parse" .
```

### Step 2: Check Entity/DTD Configuration

For each parser found, check:
1. Does it process DTD declarations by default?
2. Is there a `maxExpansion` or `maxEntitySize` option?
3. Is DTD processing explicitly disabled?
4. Does it support custom entity resolution?

### Step 3: Check for Expansion Limits

```
grep -rn "maxExpansion\|maxEntitySize\|entityExpansion\|ENTITY_EXPANSION" .
grep -rn "disableDTD\|forbidDTD\|dtd.*false\|FEATURE_SECURE_PROCESSING" .
grep -rn "noent\|resolve_entities\|processEntities" .
```

### Step 4: Check YAML Alias Limits

```
grep -rn "maxAliasCount\|maxAliases\|aliasLimit\|MAX_ALIAS" .
grep -rn "anchorLimit\|maxAnchors" .
```

### Step 5: Verify Exploitability

1. Does the parser accept untrusted input? (user uploads, API requests, webhook payloads)
2. Is there a file size limit that would prevent the payload from being processed?
3. Is the process memory-limited (cgroups, ulimit)?
4. Does the parser use streaming that could limit memory usage?

## Known Parser Default Safety

| Parser | Language | DTD/Entity Default | Safe? |
|--------|----------|-------------------|-------|
| fast-xml-parser | JS | Entities processed, no limit | UNSAFE |
| xml2js | JS | Entities processed, no limit | UNSAFE |
| xmldom | JS | Entities processed, no limit | UNSAFE |
| sax | JS | No entity expansion | SAFE |
| cheerio (htmlparser2) | JS | No DTD support | SAFE |
| xml.etree.ElementTree | Python | Entities processed, no limit | UNSAFE |
| lxml | Python | DTD disabled by default | SAFE (default) |
| defusedxml | Python | All dangerous features disabled | SAFE |
| xml.sax | Python | Entities processed | UNSAFE |
| PyYAML yaml.load | Python | Aliases processed, no limit | UNSAFE |
| PyYAML yaml.safe_load | Python | Aliases processed, no limit | UNSAFE (aliases) |
| encoding/xml | Go | No entity support | SAFE |
| go-yaml v3 | Go | Aliases processed, limited | CHECK VERSION |
| Nokogiri | Ruby | DTD disabled by default | SAFE (default) |
| REXML | Ruby | Entities processed | UNSAFE |
| simplexml_load_string | PHP | Entities processed by default | UNSAFE |
| DOMDocument | PHP | Entities processed by default | UNSAFE |

## CVSS Guidance

- Unauthenticated OOM crash (process dies): HIGH 7.5 (AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H)
- Authenticated OOM crash: MEDIUM 6.5 (PR:L)
- CPU exhaustion (recoverable): MEDIUM 5.3

## References

- [Sinks](references/sinks.md) — XML/YAML parser safety status by language
- [False Positive Indicators](references/false-positive-indicators.md) — When this isn't exploitable
- [PoC Skeleton](references/poc-skeleton.md) — Billion Laughs payload templates
