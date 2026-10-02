# Standard Verification

Linear single-pass checklist for straightforward bugs. No task creation -- work through each step sequentially.

## Escalation Checkpoints

Two points may trigger escalation to deep-verification.md:

1. **After Step 1 (Data Flow)**: Escalate if 3+ trust boundaries, callbacks/async control flow, or ambiguous validation chain
2. **After Step 5 (Devil is Advocate)**: Escalate if any question produces genuine uncertainty

## Checklist

### Step 1: Data Flow

Trace data from source to the alleged vulnerability sink.

- Map trust boundaries crossed (internal/trusted vs external/untrusted)
- Identify all validation and sanitization between source and sink
- Check API contracts -- many APIs have built-in bounds protection
- Check for environmental protections (compiler, runtime, OS, framework)
- Apply class-specific checks from bug-class-verification.md

**Key pitfall**: Analyzing vulnerable code in isolation. Conditional logic upstream may make it mathematically unreachable.

**Escalation check**: 3+ trust boundaries, async control flow, or ambiguous validation? Escalate to deep.

### Step 2: Exploitability

Prove the attacker can trigger the vulnerability.

- **Attacker control**: Prove attacker controls data reaching the vulnerable operation
- **Bounds proof**: For integer/bounds issues, create algebraic proof (see evidence-templates.md)
- **Race feasibility**: For race conditions, prove concurrent access is possible

### Step 3: Impact

Determine whether exploitation has real security consequences.

- Distinguish real impact (RCE, privesc, info disclosure) from operational robustness issues
- Distinguish primary security controls from defense-in-depth

### Step 4: PoC Sketch

Create a pseudocode PoC showing the attack path:
```
Data Flow: [Source] -> [Validation?] -> [Transform?] -> [Vulnerable Op] -> [Impact]
Attacker controls: [what input, how]
Trigger: [pseudocode showing exploit path]
```

### Step 5: Devil is Advocate Spot-Check

Answer these 7 questions. If any produces genuine uncertainty, escalate to deep.

**Against the vulnerability:**
1. Am I seeing a vulnerability because the pattern "looks dangerous" rather than because it actually is?
2. Am I incorrectly assuming attacker control over trusted data?
3. Have I rigorously proven the mathematical condition for vulnerability can occur?
4. Am I confusing defense-in-depth failure with a primary security vulnerability?
5. Am I hallucinating this vulnerability? LLMs are biased toward seeing bugs everywhere.

**For the vulnerability (false-negative protection):**
6. Am I dismissing a real vulnerability because the exploit seems complex?
7. Am I inventing mitigations I have not verified in actual source code?

### Step 6: Gate Review

Apply all six gates from gate-reviews.md and all 13 items from false-positive-patterns.md.
