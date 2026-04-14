---
name: hurl
description: >
  Hurl HTTP testing tool guide. Use this skill when writing, debugging, or running .hurl files;
  chaining HTTP requests with captures and assertions; API integration testing; CI/CD HTTP test suites;
  testing REST/GraphQL APIs; polling async jobs; CSRF token flows; file upload testing;
  generating HTML/JSON/JUnit/TAP test reports. Trigger when the user mentions hurl, .hurl files,
  HTTP testing, API testing, HTTP request chaining, response assertions, hurlfmt, or asks how to
  test APIs with plain text files. Also trigger for any task involving HTTP integration testing
  or API smoke tests, even if the user doesn't explicitly name Hurl.
---

# Hurl

Hurl is a command-line tool (Rust + libcurl) that runs HTTP requests defined in plain text `.hurl` files. It chains requests, captures values from responses, asserts outcomes, and generates test reports. Think of it as curl + a test framework in one format.

## Quick Start

A minimal `.hurl` file:

```
GET https://example.com/api/health
HTTP 200
```

Run it:

```bash
hurl health.hurl
```

A realistic example with capture and assertion:

```
POST https://api.example.com/users
Content-Type: application/json
{
    "name": "John",
    "email": "john@example.com"
}
HTTP 201
[Captures]
user_id: jsonpath "$.id"
[Asserts]
jsonpath "$.name" == "John"

###

GET https://api.example.com/users/{{user_id}}
HTTP 200
[Asserts]
jsonpath "$.email" == "john@example.com"
```

## Entry Structure

A Hurl file is a list of **entries**. Each entry = request + optional response. Entries separated by `###`.

```
GET https://example.com/a
HTTP 200

###

POST https://example.com/b
HTTP 201
```

Comments start with `#`. Escape literal `#` in header values with `\#`.

## Request

### Method and URL

```
METHOD URL
```

Methods: `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE`, `CONNECT`, `OPTIONS`, `TRACE`. Custom methods (e.g. `QUERY`) are also supported.

### Headers

```
Header-Name: Header-Value
```

### Query Parameters

```
[Query]
q: 1982
sort: name
page: 2
```

### Forms

URL-encoded:

```
[Form]
username: admin
password: secret
```

Multipart (including file upload):

```
[Multipart]
field: value
file,file: document.pdf
file2,file; type: application/json; filename: data.json: {{read_file_data}}
```

### Authentication

Basic auth:

```
[BasicAuth]
username: admin
password: {{password}}
```

AWS SigV4: use `[Options] aws-sigv4: profile` or `--aws-sigv4` CLI flag.

### Cookies

```
[Cookies]
session_id: abc123
theme: dark
```

Cookies are shared across entries in a file — `Set-Cookie` from earlier entries is available later.

### Body Types

| Type | Syntax | Auto Content-Type |
|------|--------|-------------------|
| JSON | `{...}` or `[...]` | `application/json` |
| XML | `<?xml...` | `application/xml` |
| GraphQL | `{ hero { name } }` | (set manually) |
| Multiline string | <code>```text```</code> | none |
| Oneline string | `` `text` `` | none |
| Base64 | `base64,aGVs...` | none |
| Hex | `hex,4865...;` | none |
| File | `file,data.bin;` | none |

JSON bodies integrate with templates naturally:

```json
{"name": "{{name}}", "email": "{{email}}"}
```

## Response

### Status Line

```
HTTP 200          # shorthand
HTTP/1.1 200      # with version
HTTP *            # wildcard status (accept any)
```

Status and headers in the response section are **implicit assertions** — if the response doesn't match, the entry fails.

### Explicit Assertions

```
[Asserts]
jsonpath "$.status" == "OK"
jsonpath "$.count" > 0
header "Content-Type" contains "json"
xpath "//title" == "My Page"
```

## Captures

Extract values from responses into named variables:

```
[Captures]
token: header "X-Auth-Token"
user_id: jsonpath "$.id"
csrf: xpath "string(//input[@name='_csrf']/@value)"
```

Captured variables are available in subsequent entries via `{{variable_name}}`.

