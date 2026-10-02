# Severity Escalation Through Vulnerability Chaining

How to combine findings for maximum impact. A MEDIUM finding + another MEDIUM finding
can equal a CRITICAL chain. Always ask: "Can this be made worse?"

This is a security research knowledge base document for educational purposes.

---

## Chain Reference Table

| Finding A | + Finding B | = Chain Result | CVSS Impact |
|-----------|-------------|----------------|-------------|
| Path traversal (read) | File write capability | Arbitrary file overwrite -> RCE | MEDIUM -> CRITICAL |
| Info disclosure | SSRF | Credential theft from cloud metadata | LOW -> HIGH |
| Auth bypass | Any write operation | Privilege escalation to admin | MEDIUM -> CRITICAL |
| SSRF | Cloud metadata endpoint | Full cloud account takeover | MEDIUM -> CRITICAL |
| XSS (stored) | CSRF token accessible | Account takeover | MEDIUM -> HIGH |
| Prototype pollution | Gadget in dependency | RCE via gadget chain | MEDIUM -> CRITICAL |
| ReDoS | Auth bypass | Unauthenticated DoS | LOW -> MEDIUM |
| Path traversal | Symlink following | Arbitrary file read beyond jail | MEDIUM -> HIGH |
| IDOR | Sensitive data endpoint | Mass data extraction | LOW -> HIGH |
| File upload | Path traversal | Write webshell to web root | MEDIUM -> CRITICAL |
| XXE | SSRF via entity | Internal network scanning | MEDIUM -> HIGH |
| Race condition | Balance/counter update | Financial manipulation | LOW -> HIGH |

---

## Detailed Chain Playbooks

### Chain 1: Path Traversal + File Write = RCE

**Finding A**: Path traversal allowing reading files outside intended directory
**Finding B**: Write operation that accepts user-controlled file paths

**Chain Logic**:
1. Path traversal confirms you can escape the intended directory
2. File write lets you place arbitrary content at arbitrary paths
3. Overwrite targets for RCE:
   - Application source files (if Node.js/Python — code reloads on change)
   - SSH authorized_keys (`~/.ssh/authorized_keys`)
   - Cron jobs (`/etc/cron.d/`, `~/.config/cron/`)
   - Shell profiles (`~/.bashrc`, `~/.zshrc`)
   - Package manager configs that run scripts on next install

**When it applies**: Archive extraction libraries, file upload handlers, static file servers with write APIs

**CVSS escalation**: AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H = 9.8 CRITICAL

**Example scenario**: A ZIP extraction library has path traversal (Zip Slip). The extracted files are written to disk. An attacker crafts a ZIP with `../../.ssh/authorized_keys` to write their SSH public key.

---

### Chain 2: Information Disclosure + SSRF = Credential Theft

**Finding A**: Information disclosure revealing internal URLs, API keys, or configuration
**Finding B**: SSRF allowing requests to arbitrary internal URLs

**Chain Logic**:
1. Info disclosure reveals internal service URLs or network topology
2. SSRF reaches those internal services
3. Target the cloud metadata endpoint (169.254.169.254) for:
   - AWS: IAM role credentials, instance identity
   - GCP: Service account tokens, project metadata
   - Azure: Managed identity tokens

**When it applies**: Webhook handlers, URL preview generators, import-from-URL features

**CVSS escalation**: From LOW (info disclosure alone) to HIGH/CRITICAL (credential theft)

**Example scenario**: Error messages reveal internal Kubernetes service URLs. SSRF in a URL preview feature allows requesting `http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token` to steal GCP credentials.

---

### Chain 3: Auth Bypass + Write Operation = Privilege Escalation

**Finding A**: Authentication bypass on specific endpoint(s)
**Finding B**: Write/modify operation accessible through bypassed auth

**Chain Logic**:
1. Auth bypass gives unauthenticated access to a protected endpoint
2. If that endpoint has write capabilities, you can:
   - Create admin accounts
   - Modify user permissions
   - Change application configuration
   - Install plugins/extensions

**When it applies**: Admin panels, API gateways, dashboard applications

**CVSS escalation**: MEDIUM (auth bypass to read-only) -> CRITICAL (auth bypass to admin write)

**Example scenario**: Dashboard application has a missing auth check on its API endpoint. The API allows creating new admin users. Chain: unauthenticated request -> create admin account -> full application control.

---

### Chain 4: SSRF + Cloud Metadata = Full Account Takeover

**Finding A**: SSRF allowing requests to arbitrary URLs
**Finding B**: Cloud environment with metadata endpoint accessible

**Chain Logic**:
1. SSRF to the metadata endpoint (169.254.169.254)
2. Retrieve temporary credentials for the instance's IAM role
3. Use those credentials to access cloud resources: S3 buckets, databases, secrets manager
4. If the IAM role has broad permissions, this is full account takeover

**When it applies**: Any application running on cloud infrastructure with SSRF

**CVSS escalation**: MEDIUM (SSRF alone) -> CRITICAL (full cloud account)

