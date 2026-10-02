# False Positive Indicators -- Recursion DoS

### 1. Has maxDepth Configuration
Library accepts and enforces a depth limit parameter.

### 2. Iterative Implementation
Uses explicit stack/queue instead of call stack recursion. Cannot stack overflow.

### 3. Circular Reference Detection
Library detects and breaks circular references (WeakSet/Set tracking). Prevents infinite recursion but does not prevent deep linear nesting.

### 4. Input Size Bounded
Framework limits input size (e.g., 1MB body limit) which naturally limits nesting depth. Calculate max possible depth from max input size.

### 5. RangeError Caught by Library
Library wraps recursive calls in try/catch and handles RangeError gracefully. Verify the catch block exists and handles the error properly.

### 6. Native JSON.parse/JSON.stringify
Native implementations have platform-level limits and handle edge cases. Generally safe, but custom revivers/replacers may add recursion.

### 7. Tail-Call Optimized (Rare)
Some recursive functions use tail-call optimization, preventing stack growth. Very rare in JavaScript (only in strict mode, Safari).
