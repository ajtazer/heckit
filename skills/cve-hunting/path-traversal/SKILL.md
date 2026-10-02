---
name: path-traversal
description: "Detect path traversal and Zip Slip vulnerabilities where user-controlled path components can escape intended directories."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
    - "**/*.go"
  bashPattern:
    - "semgrep.*path"
    - "grep.*(path\\.join|writeFile|extractall)"
  priority: 90
---

# Path Traversal & Zip Slip Detection

## When to Use

Audit archive extraction libraries, file upload handlers, static file servers, file path utilities, and any package that writes files based on user-controlled names.

~85% CVE acceptance rate when confirmed.

## Key Insight

`path.join()` does NOT prevent `..` traversal in Node.js:
```js
path.join('/uploads', '../../../etc/passwd')
// Returns: '/etc/passwd' -- NOT '/uploads/etc/passwd'
```

`path.resolve()` returns an absolute path but also does NOT validate that it stays within a base directory.

## Variants

### 1. Classic Path Traversal
User controls a filename/path parameter that is concatenated with a base directory:
```js
const filePath = path.join(uploadDir, req.params.filename);
fs.readFileSync(filePath); // ../../../etc/passwd
```

### 2. Zip Slip
Malicious archive entries contain `../` in their filenames. During extraction, files are written outside the intended directory:
```
malicious.zip contains:
  ../../../../tmp/pwned.txt
```

### 3. Symlink Following
Archive contains a symlink pointing outside the target directory, then a file targeting that symlink. During extraction, the file follows the symlink and writes to an arbitrary location.

### 4. Backslash Bypass
On Windows or with naive path checks, `..\` bypasses `../` filtering:
```js
filename = "..\\..\\..\\etc\\passwd"
```

### 5. URL Encoding Bypass
```
%2e%2e%2f = ../
%2e%2e/ = ../
..%2f = ../
Double encoding: %252e%252e%252f
```

### 6. Null Byte (Legacy)
```
../../etc/passwd%00.png
```
Older systems truncate at null byte. Rare in modern runtimes.

## Process

### Step 1: Find File Operations

```
# JavaScript/TypeScript
grep -rn "fs\.writeFile\|fs\.createWriteStream\|fs\.rename\|fs\.copyFile" .
grep -rn "fs\.readFile\|fs\.readFileSync\|fs\.createReadStream" .
grep -rn "path\.join\|path\.resolve" .

# Python
grep -rn "open(.*w\|shutil\.copy\|shutil\.move\|os\.rename" .
grep -rn "extractall\|extract(" .

# Go
grep -rn "os\.Create\|os\.OpenFile\|io\.Copy\|filepath\.Join" .
grep -rn "archive/zip\|archive/tar" .
```

### Step 2: Check Archive Extraction

```
grep -rn "unzip\|extract\|decompress\|gunzip\|untar" .
grep -rn "adm-zip\|yauzl\|unzipper\|archiver\|tar\|fflate\|JSZip\|node-7z" .
grep -rn "zipfile\|tarfile\|py7zr\|patool" .
```

### Step 3: Check Path Validation

```
grep -rn "startsWith\|indexOf\|includes\|realpath\|normalize" .
grep -rn "\.\." . --include="*.js" | grep -i "reject\|deny\|block\|filter"
```

### Step 4: Verify Validation Effectiveness

Common INCORRECT validations:
- `path.join(base, input)` -- does NOT prevent traversal
- `input.indexOf('..') === -1` -- can be bypassed with `....//` or encoding
- `input.replace('../', '')` -- bypassed with `....//` (after removal, `../` remains)

CORRECT validations:
- `path.resolve(base, input)` then `result.startsWith(base + path.sep)` -- verifies result is within base
- `fs.realpathSync()` to resolve symlinks before checking

## CVSS Guidance

- Arbitrary file read (unauthenticated): HIGH 7.5
- Arbitrary file write via Zip Slip: HIGH 7.5-8.1
- File write + code execution (overwrite config/executable): CRITICAL 9.8
- Authenticated file read: MEDIUM 6.5

## References

- [Sinks](references/sinks.md) -- File operation sinks by language
- [False Positive Indicators](references/false-positive-indicators.md) -- When this isn't exploitable
- [PoC Skeleton](references/poc-skeleton.md) -- Path traversal and Zip Slip PoC templates