**Key metadata endpoints**:
- AWS: `http://169.254.169.254/latest/meta-data/iam/security-credentials/`
- GCP: `http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token` (requires header: `Metadata-Flavor: Google`)
- Azure: `http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/` (requires header: `Metadata: true`)

---

### Chain 5: XSS + Session Access = Account Takeover

**Finding A**: Stored XSS in a shared context (comments, profiles, shared documents)
**Finding B**: Session tokens/CSRF tokens accessible to JavaScript

**Chain Logic**:
1. Stored XSS persists malicious JavaScript in the application
2. When another user views the content, the script executes in their session
3. Script accesses: cookies (if not HttpOnly), localStorage tokens, CSRF tokens
4. Script performs privileged actions or exfiltrates credentials

**When it applies**: Multi-user applications with user-generated content

**CVSS escalation**: MEDIUM (XSS alone) -> HIGH (account takeover via session theft)

**Barriers to check**:
- HttpOnly cookies: prevent JavaScript access to session cookies
- CSP with nonce: prevents inline script execution
- SameSite cookies: prevents CSRF via the stolen session
- If all three are present, XSS impact is significantly reduced

---

### Chain 6: Prototype Pollution + Gadget Chain = RCE

**Finding A**: Prototype pollution allowing setting properties on Object.prototype
**Finding B**: A "gadget" — code that reads from Object.prototype and performs dangerous operations

**Chain Logic**:
1. Prototype pollution sets a property on Object.prototype
2. Some code downstream reads that property (often from an options object with no explicit default)
3. The gadget uses the polluted value in a dangerous operation (shell command, template rendering, etc.)

**When it applies**: Complex applications with many dependencies (gadgets are often in dependencies)

**CVSS escalation**: MEDIUM (pollution alone has limited impact) -> CRITICAL (RCE via gadget)

**Known gadget patterns**:
- `shell` property: if code checks `options.shell` and it's truthy, enables shell mode in process spawning
- `env` property: polluted environment variables passed to child processes
- Template options: `outputFunctionName` in EJS, `compileDebug` in Pug
- `constructor.prototype` traversal to reach Function constructor

**Important**: Without a gadget, prototype pollution alone has ~50% acceptance. WITH a gadget, it's ~90%.

---

### Chain 7: File Upload + Path Traversal = Webshell

**Finding A**: File upload accepting arbitrary content types
**Finding B**: Path traversal in the upload destination

**Chain Logic**:
1. Upload a file with executable content (PHP, JSP, ASPX, or server-side JS)
2. Path traversal places it in the web-accessible directory
3. Navigate to the uploaded file URL to execute code

**When it applies**: Applications with file upload features and server-side rendering

**CVSS escalation**: MEDIUM (upload alone) -> CRITICAL (RCE via webshell)

**Considerations**:
- Check if uploaded files are served with correct MIME types
- Check if the web server executes files based on extension
- Check if there's a separate static file server (CDN/S3) that doesn't execute code
- Modern frameworks often serve uploads from object storage, not the web root

---

### Chain 8: XXE + SSRF via External Entity = Internal Scanning

**Finding A**: XXE (XML External Entity) allowing entity definitions
**Finding B**: External entity fetches arbitrary URLs

**Chain Logic**:
1. XXE allows defining external entities
2. Entity URLs can point to internal network addresses
3. Based on response time/size differences, map the internal network
4. Target internal services: databases, admin panels, metadata endpoints

**When it applies**: XML/SVG/DOCX/XLSX parsers, SAML implementations

**CVSS escalation**: MEDIUM (XXE alone = file read) -> HIGH (internal network access)

---

## Chaining Methodology

### Step 1: Catalog All Findings
Before trying to chain, list every finding — even LOW and INFORMATIONAL ones.

### Step 2: Map Attack Surface
For each finding, identify:
- What can the attacker READ? (info disclosure)
- What can the attacker WRITE? (file write, database modification)
- What can the attacker REACH? (SSRF, internal network)
- What can the attacker BYPASS? (auth, validation)

### Step 3: Connect the Dots
Ask for each pair of findings:
- Does Finding A enable or enhance Finding B?
- Does the output of Finding A become input for Finding B?
- Does bypassing Control A expose Attack Surface B?

### Step 4: Calculate Combined CVSS
The chain's CVSS should reflect the FINAL impact, not the individual findings.
- Scope change (S:C) is more likely in chains — a vulnerability in component A affects component B
- Attack complexity (AC:L) may increase if chaining requires specific conditions

### Step 5: Report as a Chain
In your report:
- Describe each individual finding
- Explain the chain logic step by step
- Provide a single PoC that demonstrates the full chain
- Calculate CVSS for the combined impact
- Reference each CWE individually

---

## When NOT to Chain

- Don't chain findings that require different privilege levels (admin + unauthenticated)
- Don't chain findings that require contradictory conditions
- Don't chain theoretical findings — each link must be demonstrated
- Don't claim a chain if the individual findings aren't confirmed first
- Don't inflate severity through unrealistic chains — reviewers will call it out
