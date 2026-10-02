# False Positive Indicators -- Method Clobbering

### 1. Uses Object.create(null)
Objects created with null prototype have no inherited methods. toString, valueOf, hasOwnProperty do not exist to be clobbered.

### 2. Has Key Allowlist/Blocklist
Parser filters or rejects keys matching built-in method names.

### 3. Does Not Call Methods on Parsed Objects
If the code never calls toString(), valueOf(), hasOwnProperty(), or other inherited methods on the parsed result, clobbering has no effect.

### 4. Input From Trusted Source
Keys come from trusted sources (admin config, database schema), not user input.

### 5. JSON.parse Does the Same
If the parser produces the same result as JSON.parse for the same input structure, clobbering is not a library-specific vulnerability. You need to show WHY the library is worse.

### 6. Library Already Handles This
Check if recent versions added protection. Many CSV parsers added key filtering after prior CVEs.

### 7. Crash Is Caught
If the code wraps the usage in try/catch and handles TypeError gracefully, the DoS impact is eliminated.
