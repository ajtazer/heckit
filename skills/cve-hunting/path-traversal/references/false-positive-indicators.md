# False Positive Indicators -- Path Traversal

## When Path Traversal is NOT Exploitable

### 1. Proper Path Validation

Uses resolve + startsWith check BEFORE file access:
```js
const resolved = path.resolve(baseDir, userInput);
if (!resolved.startsWith(baseDir + path.sep)) throw new Error('invalid');
```

### 2. Uses realpath to Canonicalize

Python `os.path.realpath()` or Node.js `fs.realpathSync()` resolves symlinks and normalizes the path, then checks it against the base directory.

### 3. Go filepath.Rel Check

```go
rel, err := filepath.Rel(base, absPath)
if err != nil || strings.HasPrefix(rel, "..") { /* reject */ }
```

### 4. Archive Library Handles Internally

Some archive libraries sanitize entry paths in newer versions. VERIFY which version:
- Python `zipfile.extractall()` with `filter='data'` (Python 3.12+)
- tar-stream with path validation callback

### 5. Input is From Trusted Source

Path comes from database, config file, or admin-only input. Not user-controlled.

### 6. Directory is Read-Only or No Sensitive Files

The target directory contains only public/non-sensitive files and is read-only.

### 7. Already Patched (Check Version)

Known CVE already exists for this exact vector in this exact version. Check NVD.

### 8. Static File Server with Built-in Protection

Frameworks like Express `res.sendFile()` with `root` option prevent traversal. Check if the framework handles it.
