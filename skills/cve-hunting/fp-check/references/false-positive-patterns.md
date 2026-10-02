# False Positive Patterns -- Lessons Learned

Apply ALL items to EACH potential bug during verification.

## Checklist

### 1. Trace Full Validation Chain
Do not analyze isolated code snippets. Trace backwards to find ALL validation preceding dangerous operations.

### 1a. Map Complete Conditional Logic Flow
Vulnerable-looking code may be unreachable due to conditional logic creating mathematical guarantees.

### 2. Identify Defensive Programming Patterns
Distinguish actual vulnerabilities from defensive assertions/validations.

### 3. Confirm Exploitable Data Paths
Only report vulnerabilities with CONFIRMED exploitable data flow paths.

### 4. Understand Data Source Context
Distinguish trust levels: API return values, compile-time constants, and network data have different risk profiles.

### 5. Analyze Bounds Validation Logic
Look for mathematical relationships between validation checks and subsequent operations.

### 6. Verify TOCTOU Claims
Prove the checked value can change between check and use.

### 7. Understand API Contract and Trust Boundaries
Some APIs have built-in bounds protection regardless of input parameters.

### 8. Distinguish Internal Storage from External Input
Internal storage set by trusted components is not attacker-controlled.

### 9. Do Not Confuse Pattern Recognition with Analysis
Code patterns that "look vulnerable" may be safely implemented due to context.

### 10. Verify Concurrent Access is Actually Possible
Single-threaded initialization contexts cannot have race conditions.

### 11. Assess Real vs Theoretical Security Impact
Focus on actual security impact, not operational robustness issues.

### 12. Understand Defense-in-Depth vs Primary Controls
Failure of defense-in-depth is not always a vulnerability if primary protections exist.

### 13. Apply the Checklist Rigorously, Not Superficially
Work through ALL items for EVERY potential vulnerability before concluding.

## Red Flags for False Positives

### Pattern-Based
- Reporting vulnerabilities in validation code itself
- Claiming TOCTOU without proving the value can change
- Ignoring preceding validation logic
- Assuming network data reaches operations without tracing

### Context-Blind
- Analyzing snippets without understanding broader system design
- Ignoring architectural guarantees
- Missing that "vulnerable" code is unreachable
- Reporting issues in test/debug-only code paths

### Mathematical
- Reporting integer underflow without proving the condition can occur
- Claiming buffer overflow when bounds are mathematically guaranteed
- Missing conditional logic creating mathematical impossibility

### API Contract
- Claiming overflows when APIs have built-in bounds checking
- Missing that return values are already validated by API contract
