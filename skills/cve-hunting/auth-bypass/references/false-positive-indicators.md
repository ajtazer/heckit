# False Positive Indicators -- Auth Bypass

### 1. Auth Checked at Different Layer
Auth is enforced by reverse proxy, API gateway, or framework middleware at a higher level than the route definition.

### 2. Route is Intentionally Public
Route serves public content (landing pages, health checks, static assets). Verify by checking documentation or comments.

### 3. Auth Bypass Requires Admin Access Already
If triggering the bypass requires admin-level access, the "bypass" does not escalate privileges.

### 4. Framework Handles Auth Globally
Some frameworks apply auth to all routes by default, with explicit opt-out for public routes. Check the global configuration.

### 5. JWT Library Validates Algorithm
Modern JWT libraries (jsonwebtoken >= 9.0, PyJWT >= 2.0) validate the algorithm by default or require explicit algorithm specification. Check library version.

### 6. IDOR With No Sensitive Data
The endpoint returns public/non-sensitive data. IDOR to read public profiles is not a vulnerability.
