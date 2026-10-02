# Shell Execution Sinks by Language

## JavaScript / TypeScript

| Sink | Uses Shell? | Risk | Notes |
|------|------------|------|-------|
| `child_process.exec(cmd)` | YES | CRITICAL | Always uses shell. String command. |
| `child_process.execSync(cmd)` | YES | CRITICAL | Synchronous shell execution |
| `child_process.spawn(cmd, {shell: true})` | YES | CRITICAL | Shell mode enabled |
| `child_process.execFile(file, args)` | NO | MEDIUM | No shell. Argument injection possible. |
| `child_process.spawn(cmd, args)` | NO | MEDIUM | No shell by default. Safer. |
| `child_process.fork(module)` | NO | LOW | Forks Node.js process |
| `shelljs.exec(cmd)` | YES | CRITICAL | Shell wrapper library |
| `execa(cmd, {shell: true})` | YES | CRITICAL | Popular exec wrapper |
| `execa(cmd, args)` | NO | MEDIUM | No shell by default |

### exec vs execFile
- exec(): String command, shell interprets metacharacters. DANGEROUS.
- execFile(): Array args, no shell. SAFER. Argument injection still possible.
- spawn({shell: true}): Negates array safety. DANGEROUS.

## Python

| Sink | Uses Shell? | Risk | Notes |
|------|------------|------|-------|
| `os.system(cmd)` | YES | CRITICAL | Always uses shell |
| `os.popen(cmd)` | YES | CRITICAL | Shell execution, returns pipe |
| `subprocess.run(cmd, shell=True)` | YES | CRITICAL | Shell mode |
| `subprocess.Popen(cmd, shell=True)` | YES | CRITICAL | Shell mode |
| `subprocess.run([prog, arg1])` | NO | MEDIUM | List args, no shell |
| `subprocess.Popen([prog, arg1])` | NO | MEDIUM | List args, no shell |
| `commands.getoutput(cmd)` | YES | CRITICAL | Deprecated, uses shell |

## Go

| Sink | Uses Shell? | Risk | Notes |
|------|------------|------|-------|
| `exec.Command(name, args...)` | NO | MEDIUM | Direct exec, no shell |
| `exec.Command("bash", "-c", cmd)` | YES | CRITICAL | Explicitly uses shell |
| `exec.Command("sh", "-c", cmd)` | YES | CRITICAL | Explicitly uses shell |

## Ruby

| Sink | Uses Shell? | Risk | Notes |
|------|------------|------|-------|
| `system(cmd)` (string) | YES | CRITICAL | Shell for string arg |
| `system(prog, arg1, arg2)` (array) | NO | MEDIUM | No shell for array args |
| `exec(cmd)` (string) | YES | CRITICAL | Replaces process |
| Backticks / `%x{}` | YES | CRITICAL | Shell execution |
| `IO.popen(cmd)` | YES | CRITICAL | Shell for string arg |
| `Open3.capture2(cmd)` | YES | CRITICAL | Shell for string arg |

## PHP

| Sink | Uses Shell? | Risk | Notes |
|------|------------|------|-------|
| `exec($cmd)` | YES | CRITICAL | Shell execution |
| `system($cmd)` | YES | CRITICAL | Shell execution, outputs directly |
| `passthru($cmd)` | YES | CRITICAL | Shell execution, binary safe |
| `shell_exec($cmd)` | YES | CRITICAL | Shell execution |
| `popen($cmd, $mode)` | YES | CRITICAL | Shell execution, returns pipe |
| `proc_open($cmd, ...)` | YES | CRITICAL | Shell execution, advanced |

### PHP safe functions
- `escapeshellarg()` — wraps in single quotes, escapes existing quotes
- `escapeshellcmd()` — escapes metacharacters but NOT safe for all argument contexts
