---
name: advisory-mining
description: "Mine GitHub Security Advisories and CVE databases for incomplete fixes, finding variant vulnerabilities in patched code or similar patterns in related packages."
metadata:
  filePattern:
    - "**/CHANGELOG.md"
    - "**/SECURITY.md"
    - "**/.github/SECURITY.md"
  bashPattern:
    - "gh api.*advisories"
    - "curl.*nvd\\.nist\\.gov"
    - "git log.*security"
  priority: 75
---

# Advisory Mining -- Finding Incomplete Fixes

## When to Use

Looking for high-acceptance-rate findings. Incomplete fix variants have ~95% acceptance rate because:
1. The vulnerability class is already acknowledged
2. The fix proves the maintainer cares about security
3. The variant proves the fix was insufficient

## Process

### Step 1: Find Recent Advisories

```bash
# GitHub Advisory API -- recent npm advisories
gh api graphql -f query='
{
  securityAdvisories(first: 20, orderBy: {field: PUBLISHED_AT, direction: DESC}, ecosystem: NPM) {
    nodes {
      ghsaId
      summary
      severity
      publishedAt
      vulnerabilities(first: 5) {
        nodes {
          package { name ecosystem }
          vulnerableVersionRange
          firstPatchedVersion { identifier }
        }
      }
    }
  }
}'

# Search by keyword
gh api "/advisories?ecosystem=npm&keyword=injection&per_page=20"
gh api "/advisories?ecosystem=pip&keyword=traversal&per_page=20"
```

### Step 2: Read the Patch Diff

For each advisory:
1. Find the fix commit (linked in the advisory or CHANGELOG)
2. Read the diff carefully
3. Ask: what did they fix? What did they NOT fix?

```bash
# Find security-related commits
git log --oneline --all | grep -i "security\|fix\|vuln\|CVE\|patch\|sanitize"

# Read the patch
git show <commit_hash>
git diff <before_commit>..<fix_commit>
```

### Step 3: Check for Incomplete Fix Patterns

Common incomplete fixes:

| What Was Fixed | What Was Missed |
|---------------|-----------------|
| `../` blocked | `..\` not blocked (Windows) |
| `__proto__` filtered | `constructor.prototype` not filtered |
| One regex fixed | Similar regex in same file not fixed |
| One function fixed | Wrapper function calls it differently |
| Parsing fixed | Serialization has same bug |
| Validation added | Can be bypassed with encoding |
| One entry point fixed | Other entry points not covered |
| Input sanitized | Error messages leak unsanitized data |

### Step 4: Search for Same Pattern in Other Packages

If the vulnerability is in a common pattern (e.g., path.join without validation), search for it in similar packages:

```bash
# Use grep.app to find same pattern across repos
# See cross-pollination skill for details
```

### Step 5: Verify the Variant

Apply the fp-check skill to verify the variant is real before submitting.

## NVD API

```bash
# Search NVD for CVEs by keyword
curl "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=xml+parser+javascript"

# Search by CPE
curl "https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=cpe:2.3:a:vendor:product:*"
```

## CVSS Guidance

Variant findings typically get:
- Same CVSS as original if the variant has same impact
- Higher CVSS if the variant bypasses the fix AND adds new impact
- Lower CVSS if the variant has additional prerequisites

## References

- [Diff Analysis](references/diff-analysis.md) -- How to read security patches
- [GHSA API](references/ghsa-api.md) -- GitHub Advisory API usage
