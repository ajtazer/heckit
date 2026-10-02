# GitHub Advisory API Usage

## Authentication

Use GitHub CLI (gh) which handles authentication:
```bash
gh auth status  # Verify authentication
```

## Search Advisories

### By Ecosystem
```bash
# npm advisories
gh api "/advisories?ecosystem=npm&per_page=50"

# PyPI advisories
gh api "/advisories?ecosystem=pip&per_page=50"

# Go advisories
gh api "/advisories?ecosystem=go&per_page=50"

# RubyGems advisories
gh api "/advisories?ecosystem=rubygems&per_page=50"
```

### By Severity
```bash
gh api "/advisories?ecosystem=npm&severity=critical&per_page=50"
gh api "/advisories?ecosystem=npm&severity=high&per_page=50"
```

### By Keyword
```bash
gh api "/advisories?ecosystem=npm&keyword=injection&per_page=20"
gh api "/advisories?ecosystem=npm&keyword=traversal&per_page=20"
gh api "/advisories?ecosystem=npm&keyword=prototype&per_page=20"
```

### By Date Range
```bash
# Advisories published after a specific date
gh api "/advisories?ecosystem=npm&published=2025-01-01..2025-12-31&per_page=50"
```

## GraphQL API (More Powerful)

```bash
gh api graphql -f query='
{
  securityAdvisories(
    first: 10,
    orderBy: {field: PUBLISHED_AT, direction: DESC},
    ecosystem: NPM,
    severity: CRITICAL
  ) {
    nodes {
      ghsaId
      summary
      severity
      publishedAt
      references { url }
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
```

## Get Advisory Details

```bash
# By GHSA ID
gh api "/advisories/GHSA-xxxx-xxxx-xxxx"

# Get the fix commit
# Usually linked in the advisory references
```

## Rate Limiting

- Authenticated: 5000 requests/hour
- GraphQL: 5000 points/hour
- Use `gh api --cache 1h` for repeated queries

## Workflow

1. Search for recent advisories in target ecosystem
2. Filter by severity and vulnerability type
3. Read advisory details and find fix commit
4. Analyze the fix diff for completeness
5. Check for variant vulnerabilities
6. Cross-reference with similar packages
