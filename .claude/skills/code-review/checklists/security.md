# Security Checklist

Severity: **CRITICAL**

## OWASP Top 10

### 1. Injection (SQL, NoSQL, Command)

- [ ] Are queries parameterized?
- [ ] Is user input sanitized before use in queries?
- [ ] Are ORMs used safely (no raw query with string concatenation)?
- [ ] Is user input passed to shell commands or system calls?

### 2. Broken Authentication

- [ ] Are passwords hashed with strong algorithms (bcrypt, argon2)?
- [ ] Is JWT properly validated (algorithm, expiration, signature)?
- [ ] Are sessions managed securely (rotation, expiration, secure flags)?
- [ ] Is MFA available for sensitive operations?
- [ ] Is brute-force protection in place (rate limiting, account lockout)?

### 3. Sensitive Data Exposure

- [ ] Is HTTPS enforced for all communication?
- [ ] Are secrets stored in environment variables or secret manager (not in code)?
- [ ] Is PII encrypted at rest?
- [ ] Are logs sanitized (no credentials, tokens, or PII)?

### 4. XML External Entities (XXE)

- [ ] Are XML parsers configured to disable external entity processing?
- [ ] Is DTD processing disabled?

### 5. Broken Access Control

- [ ] Is authorization checked on every route/endpoint?
- [ ] Are object references indirect (no direct ID exposure without authz)?
- [ ] Is CORS configured to allow only trusted origins?

### 6. Security Misconfiguration

- [ ] Are default credentials changed?
- [ ] Is error handling secure (no stack traces or internal details exposed)?
- [ ] Are security headers set (CSP, X-Frame-Options, HSTS, etc.)?
- [ ] Is debug mode disabled in production?

### 7. Cross-Site Scripting (XSS)

- [ ] Is output escaped/sanitized before rendering?
- [ ] Is Content-Security-Policy set?
- [ ] Are frameworks configured to escape by default?

### 8. Insecure Deserialization

- [ ] Is user input deserialized safely?
- [ ] Are deserialization libraries up to date?

### 9. Using Components with Known Vulnerabilities

- [ ] Are all dependencies up to date?
- [ ] Is dependency audit clean (no known CVEs)?

### 10. Insufficient Logging & Monitoring

- [ ] Are security events logged (failed logins, permission denials)?
- [ ] Are logs monitored and alerts configured?

## Vulnerability Patterns

### Hardcoded Secrets (CRITICAL)

API keys, passwords, tokens, or connection strings embedded in source code. Must use environment variables or a secret manager. Validate that required secrets are present at startup.

### SQL Injection (CRITICAL)

User input concatenated into SQL queries. Must use parameterized queries or ORM safe methods.

### Command Injection (CRITICAL)

User input passed to shell commands or system calls. Must use safe APIs or libraries instead of spawning shell processes.

### Path Traversal (CRITICAL)

User-controlled file paths without sanitization. Must canonicalize paths and restrict to allowed directories.

### Insecure Authentication (CRITICAL)

Plaintext password comparison, weak hashing algorithms, or missing brute-force protection. Must use strong hashing (bcrypt, argon2) and rate limiting on auth endpoints.

### Insufficient Authorization (CRITICAL)

Missing or bypassable access control checks. Every protected resource must verify the requester has permission.

### Race Conditions (CRITICAL)

Non-atomic read-then-write operations on shared resources. Must use database transactions with row-level locking or other concurrency controls.

### Cross-Site Scripting — XSS (HIGH)

Unescaped user input rendered in HTML output. Must use context-aware output encoding or sanitization libraries.

### Server-Side Request Forgery — SSRF (HIGH)

User-controlled URLs fetched by the server without validation. Must validate and whitelist allowed domains.

### Insufficient Rate Limiting (HIGH)

Endpoints without request throttling, especially for authentication, financial operations, and resource-intensive queries.

### Logging Sensitive Data (MEDIUM)

Credentials, tokens, PII, or other sensitive data written to logs. Must sanitize or redact sensitive fields before logging.

## Common False Positives

Not every finding is a vulnerability. Always verify context before flagging:

- Environment variables in `.env.example` (not actual secrets)
- Test credentials in test files (if clearly marked as test data)
- Public API keys that are intended to be public
- SHA256/MD5 used for checksums, not password hashing
