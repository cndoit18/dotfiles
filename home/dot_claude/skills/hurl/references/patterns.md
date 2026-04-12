# Common Hurl Patterns

## Table of Contents

- [CSRF Token Flow](#csrf-token-flow)
- [REST API Testing with Polling](#rest-api-testing-with-polling)
- [GraphQL Testing](#graphql-testing)
- [File Upload](#file-upload)
- [Chained Requests (Login → Action)](#chained-requests-login--action)
- [Environment-Based Configuration](#environment-based-configuration)
- [CI/CD Integration](#cicd-integration)
- [Security Testing](#security-testing)
- [HTML Page Testing](#html-page-testing)

## CSRF Token Flow

Extract CSRF token from a form page, then submit with the token:

```
GET https://example.com/form
HTTP 200
[Captures]
csrf_token: xpath "string(//input[@name='_csrf']/@value)"

###

POST https://example.com/submit
[Form]
_csrf: {{csrf_token}}
data: value
HTTP 302
```

## REST API Testing with Polling

Submit a job, then poll until completion:

```
POST https://api.example.com/jobs
Content-Type: application/json
{
    "type": "export",
    "format": "csv"
}
HTTP 201
[Captures]
job_id: jsonpath "$.id"

###

GET https://api.example.com/jobs/{{job_id}}
[Options]
retry: 5
retry-interval: 2s
HTTP 200
[Asserts]
jsonpath "$.status" == "COMPLETED"
jsonpath "$.download_url" startsWith "https://"
```

## GraphQL Testing

### Query

```
POST https://api.example.com/graphql
Content-Type: application/json
{
    "query": "{ hero { name friends { name } } }"
}
HTTP 200
[Asserts]
jsonpath "$.data.hero.name" == "Luke Skywalker"
jsonpath "$.data.hero.friends" isList
jsonpath "$.data.hero.friends" count > 0
```

### Mutation with Variables

```
POST https://api.example.com/graphql
Content-Type: application/json
{
    "query": "mutation CreateUser($name: String!, $email: String!) { createUser(name: $name, email: $email) { id name } }",
    "variables": {
        "name": "{{name}}",
        "email": "{{email}}"
    }
}
HTTP 200
[Captures]
user_id: jsonpath "$.data.createUser.id"
[Asserts]
jsonpath "$.data.createUser.name" == "{{name}}"
```

## File Upload

### Simple File Upload

```
POST https://api.example.com/upload
[Multipart]
file,file: document.pdf
HTTP 200
```

### Upload with Metadata

```
POST https://api.example.com/upload
[Multipart]
file,file; type: application/pdf; filename: report.pdf: {{read_file_data}}
description: Q4 Financial Report
HTTP 201
[Captures]
file_id: jsonpath "$.id"
[Asserts]
jsonpath "$.size" > 0
```

## Chained Requests (Login → Action)

Full authentication flow:

```
# Step 1: Login and capture token
POST https://api.example.com/auth/login
Content-Type: application/json
{
    "email": "{{email}}",
    "password": "{{password}}"
}
HTTP 200
[Captures]
token: jsonpath "$.access_token"
user_id: jsonpath "$.user.id"

###

# Step 2: Use token for authenticated request
GET https://api.example.com/users/{{user_id}}/profile
Authorization: Bearer {{token}}
HTTP 200
[Asserts]
jsonpath "$.email" == "{{email}}"

###

# Step 3: Modify resource
PATCH https://api.example.com/users/{{user_id}}
Authorization: Bearer {{token}}
Content-Type: application/json
{
    "bio": "Updated bio"
}
HTTP 200
[Asserts]
jsonpath "$.bio" == "Updated bio"
```

## Environment-Based Configuration

Use variables for environment-specific URLs:

```
GET {{base_url}}/api/health
HTTP 200
```

```bash
# Development
hurl --variable base_url=http://localhost:3000 health.hurl

# Staging
hurl --variable base_url=https://staging.example.com health.hurl

# Production
hurl --variable base_url=https://api.example.com health.hurl
```

Or use a variables file (`env.env`):

```
base_url=http://localhost:3000
email=test@example.com
password=secret
```

```bash
hurl --variables-file env.env --test *.hurl
```

## CI/CD Integration

### GitHub Actions

```yaml
name: API Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Hurl
        run: |
          curl -LO https://github.com/Orange-OpenSource/hurl/releases/latest/download/hurl_4.3.0_amd64.deb
          sudo dpkg -i hurl_4.3.0_amd64.deb

      - name: Start API server
        run: |
          docker compose up -d
          sleep 5

      - name: Run API tests
        run: |
          hurl --test --variable base_url=http://localhost:3000 \
            --report-html ./report \
            tests/*.hurl

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: hurl-report
          path: ./report
```

### Docker Pattern

```bash
# Start service
docker run -d --name myapp -p 3000:3000 myapp:latest

# Wait for healthy response
hurl --retry 5 --retry-interval 2s http://localhost:3000/health

# Run full test suite
hurl --test --variable base_url=http://localhost:3000 \
  --report-html ./report \
  tests/*.hurl

# Cleanup
docker stop myapp && docker rm myapp
```

### GitLab CI

```yaml
test:
  image: debian:bookworm
  services:
    - name: myapp:latest
      alias: api
  before_script:
    - apt-get update && apt-get install -y curl
    - curl -LO https://github.com/Orange-OpenSource/hurl/releases/latest/download/hurl_4.3.0_amd64.deb
    - dpkg -i hurl_4.3.0_amd64.deb
  script:
    - hurl --test --variable base_url=http://api:3000 tests/*.hurl
```

## Security Testing

### CSRF Protection Check

```
# POST without CSRF token should be rejected
POST https://example.com/submit
[Form]
data: malicious value
HTTP 403
```

### HTML Comment Leak Detection

```
GET https://example.com/page
HTTP 200
[Asserts]
xpath "//comment" not exists
```

### Invalid Input Handling

```
POST https://api.example.com/users
Content-Type: application/json
{
    "username": "ab",
    "email": "not-an-email"
}
HTTP 422
[Asserts]
jsonpath "$.errors" isList
jsonpath "$.errors" count > 0
```

### Redirect Target Validation

```
POST https://example.com/action
HTTP 302
[Asserts]
header "Location" startsWith "https://example.com/"
header "Location" not contains "evil.com"
```

### Bypass Client-Side Validation

```
POST https://api.example.com/orders
Content-Type: application/json
{
    "quantity": -1,
    "price": 0
}
HTTP 422
[Asserts]
jsonpath "$.error" exists
```

## HTML Page Testing

Assert HTML structure and content:

```
GET https://example.com/products
HTTP 200
[Asserts]
xpath "//title" == "Products - My Store"
xpath "//div[@class='product']" count >= 1
xpath "//a[@class='cart']" exists
xpath "//script[contains(@src,'analytics')]" not exists
header "Content-Security-Policy" exists
```
