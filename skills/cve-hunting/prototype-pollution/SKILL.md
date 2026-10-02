---
name: prototype-pollution
description: "Detect prototype pollution via object merge/clone/assign operations where __proto__ or constructor.prototype keys can modify Object.prototype."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
  bashPattern:
    - "grep.*(__proto__|prototype|constructor)"
    - "semgrep.*pollution"
  priority: 82
---

# Prototype Pollution Detection

## When to Use

Audit merge/clone/deep-assign utilities, query string parsers, JSON parsers, config mergers, and any package that recursively sets object properties from untrusted input.

**Key insight**: Only ~50% acceptance rate. Must demonstrate REAL impact beyond just polluting prototype.

## Process

### Step 1: Find Object Manipulation Sinks

```
grep -rn "Object\.assign\|Object\.defineProperty\|Object\.create" .
grep -rn "merge\|extend\|deepMerge\|deepExtend\|deepAssign\|mixin" .
grep -rn "clone\|deepClone\|cloneDeep\|deepCopy" .
grep -rn "set\|setPath\|setValue\|lodash\.set\|_.set" .
grep -rn "\[.*\]\s*=" . --include="*.js"  # Bracket notation assignment
```

### Step 2: Check for Recursive Property Setting

Look for patterns where object keys from user input are used as property paths:
```js
// VULNERABLE: recursive merge without key filtering
function merge(target, source) {
  for (const key in source) {
    if (typeof source[key] === 'object') {
      target[key] = merge(target[key] || {}, source[key]);
    } else {
      target[key] = source[key];
    }
  }
}
```

### Step 3: Check Key Filtering

```
grep -rn "__proto__\|constructor\|prototype" . | grep -i "filter\|block\|skip\|ignore\|reject"
grep -rn "Object\.create(null)" .  # Null prototype objects are safe
grep -rn "hasOwnProperty\|Object\.keys\|Object\.entries" .
```

### Step 4: Assess Impact

Prototype pollution alone is often not enough. Look for impact:
- **DoS**: Polluted property causes TypeError crash (toString, valueOf)
- **Property injection**: Polluted property affects security logic (isAdmin, role, auth)
- **Gadget chains**: Polluted property reaches dangerous sink (eval, template)
- **Method clobbering**: toString/valueOf overwritten causing crash

## Dangerous Keys

| Key | Effect | Impact |
|-----|--------|--------|
| `__proto__` | Sets properties on Object.prototype | All objects affected |
| `constructor.prototype` | Same effect via constructor chain | All objects affected |
| `constructor` | Overwrites constructor reference | Type confusion |
| `toString` | Overwrites string conversion | TypeError on string operations |
| `valueOf` | Overwrites value conversion | TypeError on comparisons |
| `hasOwnProperty` | Overwrites property check | Logic bypass |

## CVSS Guidance

- Proto pollution + RCE gadget chain: CRITICAL 9.8
- Proto pollution + auth bypass: HIGH 8.1
- Proto pollution + DoS (crash): HIGH 7.5
- Proto pollution with no demonstrated impact: MEDIUM 5.3 (often rejected)

## References

- [Sinks](references/sinks.md) -- Object manipulation sinks
- [False Positive Indicators](references/false-positive-indicators.md)
- [PoC Skeleton](references/poc-skeleton.md)
