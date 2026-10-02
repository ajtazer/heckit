# grep.app Detailed Usage Guide

## URL Format

Base URL: `https://grep.app/search`

### Parameters
| Parameter | Values | Example |
|-----------|--------|---------|
| `q` | URL-encoded query | `q=new+Function` |
| `regexp` | true/false | `regexp=true` |
| `filter[lang][0]` | Language name | `filter[lang][0]=JavaScript` |
| `filter[repo]` | org/repo | `filter[repo]=lodash/lodash` |
| `page` | Page number | `page=2` |

## Example Searches That Found Real CVEs

### Code Injection via new Function
```
https://grep.app/search?q=new+Function%28%60&regexp=false&filter[lang][0]=JavaScript
```
Found: fastest-validator, djv, dot (doT), property-expr

### Entity Expansion (no limit check)
```
https://grep.app/search?q=processEntities&regexp=false&filter[lang][0]=JavaScript
```
Found: fast-xml-parser (before fix), xml-js

### Recursive Clone Without Depth
```
https://grep.app/search?q=function+clone%28&regexp=false&filter[lang][0]=JavaScript
```
Found: rfdc, klona (before fixes)

### Zip Slip Pattern
```
https://grep.app/search?q=entry.fileName&regexp=false&filter[lang][0]=JavaScript
```
Found: unzipper, adm-zip, decompress

## Tips for Effective Searching

1. **Start specific, then broaden**: Begin with exact function names, then generalize
2. **Filter by language**: Reduces noise significantly
3. **Check context**: A matching line in a test file is not a finding
4. **Exclude common false positives**: Skip node_modules, vendor, dist, build directories
5. **Cross-reference downloads**: A match in a package with 10 weekly downloads is not worth pursuing
6. **Check for existing fixes**: The match may be in a patched version

## Alternative Cross-Repo Search Tools

| Tool | URL | Notes |
|------|-----|-------|
| grep.app | grep.app | Best for regex, fast, free |
| GitHub Code Search | github.com/search | Integrated with GH, limited regex |
| Sourcegraph | sourcegraph.com | Powerful, structural search |
| SearchCode | searchcode.com | Simple, covers many repos |

## Rate Limiting

grep.app does not document rate limits, but:
- Do not hammer with automated requests
- Use reasonable intervals (1-2 seconds between requests)
- Cache results locally
- For large-scale scanning, consider cloning repos locally and using ripgrep
