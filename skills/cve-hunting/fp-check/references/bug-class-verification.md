# Bug-Class-Specific Verification

Different bug classes require different verification approaches. Apply these IN ADDITION to generic phases.

## Memory Corruption

**Language safety check first:** Memory corruption in safe Rust, Go (without unsafe), or managed languages (Java, C#, Python) is almost always a false positive.

Verify: What gets corrupted? What is the corruption size? Is it a useful exploitation primitive? What allocator is in use?

## Logic Bugs

Verify against specification/RFC, not just code. Map all state transitions. Check ALL auth paths, not just the broken one. Logic bugs pass every bounds check -- do not let clean static analysis convince you it is false positive.

## Race Conditions

What is the actual race window? Can attacker widen it? Verify the threading model. Check synchronization primitives. For TOCTOU: can attacker control the path between check and use?

## Integer Issues

What are exact integer types and ranges at every point? Signed (UB in C/C++) vs unsigned (defined wraparound)? Trace through all casts and promotions. Is the resulting value actually used dangerously?

## Crypto Weaknesses

Check parameters against current standards. Verify randomness sources. For nonce reuse: prove it can happen in practice. For timing: is the code reachable by an attacker who can measure timing?

## Injection

Trace from entry point to sink. Check framework automatic escaping. For XSS: what context (HTML body, attribute, JS, URL)? For path traversal: is path canonicalized before access check?

## Information Disclosure

What specific data leaks? Is it useful to an attacker? Prove memory is actually uninitialized. Does error reach the attacker or only server logs?

## Denial of Service

What is the resource consumption ratio? Can resources be reclaimed? Prove worst-case input actually triggers worst-case behavior. Does service restart automatically?

## Deserialization

Does attacker control serialized data? Does a usable gadget chain exist? Are there type restrictions or allowlists?
