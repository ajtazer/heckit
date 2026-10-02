# False Positive Indicators -- Decompression Bomb

### 1. Has maxSize/maxOutputSize Check
Library checks decompressed output size and aborts if exceeded.

### 2. Uses Streaming with Backpressure
Streaming decompression where the consumer applies backpressure and processes chunks without buffering the entire output.

### 3. Has Compression Ratio Limiting
Library checks the ratio of compressed to decompressed size and rejects abnormally high ratios (> 100:1 or similar).

### 4. Input Size Bounded by Upload Limits
Server enforces a maximum upload/request body size. Calculate: even worst-case compression ratio (1032:1 for gzip) applied to max input size -- is the result within memory limits?

### 5. Process Has Memory Limits
Container/cgroup memory limits. Still a DoS (process killed) but reduced blast radius.

### 6. Nested Compression Not Supported
For nested bombs (compressed data inside compressed data), the library only decompresses one level.
