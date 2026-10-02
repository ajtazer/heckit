---
name: command-injection
description: "Detect OS command injection via shell execution sinks where user-controlled input reaches system commands without proper sanitization."
metadata:
  filePattern:
    - "**/*.js"
    - "**/*.ts"
    - "**/*.py"
    - "**/*.go"
    - "**/*.rb"
    - "**/*.php"
  bashPattern:
    - "semgrep.*cmdi"
    - "grep.*(exec|spawn|system|popen)"
  priority: 90
---

# Command Injection Detection

## When to Use

Audit any package that wraps CLI tools, runs build commands, processes files via external programs, or interfaces with git/ffmpeg/imagemagick/pandoc/etc.

CVSS is typically CRITICAL 9.8 for confirmed RCE.

## Key Distinctions

### Command Injection vs Argument Injection
- **Command injection**: Attacker breaks out of the intended command entirely (`; rm -rf /`)
- **Argument injection**: Attacker adds flags to the intended command (`--upload-pack=malicious`)
- Both are reportable. Command injection is CRITICAL, argument injection is HIGH.

### Shell vs No-Shell Execution
- **Shell execution** (exec, system, os.popen): Command string passed to shell interpreter. Metacharacters (`;`, `|`, `&&`, backticks, `$()`) are interpreted. DANGEROUS.
- **Direct execution** (execFile, spawn without shell, subprocess with list args): Arguments passed directly to the program. No shell interpretation. SAFER but argument injection may still work.

## Process

### Step 1: Find Shell Execution Sinks

```
# JavaScript/TypeScript — look for child_process usage
grep -rn "child_process" .
grep -rn "\.exec\('" .
grep -rn "\.execSync\(" .
grep -rn "spawn.*shell.*true" .
grep -rn "shelljs" .

# Python
grep -rn "os\.system\|os\.popen" .
grep -rn "subprocess.*shell.*True" .
grep -rn "commands\.getoutput\|commands\.getstatusoutput" .

# Go
grep -rn 'exec\.Command.*"bash"\|exec\.Command.*"sh"' .

# Ruby
grep -rn "system(\|%x{" . --include="*.rb"
grep -rn "IO\.popen\|Open3" .

# PHP
grep -rn "system(\|passthru(\|shell_exec(\|popen(" .
grep -rn "proc_open\|pcntl_exec" .
```

### Step 2: Trace User Input to Sink

For each sink:
1. What command string is constructed?
2. Is any part from user input (HTTP params, filenames, config values)?
3. Is the user input interpolated into a shell string or passed as an argument array?

### Step 3: Check Sanitization

```
grep -rn "escapeshellarg\|escapeshellcmd\|shlex\.quote\|shellescape" .
grep -rn "sanitize\|escape\|clean\|validate" .
```

Verify sanitization is:
- Applied to ALL user-controlled parts (not just some)
- Using the right function (escapeshellarg vs escapeshellcmd)
- Not bypassable (blocklists are almost always bypassable)

### Step 4: Check for Argument Injection

Even with execFile/spawn (no shell), check for:
- `--flag` injection: user input starts with `-` or `--`
- Git-specific: `--upload-pack`, `-c core.fsmonitor`, `--config`
- Arguments that accept commands: `--exec`, `--filter`, `--diff-filter`
- Double-dash (`--`) separator missing before user-controlled args

## Common Vulnerable Patterns

### Pattern 1: String Interpolation in Shell Execution
```js
// VULNERABLE — shell interprets metacharacters
const cp = require('child_process');
cp.exec(`convert ${inputFile} ${outputFile}`);
// Exploit: inputFile = "; id; #"
```

### Pattern 2: Filename-Based Injection
```js
cp.exec(`file "${filename}"`);
// Exploit: filename = '$(id).txt' or filename = '"; id; #"'
```

### Pattern 3: Git Argument Injection
```js
// Even without shell, git interprets dangerous flags
cp.execFile('git', ['clone', userUrl, '--config', 'core.fsmonitor=id']);
```

### Pattern 4: Environment Variable Injection
```js
cp.exec(command, { env: { ...process.env, USER_INPUT: untrusted } });
// If command references $USER_INPUT or uses env vars unsafely
```

### Pattern 5: Newline Injection
```js
cp.execFile('program', ['--option=' + userInput]);
// Exploit: userInput = "value\n--dangerous-flag"
```

## Grep Patterns by Vulnerability Type

### Direct Shell Injection
```
grep -rn "exec\(.*\+" .        # String concatenation in exec
grep -rn "exec\(.*\$\{" .      # Template literal in exec
grep -rn "exec\(.*%" .         # Format string in exec (Python)
```

### Argument Injection
```
grep -rn "execFile\|spawn" .
# Then check if user input is in the args array without -- separator
```

## CVSS Guidance

- Unauthenticated RCE: CRITICAL 9.8
- Authenticated RCE (low-priv): HIGH 8.8
- Argument injection (limited impact): HIGH 7.5-8.1
- Requires specific config/setup: HIGH 7.2 (AC:H)

## References

- [Sinks](references/sinks.md) — Shell execution sinks by language
- [False Positive Indicators](references/false-positive-indicators.md) — When this isn't exploitable
- [PoC Skeleton](references/poc-skeleton.md) — Command injection PoC template