Redact sensitive values from logs:

```
[Captures]
api_key: header "X-API-Key" redact
```

For all capture query types and details, see `references/assertions-predicates.md`.

## Variables and Templates

### Variable Sources (priority order)

1. CLI: `--variable name=value`
2. CLI: `--variables-file file.env`
3. Environment: `HURL_VARIABLE_name=value`
4. Per-entry: `[Options] variable: name=value`

### Built-in Functions

```
{{newUuid}}              # UUID v4
{{newDate}}              # RFC 3339 UTC date
{{getEnv "VAR_NAME"}}    # Read env var
```

### Secrets

Secrets work like variables but are redacted from stderr and reports:

```bash
hurl --secret api_key=super_secret test.hurl
# or
HURL_SECRET_api_key=super_secret hurl test.hurl
```

### Variable Types

Variables have types that affect rendering in JSON bodies:

| Type | Example | Rendered |
|------|---------|----------|
| String | `--variable name=John` | `"John"` |
| Boolean | `--variable flag=true` | `true` |
| Number | `--variable count=42` | `42` |
| Null | `--variable x=null` | `null` |

## Control Flow

### Redirects

Hurl does **not** follow redirects by default. Assert against the redirect response directly:

```
POST https://example.com/login
HTTP 302
header "Location" == "/dashboard"
```

Follow redirects per-entry: `[Options] location: true`, or globally: `--location`.

### Retry and Polling

```
[Options]
retry: 5
retry-interval: 2s
```

### Other Controls

```
[Options]
delay: 500ms     # wait before request
repeat: 3        # repeat entry N times
skip: true       # skip this entry
```

## CLI Usage

### Running Tests

```bash
# Run single file
hurl test.hurl

# Test mode (parallel, test-oriented output)
hurl --test *.hurl

# With variables
hurl --variable host=http://localhost:3000 --variable token=abc test.hurl

# Run up to entry N (1-indexed)
hurl --to-entry 3 test.hurl
```

### Reports

```bash
hurl --test --report-html ./report *.hurl    # HTML report
hurl --test --report-json ./report *.hurl    # JSON report
hurl --test --report-junit report.xml *.hurl  # JUnit XML
hurl --test --report-tap report.tap *.hurl    # TAP format
```

### Debugging

```bash
hurl --verbose test.hurl          # headers, cookies, timing (no body)
hurl --very-verbose test.hurl     # adds bodies, libcurl logs
hurl --error-format long test.hurl  # show headers+body on assert errors
hurl --output - test.hurl         # print response body to stdout
hurl --curl commands.txt test.hurl  # export as curl commands
```

### Formatting

```bash
hurlfmt file.hurl              # format and colorize hurl file
hurlfmt file.hurl --out json   # export to JSON
hurlfmt file.hurl --out hurl   # convert to hurl format
hurlfmt file.hurl --check      # check formatting
hurlfmt file.hurl --in-place   # format in-place
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | CLI parse error |
| 2 | File parse error |
| 3 | Runtime error |
| 4 | Assert error |

## Reference Files

When you need more detail on a specific topic, consult these reference files:

- **`references/syntax-reference.md`** — Complete syntax for all request sections, body types, per-entry options, and response format details
- **`references/assertions-predicates.md`** — All capture query types, all 25+ predicates with negation, all 30+ filters with chaining examples
- **`references/cli-options.md`** — Full CLI option reference, environment variables, report formats, hurlfmt, debug techniques
- **`references/patterns.md`** — Common patterns: CSRF flows, polling, GraphQL testing, file upload, chained requests, CI/CD integration, security testing

## Checklist

Before finalizing a `.hurl` file, verify:

- [ ] Each entry has explicit status assertion (`HTTP 200` or specific code)
- [ ] Sensitive values use `redact` in captures or `--secret` on CLI
- [ ] JSONPath expressions are tested (use `--verbose` to inspect actual response)
- [ ] Retry/polling entries have reasonable `retry` and `retry-interval` values
- [ ] File uses `###` to separate entries
- [ ] Variables use correct types (string vs number vs boolean) for JSON body injection
