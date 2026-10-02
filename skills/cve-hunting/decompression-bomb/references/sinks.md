# Decompression Sinks by Language

## JavaScript / TypeScript

| Sink | Type | Risk |
|------|------|------|
| `zlib.gunzipSync(buf)` | Buffer | HIGH -- full output in memory |
| `zlib.inflateSync(buf)` | Buffer | HIGH |
| `zlib.brotliDecompressSync(buf)` | Buffer | HIGH |
| `zlib.gunzip(buf, callback)` | Buffer (async) | HIGH -- full output in callback |
| `zlib.createGunzip()` | Stream | MEDIUM -- check backpressure |
| `zlib.createInflate()` | Stream | MEDIUM |
| `pako.inflate(buf)` | Buffer | HIGH |
| `pako.ungzip(buf)` | Buffer | HIGH |
| `fflate.decompressSync(buf)` | Buffer | HIGH |
| `fflate.gunzipSync(buf)` | Buffer | HIGH |
| `lz-string.decompress(str)` | Buffer | HIGH |
| `snappy.uncompressSync(buf)` | Buffer | HIGH |

## Python

| Sink | Type | Risk |
|------|------|------|
| `zlib.decompress(data)` | Buffer | HIGH |
| `gzip.decompress(data)` | Buffer | HIGH |
| `bz2.decompress(data)` | Buffer | HIGH |
| `lzma.decompress(data)` | Buffer | HIGH |
| `gzip.open().read()` | Stream->Buffer | HIGH if read() called |
| `zipfile.read()` | Buffer | HIGH |
| `tarfile.extractfile().read()` | Stream->Buffer | HIGH |

### Python zlib with maxLength
```python
# SAFER -- limits output size
zlib.decompress(data, wbits=15, bufsize=MAX_SIZE)
# But bufsize is just initial allocation, not a hard limit!
# Use zlib.decompressobj() with incremental decompression for true limiting
```

## Go

| Sink | Type | Risk |
|------|------|------|
| `gzip.NewReader(r)` + `io.ReadAll()` | Stream->Buffer | HIGH |
| `zlib.NewReader(r)` + `io.ReadAll()` | Stream->Buffer | HIGH |
| `io.Copy(dst, gzipReader)` | Stream | MEDIUM -- depends on dst |
| `io.LimitReader(r, maxBytes)` | Stream | SAFE -- hard limit |
