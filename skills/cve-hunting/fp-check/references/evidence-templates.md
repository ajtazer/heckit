# Evidence Templates

## Data Flow Documentation

```
Bug #N Data Flow Analysis
Source: [exact location] -- Trust Level: [trusted/untrusted]
Path: Source -> Validation1[file:line] -> Transform[file:line] -> Vulnerability[file:line]
Validation Points:
  - Check1: [condition] at [file:line] -- [passes/fails/bypassed]
  - Check2: [condition] at [file:line] -- [passes/fails/bypassed]
```

## Mathematical Bounds Proof

```
Bug #N Mathematical Analysis
Claim: Operation X is vulnerable to [overflow/underflow/bounds violation]
Given Constraints: [list all validation conditions]

Algebraic Proof:
1. [first constraint from validation]
2. [constant or known value]
3. [derived inequality]
...
N. Therefore: [vulnerability confirmed/debunked] (Q.E.D.)
```

Example:
```
Given: validation ensures (input_size >= MIN_SIZE)
Given: MIN_SIZE = 16, header_size = 8
1. input_size >= 16                   (from validation)
2. input_size - 8 >= 8               (subtract header_size)
3. Therefore: underflow impossible    (Q.E.D.)
```

## Attacker Control Analysis

```
Bug #N Attacker Control Analysis
Input Vector: [how attacker provides input]
Control Level: [full/partial/none]
Constraints: [limits on attacker input]
Reachability: [can attacker-controlled data reach vulnerable operation?]
```

## PoC -- Pseudocode with Data Flow Diagram

```
PoC for Bug #N: [Brief Description]

[External Input] -> [Validation Point] -> [Processing] -> [Vulnerable Operation]
     |                    |                   |                    |
  Attacker           (May be bypassed)    (Transforms)        (Unsafe op)

PSEUDOCODE:
function vulnerable_operation(user_data):
    validation_result = weak_validation(user_data)
    processed_data = transform_data(user_data)
    unsafe_operation(processed_data)
```

## Devil is Advocate Review

```
Bug #N Devil is Advocate Review
Vulnerability Claim: [brief description]

1-5. [Challenges arguing AGAINST the vulnerability]
6-7. [Challenges arguing FOR the vulnerability]

Final Assessment: [confirmed/debunked with reasoning]
```
