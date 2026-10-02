# Diff Analysis -- Reading Security Patches

## How to Read a Security Fix Diff

### Step 1: Identify What Changed

```bash
git show <fix_commit> --stat  # Files changed
git show <fix_commit>          # Full diff
```

### Step 2: Categorize the Fix

| Fix Type | What to Look For |
|----------|-----------------|
| Input validation added | New regex, allowlist, or blocklist |
| Sanitization added | New escape/encode function call |
| Configuration changed | Default changed to safe value |
| Code path removed | Dangerous function removed entirely |
| Dependency updated | Library version bumped |

### Step 3: Check Completeness

For EACH fix type, ask:

**Validation added?**
- Does it cover ALL input paths? (check other functions calling the same code)
- Is it a blocklist? (blocklists are almost always bypassable)
- Does it handle encoding? (URL encoding, double encoding, Unicode)
- Does it handle case sensitivity?

**Sanitization added?**
- Is it applied BEFORE the dangerous operation? (not after)
- Is it the RIGHT escaping for the context? (SQL vs HTML vs shell)
- Is it applied to ALL dangerous parameters?

**Configuration changed?**
- Is the old default still accessible via config?
- Can the user override the safe default?

### Step 4: Look for Similar Code

```bash
# Find similar patterns in the same codebase
grep -rn "SIMILAR_PATTERN" .
# If the fix was in function A, check functions B, C, D
```

### Example: Incomplete Path Traversal Fix

A popular archive library fixed forward slash `../` in ZIP entry names but missed backslash `..\`:

The diff showed:
```diff
+ if (name.indexOf('../') >= 0) throw new Error('invalid');
```
But did NOT add:
```
+ if (name.indexOf('..\\') >= 0) throw new Error('invalid');
```

This is a classic blocklist bypass — the fix only covered one representation of the same attack.
