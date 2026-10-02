---
name: decompression-bomb
description: "Detect decompression bomb vulnerabilities where compressed input can expand to exhaust memory, targeting buffer-based decompression without size limits."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
    - "**/*.go"
  bashPattern:
    - "grep.*(zlib|gzip|deflate|decompress|inflate|gunzip)"
  priority: 78
---

# Decompression Bomb Detection

## When to Use

Audit archive/compression libraries, file upload handlers, content-encoding processors, and any package that decompresses user-supplied data.

## Key Insight

**Buffer-based decompression is vulnerable**: the entire decompressed output is loaded into memory at once. A 1KB compressed payload can expand to 1GB+.

**Stream-based MAY have backpressure**: but only if the consumer applies it. Many stream implementations still buffer the entire output.

## Process

### Step 1: Find Decompression Sinks

```
# JavaScript
grep -rn "zlib\.gunzip\|zlib\.inflate\|zlib\.unzip\|zlib\.brotli" .
grep -rn "gunzipSync\|inflateSync\|unzipSync\|brotliDecompress" .
grep -rn "pako\|fflate\|lz-string\|snappy" .
grep -rn "decompress\|decompressSync\|uncompress" .

# Python
grep -rn "zlib\.decompress\|gzip\.decompress\|bz2\.decompress" .
grep -rn "lzma\.decompress\|snappy\.decompress" .

# Go
grep -rn "gzip\.NewReader\|zlib\.NewReader\|flate\.NewReader" .
grep -rn "compress/gzip\|compress/zlib\|compress/flate" .
```

### Step 2: Check for Size Limits

```
grep -rn "maxSize\|maxOutput\|maxLength\|MAX_SIZE\|outputLimit\|sizeLimit" .
grep -rn "ratio\|compressionRatio\|maxRatio" .
```

### Step 3: Check Buffer vs Stream

Buffer-based (VULNERABLE):
```js
zlib.gunzipSync(input)                    // Entire output in memory
zlib.gunzip(input, (err, result) => {})   // Callback with full buffer
```

Stream-based (CHECK):
```js
input.pipe(zlib.createGunzip()).pipe(output)  // Streaming, may have backpressure
```

Even stream-based can be vulnerable if:
- Output is collected into a buffer: `const chunks = []; stream.on('data', c => chunks.push(c))`
- No backpressure is applied
- Consumer reads faster than it can process

### Step 4: Verify Exploitability

1. Can the attacker supply compressed data? (file upload, HTTP content-encoding, archive processing)
2. Is there an input size limit that would prevent the bomb?
3. Is there a decompressed size limit?
4. Is the process memory-limited?

## CVSS Guidance

- Unauthenticated OOM crash: HIGH 7.5
- Authenticated OOM crash: MEDIUM 6.5
- Stream-based with memory growth: MEDIUM 5.3
- With input size limits that bound expansion: may not be exploitable

## References

- [Sinks](references/sinks.md) -- Decompression sinks by language
- [False Positive Indicators](references/false-positive-indicators.md)
- [PoC Skeleton](references/poc-skeleton.md)
