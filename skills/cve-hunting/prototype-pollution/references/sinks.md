# Object Manipulation Sinks

## Vulnerable Patterns

| Pattern | Risk | Notes |
|---------|------|-------|
| `lodash.merge(target, source)` | HIGH | Deep merge, older versions vulnerable |
| `lodash.defaultsDeep(target, source)` | HIGH | Same issue |
| `jQuery.extend(true, target, source)` | HIGH | Deep extend, older versions |
| `Object.assign(target, source)` | LOW | Shallow only, no __proto__ traversal |
| `{...source}` spread operator | LOW | Shallow, safe |
| Custom recursive merge | HIGH | Check key filtering |
| `set(obj, path, value)` | HIGH | If path is user-controlled |
| `deepmerge(target, source)` | CHECK | Depends on version |
| `extend(true, target, source)` | HIGH | Many implementations vulnerable |

## Key Distinction

**Shallow operations** (Object.assign, spread) do NOT traverse into __proto__ -- they copy the key literally but do not follow the prototype chain. These are generally safe.

**Deep/recursive operations** that traverse nested objects ARE vulnerable if they do not filter __proto__/constructor keys.

## Safe Patterns

- `Object.create(null)` -- creates object with no prototype
- Key filtering: `if (key === '__proto__' || key === 'constructor') continue`
- `Object.keys()` / `Object.entries()` -- skip inherited properties
- `Map` instead of plain objects -- no prototype chain
