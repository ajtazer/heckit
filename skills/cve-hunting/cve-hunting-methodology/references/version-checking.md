# Version Checking — Always Verify the Exact Version

**Reporting vulnerabilities in already-patched versions is the #1 embarrassment in security research.**

## Why This Matters

- Maintainers lose trust in researchers who report fixed bugs
- It wastes everyone's time and clutters advisory databases
- Your credibility drops with every false report

## Verification Process

### Step 1: Identify the Exact Installed Version

```bash
# npm
cat node_modules/<package>/package.json | grep '"version"'
npm ls <package>

# PyPI
pip show <package> | grep Version

# Go
grep <package> go.sum
go list -m <package>

# Ruby
bundle show <gem> | grep -i version
```

### Step 2: Check for Existing CVEs on That Version

```bash
# NVD
./scripts/check-nvd.sh <package-name>

# OSV.dev (version-specific)
./scripts/check-osv.sh npm <package-name> <version>
./scripts/check-osv.sh PyPI <package-name> <version>

# GitHub Advisory Database
gh api graphql -f query='{ securityVulnerabilities(ecosystem:NPM, package:"<package>", first:10) { nodes { advisory { summary ghsaId } vulnerableVersionRange firstPatchedVersion { identifier } } } }'
```

### Step 3: Check the CHANGELOG

Look for entries containing: "security", "fix", "CVE", "vulnerability", "patch", "sanitize", "escape", "validate"

```bash
# In the cloned repo
grep -i "security\|CVE\|vulnerab\|sanitiz\|escap" CHANGELOG.md CHANGES.md HISTORY.md 2>/dev/null
git log --oneline --grep="security\|CVE\|fix" --since="1 year ago"
```

### Step 4: Check Git History for Security Commits

```bash
git log --all --oneline --grep="security" --grep="CVE" --grep="vulnerability" --grep="injection" --grep="traversal" --grep="XSS"
```

### Step 5: Test Against Latest Release

```bash
# Always install latest before testing
npm install <package>@latest
pip install --upgrade <package>
```

**Never test only against the version in your local node_modules — it may be outdated.**

## Common Pitfalls

| Pitfall | Example | How to Avoid |
|---------|---------|--------------|
| Testing old version | Testing qs@6.5.2 when 6.14.2 is latest | Always `npm install <pkg>@latest` |
| Missing patch release | Bug fixed in 2.3.1, testing 2.3.0 | Check all patch versions |
| Different package name | Confusing `xml2js` with `xml-js` | Verify exact package name in NVD |
| Backported fix | Fix backported to LTS branch | Check all maintained branches |
| Pre-release fix | Fixed in 3.0.0-beta but not 2.x | Note which versions are affected |
