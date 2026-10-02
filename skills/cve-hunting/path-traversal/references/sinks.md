# File Operation Sinks by Language

## JavaScript / TypeScript

| Sink | Operation | Risk |
|------|-----------|------|
| `fs.writeFile(path, data)` | Write | HIGH -- arbitrary file write |
| `fs.writeFileSync(path, data)` | Write | HIGH |
| `fs.createWriteStream(path)` | Write | HIGH |
| `fs.readFile(path)` | Read | MEDIUM -- arbitrary file read |
| `fs.readFileSync(path)` | Read | MEDIUM |
| `fs.createReadStream(path)` | Read | MEDIUM |
| `fs.rename(old, new)` | Move | HIGH -- can move files outside dir |
| `fs.copyFile(src, dst)` | Copy | HIGH |
| `fs.unlink(path)` | Delete | HIGH -- arbitrary file delete |
| `path.join(base, input)` | Construct | UNSAFE -- does NOT prevent ../ |
| `path.resolve(input)` | Construct | UNSAFE -- still needs startsWith check |

### Archive Libraries
| Library | Function | Zip Slip Status |
|---------|----------|-----------------|
| adm-zip | `extractAllTo()` | VULNERABLE in older versions |
| yauzl | `entry.fileName` | SAFE -- warns in docs, user must validate |
| unzipper | `Extract()` | CHECK -- some versions vulnerable |
| tar | `tar.extract()` | CHECK -- preservePaths option |
| decompress | `decompress()` | VULNERABLE in older versions |
| fflate | `unzipSync()` | CHECK version |
| JSZip | `forEach()` + manual extract | User responsibility |

## Python

| Sink | Operation | Risk |
|------|-----------|------|
| `open(path, 'w')` | Write | HIGH |
| `shutil.copy(src, dst)` | Copy | HIGH |
| `shutil.move(src, dst)` | Move | HIGH |
| `os.rename(old, new)` | Move | HIGH |
| `zipfile.extractall()` | Extract | CHECK -- Python 3.12+ has filter param |
| `tarfile.extractall()` | Extract | VULNERABLE -- CVE-2007-4559 (partially fixed) |
| `os.path.join(base, input)` | Construct | UNSAFE if input starts with / |

## Go

| Sink | Operation | Risk |
|------|-----------|------|
| `os.Create(path)` | Write | HIGH |
| `os.OpenFile(path, ...)` | Read/Write | HIGH |
| `io.Copy(dst, src)` | Copy | Depends on dst |
| `filepath.Join(base, input)` | Construct | UNSAFE -- Clean() does NOT prevent ../ above base |
| `filepath.Clean(path)` | Normalize | Does NOT validate, only normalizes |

### Go safe pattern
```go
// CORRECT: Check result stays within base
absPath := filepath.Join(base, userInput)
if !strings.HasPrefix(absPath, filepath.Clean(base) + string(os.PathSeparator)) {
    return errors.New("path traversal detected")
}
```
