# Code Execution Sinks by Language

## JavaScript / TypeScript

| Sink | Risk | Notes |
|------|------|-------|
| `eval(string)` | CRITICAL | Direct code execution in current scope |
| `new Function(string)` | CRITICAL | Creates function from string, executes in global scope |
| `new Function(...args, body)` | CRITICAL | Last argument is the function body |
| `new AsyncFunction(string)` | CRITICAL | Async variant, allows await |
| `vm.runInNewContext(code, sandbox)` | CRITICAL | node:vm is NOT a security sandbox |
| `vm.runInThisContext(code)` | CRITICAL | Runs in current V8 context |
| `vm.compileFunction(code)` | CRITICAL | Compiles and returns function |
| `vm.Script(code)` + `.runInContext()` | CRITICAL | Two-step execution |
| `setTimeout(string, ms)` | HIGH | String argument is eval'd (not function) |
| `setInterval(string, ms)` | HIGH | String argument is eval'd (not function) |
| `require('module')._compile(code)` | CRITICAL | Internal Node.js module compilation |
| `import()` dynamic import | HIGH | Can load arbitrary modules from URL/path |

### Safe Variants
- `setTimeout(function, ms)` — function argument, not string
- `JSON.parse(string)` — only parses JSON, no code execution
- `vm2` (deprecated but hardened) — separate sandbox
- `isolated-vm` — separate V8 isolate, truly isolated

## Python

| Sink | Risk | Notes |
|------|------|-------|
| `eval(string)` | CRITICAL | Evaluates expression, returns result |
| `exec(string)` | CRITICAL | Executes statements |
| `compile(string, ...)` + `exec()` | CRITICAL | Two-step: compile then execute |
| `__import__(name)` | HIGH | Dynamic module import |
| `importlib.import_module(name)` | HIGH | Dynamic module import |
| `os.system(cmd)` | CRITICAL | Shell execution (see command-injection) |
| `pickle.loads(data)` | CRITICAL | Arbitrary object construction |
| `yaml.load(data)` | CRITICAL | Without Loader=SafeLoader |

### Safe Variants
- `ast.literal_eval(string)` — only evaluates literals (strings, numbers, tuples, lists, dicts, booleans, None)
- `yaml.safe_load(data)` — restricted YAML loading

## Ruby

| Sink | Risk | Notes |
|------|------|-------|
| `eval(string)` | CRITICAL | Direct code execution |
| `instance_eval(string)` | CRITICAL | Evaluates in object context |
| `class_eval(string)` | CRITICAL | Evaluates in class context |
| `module_eval(string)` | CRITICAL | Evaluates in module context |
| `send(method, *args)` | HIGH | Dynamic method dispatch |
| `public_send(method, *args)` | HIGH | Dynamic dispatch (public only) |
| `Kernel.system(cmd)` | CRITICAL | Shell execution |
| `binding.eval(string)` | CRITICAL | Evaluates with binding context |
| `ERB.new(string).result` | HIGH | Template execution |

## PHP

| Sink | Risk | Notes |
|------|------|-------|
| `eval($string)` | CRITICAL | Direct code execution |
| `assert($string)` | CRITICAL | Evaluates expression (PHP < 8.0) |
| `create_function($args, $code)` | CRITICAL | Deprecated, creates anonymous function |
| `preg_replace('/.*/e', $replacement)` | CRITICAL | /e modifier executes replacement (removed in PHP 7.0) |
| `call_user_func($func, $args)` | HIGH | Dynamic function call |
| `call_user_func_array($func, $args)` | HIGH | Dynamic function call with array args |
| `$func()` variable function | HIGH | Dynamic function call |
| `include/require($file)` | CRITICAL | File inclusion = code execution |
| `unserialize($data)` | CRITICAL | Object injection |

## Go

Go has no direct eval, but code execution is possible through:

| Sink | Risk | Notes |
|------|------|-------|
| `text/template.Execute()` | HIGH | Template with function maps can execute arbitrary funcs |
| `html/template.Execute()` | MEDIUM | Auto-escapes HTML but function maps still execute |
| `plugin.Open(path)` | CRITICAL | Loads shared library |
| `os/exec.Command()` | HIGH | Process execution (see command-injection) |
| `reflect.Value.Call()` | MEDIUM | Dynamic method invocation |

### Key Distinction
Go templates with custom `FuncMap` can expose dangerous functions. The template itself is the code, and if the template string is user-controlled, any function in the FuncMap is callable.
