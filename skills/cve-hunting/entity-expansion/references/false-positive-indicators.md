# False Positive Indicators — Entity Expansion

## When Entity Expansion is NOT Exploitable

### 1. Parser Disables DTD/Entity Processing

The parser is configured to reject DTDs entirely:
```js
// fast-xml-parser with entities disabled
new XMLParser({ processEntities: false });
```
```python
# defusedxml — all dangerous features off by default
import defusedxml.ElementTree as ET
```

**How to verify**: Search for parser configuration options. Check if `processEntities`, `forbidDtd`, `disableEntityExpansion`, or equivalent is set.

### 2. Uses Safe Parser Defaults

Some parsers are safe by default:
- `sax` (JS) — no entity expansion
- `htmlparser2` / `cheerio` (JS) — no DTD support
- `encoding/xml` (Go) — no custom entity support
- `lxml` (Python) — DTD disabled by default
- `defusedxml` (Python) — all dangerous features disabled
- `Nokogiri` (Ruby) — DTD disabled by default

### 3. Has Expansion Limits Configured

The parser has explicit limits that prevent the bomb from being effective:
```js
new XMLParser({ maxEntities: 100 });
```
```yaml
# go-yaml v3 default: 1000 alias limit
# But check if limit is sufficient — 1000 aliases with recursive expansion can still be large
```

**Caveat**: A limit of 10000 may still allow significant memory consumption. Calculate the actual expansion: if each entity doubles in size, 10000 entities could still mean gigabytes.

### 4. Input is From Trusted Source

The XML/YAML input comes from:
- Internal service-to-service communication (not user-facing)
- Trusted configuration files
- Database records set by admin users

### 5. Input Size is Bounded

The system enforces a maximum input size before parsing:
- HTTP body size limit (e.g., 1MB max request body)
- File upload size limit

**Caveat**: Even small XML can expand massively. A 1KB Billion Laughs payload can expand to 1GB+. Only reject if the input limit is very small (< 100 bytes) or if the parser has entity limits.

### 6. Process Has Memory Limits

The process runs with strict memory limits:
- Container memory limit (cgroups)
- ulimit settings
- Kubernetes resource limits

**Note**: This is a mitigation, not a fix. The process will still be killed (OOM), which is a denial of service. Only reject if the process restarts automatically AND the restart is fast enough that impact is negligible.

### 7. Streaming Parser with Backpressure

The parser uses streaming and the consumer applies backpressure:
- SAX/event-based parser where events are processed one at a time
- Stream-based parser with flow control

**Caveat**: Even streaming parsers may buffer entity expansion internally before emitting events. Test to confirm.
