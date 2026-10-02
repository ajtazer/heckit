# Auth Mechanism Patterns by Framework

## Express.js (Node.js)
```js
// Middleware-based auth
app.use('/admin', requireAdmin);           // Route-level
app.get('/api/data', isAuth, handler);      // Per-route
router.use(authMiddleware);                 // Router-level

// Common auth libraries
passport.authenticate('jwt')               // Passport.js
expressJwt({ secret })                     // express-jwt
```

## Django (Python)
```python
@login_required                            # View decorator
@permission_required('app.view_model')     # Permission decorator
class MyView(LoginRequiredMixin, View):    # Class-based mixin

# DRF
permission_classes = [IsAuthenticated]     # View permission
authentication_classes = [TokenAuth]       # Auth backend
```

## Flask (Python)
```python
@login_required                            # Flask-Login
@jwt_required()                            # Flask-JWT-Extended
@roles_required('admin')                   # Flask-Security
```

## Go
```go
r.Use(AuthMiddleware)                      // Router middleware
r.Group(func(r chi.Router) {
    r.Use(RequireAuth)                     // Group middleware
    r.Get("/protected", handler)
})
```

## Rails (Ruby)
```ruby
before_action :authenticate_user!          # Devise
before_action :authorize_admin, only: [:destroy]
skip_before_action :verify_authenticity_token  # CSRF bypass (red flag)
```
