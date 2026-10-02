# Sandbox Mechanisms and Known Escape Patterns

## JavaScript

### node:vm (ALL UNSAFE)
| API | Escapable? | Escape Method |
|-----|-----------|---------------|
| `vm.runInNewContext(code, sandbox)` | YES | Constructor chain |
| `vm.runInThisContext(code)` | YES | Direct access to host context |
| `vm.runInContext(code, context)` | YES | Constructor chain |
| `vm.compileFunction(code)` | YES | Constructor chain via this |
| `new vm.Script(code).runInNewContext()` | YES | Constructor chain |
| `vm.createContext(sandbox)` | N/A | Creates context, doesn't execute |

### vm2 (Deprecated -- MOSTLY UNSAFE)
| Version | Status | Notes |
|---------|--------|-------|
| < 3.9.15 | UNSAFE | Multiple known escapes |
| 3.9.15-3.9.18 | PARTIALLY SAFE | Some escapes patched |
| >= 3.9.19 | MOSTLY SAFE | Most escapes patched but library deprecated |
| Any | DEPRECATED | Use isolated-vm instead |

### isolated-vm (SAFE)
Runs code in a separate V8 isolate. No shared memory, no prototype chain access. Genuinely isolated. The correct choice for running untrusted JS.

### quickjs-emscripten (SAFE)
Runs QuickJS engine compiled to WebAssembly. No access to Node.js APIs.

## Python

### simpleeval
| Version | Status | Notes |
|---------|--------|-------|
| < 0.9.13 | UNSAFE | Multiple bypasses |
| >= 0.9.13 | MOSTLY SAFE | Basic expressions safe, compound types risky |
| EvalWithCompoundTypes | UNSAFE | Allows list/dict comprehensions, more attack surface |

### ast.literal_eval (SAFE)
Only evaluates Python literals: strings, bytes, numbers, tuples, lists, dicts, sets, booleans, None, and frozensets. Cannot execute arbitrary code.

### RestrictedPython
| Version | Status | Notes |
|---------|--------|-------|
| < 5.0 | UNSAFE | Known bypasses |
| >= 5.0 | MEDIUM | Improved but still has attack surface |
| >= 6.0 | MOSTLY SAFE | Major security improvements |

### Python eval/exec (ALWAYS UNSAFE)
No sandbox. Direct code execution. Even with restricted builtins, class hierarchy traversal bypasses restrictions.

## Known Escape Techniques

### Constructor Chain (node:vm)
```js
this.constructor.constructor('return process')()
```

### Python Class Hierarchy
```python
''.__class__.__mro__[1].__subclasses__()  # All loaded classes
().__class__.__base__.__subclasses__()     # Via tuple
```

### Python Function Object Access
```python
func.__globals__  # Global namespace of function
func.__code__     # Code object, can inspect/modify
type.__subclasses__(type)  # All types
```
