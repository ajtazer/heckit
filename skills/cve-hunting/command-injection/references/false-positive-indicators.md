# False Positive Indicators -- Command Injection

## When Command Injection is NOT Exploitable

### 1. Uses Argument Arrays (No Shell)

The command uses the array/list form of execution:
```js
cp.execFile('convert', [userInput, 'output.png']);  // No shell
cp.spawn('git', ['clone', url]);  // No shell (default)
```

**Caveat**: Argument injection is still possible. Check for `--flag` injection with git, ffmpeg, and other tools that accept command-execution flags.

### 2. Input is Hardcoded or From Config

The command string contains no external input. Trace ALL parts of the command string -- even if the command name is hardcoded, arguments might come from user input.

### 3. Input Has Strict Allowlist Validation

User input is validated against a strict allowlist before use. Blocklist validation (rejecting specific characters) is almost always bypassable -- only allowlist validation is reliable.

### 4. Proper Escaping Applied

Language-specific escaping is correctly applied to ALL user-controlled parts:
- PHP: `escapeshellarg()`
- Python: `shlex.quote()`
- Ruby: `Shellwords.escape()`

### 5. Read-Only Command With No Side Effects

The command only reads data. Caveat: even read-only commands can leak sensitive data if the attacker controls the file path.

### 6. Sandboxed/Containerized Environment

Container with no sensitive data, chroot, seccomp profile. Still report but note reduced impact.

### 7. Node.js Runtime Rejection

Node.js rejects null bytes in execFile arguments but most shell metacharacters pass through in exec().
