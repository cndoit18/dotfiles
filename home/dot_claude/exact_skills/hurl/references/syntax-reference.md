# Hurl Syntax Reference

## Table of Contents

- [Request Sections](#request-sections)
- [Body Types](#body-types)
- [Per-Entry Options](#per-entry-options)
- [Response Format](#response-format)
- [Special Characters](#special-characters)

## Request Sections

### Section Aliases

Some sections have alternative names that can be used interchangeably:

| Short Form | Alias |
|------------|-------|
| `[Query]` | `[QueryStringParams]` |
| `[Form]` | `[FormParams]` |
| `[Multipart]` | `[MultipartFormData]` |

### Headers

```
Header-Name: Header-Value
X-Custom: some value
```

Multiple headers with the same name are allowed. To include a literal `#` in a header value, escape it: `\#`.

### [Query]

```
[Query]
q: 1982
sort: name
page: 2
filter: active status
```

Values can include spaces — no quoting needed.

### [Form]

URL-encoded form data (`Content-Type: application/x-www-form-urlencoded`):

```
[Form]
username: admin
password: secret
remember: true
```

### [Multipart]

Multipart form data (`Content-Type: multipart/form-data`):

```
[Multipart]
field: value
file,file: data.bin
file2,file; type: application/json; filename: data.json: {{read_file_data}}
```

File fields use the format: `fieldname,file; type: MIME; filename: NAME: CONTENT_OR_VARIABLE`

### [Cookies]

Explicit cookies sent with the request:

```
[Cookies]
session_id: abc123
theme: dark
tracking: enabled
```

### [BasicAuth]

HTTP Basic Authentication:

```
[BasicAuth]
username: admin
password: {{password}}
```

Variables in passwords are resolved at runtime.

### [Options]

Per-entry options that override CLI defaults. See [Per-Entry Options](#per-entry-options) below.

## Body Types

### JSON Body

Auto-detected when body starts with `{` or `[`. Sets `Content-Type: application/json` automatically.

```json
{
    "name": "John",
    "age": 30,
    "tags": ["admin", "user"]
}
```

Variables render with correct types:
```json
{"count": {{count}}, "active": {{flag}}, "name": "{{name}}"}
```

### XML Body

Auto-detected when body starts with `<?xml` or `<`. Sets `Content-Type: application/xml`.

```xml
<?xml version="1.0"?>
<root>
    <name>John</name>
</root>
```

### GraphQL Query

Use triple backticks with `graphql` marker, or just write the query directly. Set Content-Type header manually.

```
POST https://api.example.com/graphql
Content-Type: application/json
{
    "hero": {
        "name": "Luke Skywalker"
    }
}
```

For query language syntax:

```
POST https://api.example.com/graphql
Content-Type: application/graphql
```
```graphql
{
    hero {
        name
        friends {
            name
        }
    }
}
```

### Multiline String

Triple backticks for multi-line content:

```
```
line one
line two
line three
```
```

Useful for XML, HTML, or other text bodies without auto-detection.

### Oneline String

Single backticks for single-line content:

```
`single line content`
```

### Base64 Body

Raw base64-encoded content:

```
base64,aGVsbG8gd29ybGQ=
```

### Hex Body

Hex-encoded bytes (semicolon-terminated segments):

```
hex,48656c6c6f;
```

### File Body

Reference external file content:

```
file,data.bin;
```

## Per-Entry Options

All options available in `[Options]` section:

| Option | Type | Description |
|--------|------|-------------|
| `aws-sigv4` | string | AWS Signature V4 profile |
| `cacert` | string | CA certificate bundle file |
| `cert` | string | Client certificate file |
| `key` | string | Private key file |
| `compressed` | boolean | Request compressed response |
| `connect-to` | string | `host:port:target` |
| `connect-timeout` | duration | Connection timeout (e.g. `10s`, `1m`) |
| `delay` | duration | Wait before request (e.g. `500ms`, `2s`) |
| `location` | boolean | Follow redirects |
| `location-trusted` | boolean | Follow redirects with credentials |
| `header` | string | Additional header (`"Name: Value"`) |
| `http1.0` | boolean | Use HTTP/1.0 |
| `http1.1` | boolean | Use HTTP/1.1 |
| `http2` | boolean | Use HTTP/2 |
| `http3` | boolean | Use HTTP/3 |
| `insecure` | boolean | Skip TLS verification |
| `ipv4` | boolean | Resolve to IPv4 only |
| `ipv6` | boolean | Resolve to IPv6 only |
| `limit-rate` | integer | Limit transfer rate in bytes/sec (e.g. `32000`) |
| `max-redirs` | number | Maximum redirects |
| `max-time` | duration | Max time per request (e.g. `30s`, `1m`) |
| `netrc` | boolean | Use .netrc |
| `netrc-file` | string | Specify .netrc file |
| `netrc-optional` | boolean | Optional .netrc |
| `output` | string | Output response body to file |
| `path-as-is` | boolean | No URL normalization |
| `pinnedpubkey` | string | Public key pinning (SHA-256 hash) |
| `proxy` | string | Proxy URL |
| `resolve` | string | Custom DNS: `host:port:addr` |
| `repeat` | number | Repeat entry N times |
| `retry` | number | Retry count |
| `retry-interval` | duration | Retry interval (e.g. `2s`) |
| `skip` | boolean | Skip this entry |
| `unix-socket` | string | Unix domain socket path |
| `user` | string | `user:password` basic auth |
| `variable` | string | `name=value` set variable (persists to subsequent entries, unlike other options) |
| `verbose` | boolean | Verbose output for this entry |
| `very-verbose` | boolean | Very verbose output for this entry |

Duration format: number + unit (`ms`, `s`, `m`). Example: `500ms`, `2s`, `1m`.

## Response Format

### Status Line Variants

```
HTTP 200            # shorthand (any version)
HTTP/1.0 200        # HTTP/1.0
HTTP/1.1 200        # HTTP/1.1
HTTP/2 200          # HTTP/2
HTTP *              # wildcard (accept any status)
```

### Response Headers

Headers in the response section are implicit assertions:

```
HTTP 200
Content-Type: application/json
X-Custom: value
```

### Response Body

Response body in the entry is used for assertion/capture comparison. Body compression (gzip, deflate, brotli) is handled automatically.

### Cookie Attributes

Access cookie attributes in captures/assertions:

```
cookie "name[Expires]"
cookie "name[Max-Age]"
cookie "name[Domain]"
cookie "name[Path]"
cookie "name[Secure]"
cookie "name[HttpOnly]"
cookie "name[SameSite]"
```

### Certificate Attributes

Access TLS certificate fields:

```
certificate "Subject"
certificate "Issuer"
certificate "Start-Date"
certificate "Expire-Date"
certificate "Serial-Number"
```

### Timing Metrics

Timing data is available in two contexts:

**1. Response documentation (response.html) — libcurl metric names:**

| Metric | Description |
|--------|-------------|
| `time_namelookup` | DNS resolution |
| `time_connect` | TCP connection |
| `time_appconnect` | TLS handshake |
| `time_starttransfer` | Time to first byte (TTFB) |
| `time_total` | Total request time |

All values in **microseconds**.

**2. `--json` output (running-tests.html) — JSON field names:**

| Field | Description |
|-------|-------------|
| `name_lookup` | DNS resolution |
| `connect` | TCP connection |
| `app_connect` | TLS handshake |
| `pre_transfer` | Pre-transfer |
| `start_transfer` | Time to first byte (TTFB) |
| `total` | Total request time |

All values in **microseconds**.

Note: `duration` as a capture query returns response time in **milliseconds**, separate from these report metrics.

## Special Characters

| Escape | Meaning |
|--------|---------|
| `\"` | Double quote |
| `\\` | Backslash |
| `\b` | Backspace |
| `\f` | Form feed |
| `\n` | Newline |
| `\r` | Carriage return |
| `\t` | Tab |
| `\u{n}` | Unicode code point |
| `\#` | Literal `#` (in headers) |

File encoding: UTF-8 (BOM tolerated but not required). File extension: `.hurl`.
