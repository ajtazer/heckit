---
name: method-clobbering
description: "Detect method clobbering via user-controlled object keys that overwrite built-in methods like toString, valueOf, or hasOwnProperty, causing crashes or logic bypass."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
  bashPattern:
    - "grep.*(toString|valueOf|hasOwnProperty|constructor)"
  priority: 75
---

# Method Clobbering Detection

## When to Use

Audit CSV/form/query string parsers that create plain objects from untrusted input where the attacker can control property names (keys), not just values.

## Key Insight

When a parser creates a plain object `{}` from user input, the attacker can set keys like `toString`, `valueOf`, `hasOwnProperty` to non-function values. Any code that later calls these methods on the object will throw a TypeError.

**Important**: JSON.parse can do the same thing. You MUST show why the library-specific clobbering is worse than what JSON.parse enables. Show a REAL crash path, not just theoretical property overwrite.

## Dangerous Keys

| Key | Normal Type | Effect When Clobbered |
|-----|------------|----------------------|
| `toString` | Function | `obj + ""` throws TypeError |
| `valueOf` | Function | `obj == x` or coercion throws TypeError |
| `hasOwnProperty` | Function | `obj.hasOwnProperty(k)` throws TypeError |
| `constructor` | Function | Type checks fail |
| `__proto__` | Object | Prototype pollution (see prototype-pollution skill) |
| `__defineGetter__` | Function | Legacy getter/setter manipulation |
| `__defineSetter__` | Function | Legacy getter/setter manipulation |
| `__lookupGetter__` | Function | Legacy getter/setter introspection |
| `toJSON` | undefined | `JSON.stringify(obj)` throws TypeError |
| `then` | undefined | `await obj` or Promise.resolve(obj) treats obj as thenable |

## Process

### Step 1: Find Parsers That Create Objects

```
grep -rn "\[key\]\s*=" . --include="*.js" --include="*.ts"
grep -rn "\[header\]\|\[field\]\|\[name\]\|\[prop\]" .
grep -rn "result\[\|output\[\|obj\[\|data\[\|parsed\[" .
```

### Step 2: Check If Keys Are User-Controlled

Common sources of attacker-controlled keys:
- CSV column headers (first row)
- HTTP form field names
- Query string parameter names
- Configuration file keys
- JSON object keys (but JSON.parse already handles this)

### Step 3: Check for Key Filtering

```
grep -rn "Object\.create(null)" .  # Null prototype = safe
grep -rn "hasOwnProperty\|toString\|valueOf" . | grep -i "filter\|block\|skip"
grep -rn "Object\.keys\|Map\|new Map" .
```

### Step 4: Demonstrate Real Impact

You MUST show one of:
1. **TypeError crash**: Code calls `obj.toString()` or `obj.hasOwnProperty()` on the parsed result
2. **Logic bypass**: Code checks `obj.hasOwnProperty(x)` for security decisions
3. **Thenable confusion**: Code uses `await` or Promise.resolve() on the parsed object

```
# Find code that calls methods on parsed objects
grep -rn "\.toString()\|\.valueOf()\|\.hasOwnProperty(" .
grep -rn "JSON\.stringify(" .  # Uses toJSON
grep -rn "await\|Promise\.resolve" .  # Uses then
```

## CVSS Guidance

- TypeError crash causing DoS (unauthenticated): HIGH 7.5
- Logic bypass via hasOwnProperty clobbering: HIGH 7.5
- Thenable confusion: MEDIUM 5.3-6.5
- No demonstrated crash/bypass: likely rejected

## Self-Check Before Reporting

1. Can JSON.parse achieve the same clobbering? If yes, why is this worse?
2. Does code actually call methods on the parsed object?
3. Is the crash catchable (try/catch around it)?
4. Is the parser documented as expecting trusted input?

## References

- [Sinks](references/sinks.md) -- Parser patterns creating objects from untrusted keys
- [False Positive Indicators](references/false-positive-indicators.md)
- [PoC Skeleton](references/poc-skeleton.md)
