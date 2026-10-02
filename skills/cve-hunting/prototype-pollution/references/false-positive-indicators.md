# False Positive Indicators -- Prototype Pollution

### 1. Library Filters Dangerous Keys
Checks for and rejects `__proto__`, `constructor`, `prototype` keys.

### 2. Uses Object.create(null)
Target objects have null prototype -- no prototype chain to pollute.

### 3. Input From Trusted Source
Object keys come from config/database, not user input.

### 4. Shallow Operation Only
Uses Object.assign or spread operator -- no deep traversal.

### 5. JSON.parse Handles __proto__
Modern Node.js (v21+) and V8 versions handle `__proto__` in JSON.parse safely. The key is set as a regular property, not a prototype setter.

### 6. No Demonstrated Impact
Prototype pollution without a demonstrated impact (DoS, auth bypass, RCE via gadget chain) is often rejected. JSON.parse can do the same thing -- show why the library-specific pollution is worse.

### 7. Already Patched
Check if the library already fixed prototype pollution in current version.
