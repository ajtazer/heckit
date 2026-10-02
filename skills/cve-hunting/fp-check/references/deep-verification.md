# Deep Verification

Full task-based verification for complex bugs.

## If Escalated from Standard

1. Review evidence gathered during standard pass -- do not repeat completed work
2. Identify which phases are already satisfied
3. Create tasks only for remaining phases
4. Preserve and reference all prior findings

## Verification Phases

```
Phase 1: Data Flow Analysis
  1.1: Map trust boundaries and trace data flow
  1.2: Research API contracts and safety guarantees (parallel)
  1.3: Environment protection analysis (parallel)
  1.4: Cross-reference analysis (parallel)

Phase 2: Exploitability Verification (blocked by Phase 1)
  2.1: Confirm attacker controls input data (parallel)
  2.2: Mathematical bounds verification (parallel)
  2.3: Race condition feasibility proof (parallel)
  2.4: Adversarial analysis (blocked by 2.1-2.3)

Phase 3: Impact Assessment (blocked by Phase 2)
  3.1: Demonstrate real security impact (parallel)
  3.2: Primary control vs defense-in-depth (parallel)

Phase 4: PoC Creation (blocked by Phase 3)
  4.1: Create pseudocode PoC with data flow diagrams
  4.2: Create executable PoC if feasible (parallel)
  4.3: Create unit test PoC if feasible (parallel)
  4.4: Negative PoC -- show exploit preconditions (parallel)
  4.5: Verify PoC demonstrates the vulnerability (blocked by 4.2-4.4)

Phase 5: Devil is Advocate (blocked by Phase 4)
  5.1: Full devil is advocate review (13 questions)

Gate Review (blocked by Phase 5)
  Evaluate all six gates before verdict
```

## Phase Requirements

### Phase 1: Data Flow Analysis
**1.1**: Map trust boundaries and trace data from source to vulnerability. Apply class-specific verification from bug-class-verification.md.
**1.2**: Check API contracts before claiming overflows.
**1.3**: Verify no compiler/runtime/OS/framework protections prevent exploitation entirely.
**1.4**: Check if similar patterns exist elsewhere and are handled safely.

### Phase 2: Exploitability Verification
**2.1**: Prove attacker controls data reaching the vulnerability.
**2.2**: Create algebraic proofs for bounds issues (see evidence-templates.md).
**2.3**: For race conditions, prove concurrent access is possible.
**2.4**: Full attack surface assessment.

### Phase 3: Impact Assessment
**3.1**: Distinguish real security impact from operational robustness issues.
**3.2**: Distinguish primary controls from defense-in-depth.

### Phase 4: PoC Creation
Always create pseudocode PoC. Executable and unit test PoCs when feasible.
Negative PoC shows what preconditions must hold.

### Phase 5: Devil is Advocate Review

13 challenges:

Against the vulnerability:
1-4. Non-vulnerability explanations, developer justification, missing context, pattern-matching bias
5-7. Insufficient validation may still prevent, trusted data assumption, mathematical proof rigor
8-9. Practical exploitability, defense-in-depth confusion
10-11. Environmental protections, LLM hallucination check

For the vulnerability:
12. Am I dismissing because exploit seems complex?
13. Am I inventing mitigations not verified in source code?

## Gate Review

Apply six gates from gate-reviews.md to reach verdict.
