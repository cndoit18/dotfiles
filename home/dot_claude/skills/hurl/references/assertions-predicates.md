# Assertions, Predicates, and Filters

## Table of Contents

- [Capture Query Types](#capture-query-types)
- [Predicates](#predicates)
- [Filters](#filters)
- [Filter Chaining](#filter-chaining)

## Capture Query Types

Used in `[Captures]` and `[Asserts]` sections to extract values from responses.

| Query | Description | Example |
|-------|-------------|---------|
| `status` | HTTP status code | `status` |
| `version` | HTTP version | `version` |
| `header "Name"` | Response header value | `header "Content-Type"` |
| `cookie "name"` | Cookie value | `cookie "session_id"` |
| `cookie "name[Attr]"` | Cookie attribute | `cookie "sid[Expires]"` |
| `body` | Full response body | `body` |
| `bytes` | Full response body as bytes | `bytes` |
| `xpath "expr"` | XPath on HTML/XML body | `xpath "string(//title)"` |
| `jsonpath "expr"` | JSONPath on JSON body | `jsonpath "$.id"` |
| `regex "pattern"` | Regex match on body | `regex "id=([0-9]+)"` |
| `sha256` | SHA-256 hash of body | `sha256` |
| `md5` | MD5 hash of body | `md5` |
| `url` | Response URL (after redirects) | `url` |
| `redirects` | Number of redirects | `redirects` |
| `ip` | Remote IP address | `ip` |
| `variable "name"` | Get variable value | `variable "token"` |
| `duration` | Response time in ms | `duration` |
| `certificate "field"` | TLS certificate field | `certificate "Subject"` |

### Certificate Fields

`certificate` query supports:
- `Subject`, `Issuer`, `Start-Date`, `Expire-Date`, `Serial-Number`

### Cookie Attributes

`cookie` query supports attribute access:
- `Expires`, `Max-Age`, `Domain`, `Path`, `Secure`, `HttpOnly`, `SameSite`

## Predicates

Used in `[Asserts]` and implicit response assertions. All predicates can be negated with `not`.

### Comparison Predicates

| Predicate | Types | Example |
|-----------|-------|---------|
| `==` | any | `== 200`, `== "hello"`, `== true` |
| `!=` | any | `!= "error"`, `!= null` |
| `>` | number | `> 0`, `> 100` |
| `>=` | number | `>= 1` |
| `<` | number | `< 100` |
| `<=` | number | `<= 10` |

### String Predicates

| Predicate | Description | Example |
|-----------|-------------|---------|
| `startsWith` | String starts with | `startsWith "http"` |
| `endsWith` | String ends with | `endsWith ".json"` |
| `contains` | Contains substring/element | `contains "error"` |
| `matches` | Regex match | `matches "^\\d+$"` |

### Type Check Predicates

| Predicate | Description | Example |
|-----------|-------------|---------|
| `exists` | Value exists (not null) | `exists` |
| `isEmpty` | Value is empty/null | `isEmpty` |
| `isBoolean` | Value is boolean | `isBoolean` |
| `isFloat` | Value is float | `isFloat` |
| `isInteger` | Value is integer | `isInteger` |
| `isNumber` | Value is a number | `isNumber` |
| `isString` | Value is a string | `isString` |
| `isObject` | Value is an object | `isObject` |
| `isList` | Value is a list | `isList` |
| `isIsoDate` | Value is ISO 8601 date | `isIsoDate` |
| `isIpv4` | Value is IPv4 address | `isIpv4` |
| `isIpv6` | Value is IPv6 address | `isIpv6` |
| `isUuid` | Value is a UUID | `isUuid` |

### Negation

All predicates support `not`:

```
jsonpath "$.error" not exists
header "X-Debug" not exists
jsonpath "$.items" not includes "removed"
jsonpath "$.name" not contains "test"
```

## Filters

Filters transform query results. Pipe multiple filters together.

### Encoding / Decoding

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `base64Decode` | string → bytes | Decode base64 |
| `base64Encode` | bytes → string | Encode to base64 |
| `base64UrlSafeDecode` | string → bytes | Decode URL-safe base64 |
| `base64UrlSafeEncode` | bytes → string | Encode to URL-safe base64 |
| `decode "enc"` | bytes → string | Decode bytes with encoding |
| `htmlEscape` | string → string | HTML-escape |
| `htmlUnescape` | string → string | HTML-unescape |
| `urlDecode` | string → string | URL-decode |
| `urlEncode` | string → string | URL-encode |
| `utf8Decode` | bytes → string | Decode UTF-8 bytes |
| `utf8Encode` | string → bytes | Encode to UTF-8 bytes |
| `toHex` | bytes → string | Convert bytes to hex |

### Type Conversion

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `toFloat` | any → float | Convert to float |
| `toInt` | any → integer | Convert to integer |
| `toString` | any → string | Convert to string |
| `toDate` | string → date | Parse as date (`%+` shorthand for ISO 8601 / RFC 3339) |

### Collection Operations

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `count` | collection → integer | Count elements |
| `first` | collection → any | First element |
| `last` | collection → any | Last element |
| `nth N` | collection → any | Nth element (zero-based, supports negative indices) |

### String Operations

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `replace "from" "to"` | string → string | Replace substring |
| `replaceRegex "pat" "to"` | string → string | Replace by regex |
| `split "sep"` | string → list | Split string by separator |

### Query / Extraction

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `jsonpath "expr"` | JSON → any | Apply JSONPath |
| `xpath "expr"` | HTML/XML → any | Apply XPath |
| `regex "pattern"` | string → string | Extract regex match |
| `location` | header → string | Extract URL from header |
| `urlQueryParam "name"` | string → string | Extract query param from URL |

### Date Operations

| Filter | Input → Output | Description |
|--------|---------------|-------------|
| `dateFormat "fmt"` | date → string | Format date (strftime). Formerly `format`, which is deprecated |
| `daysAfterNow` | date → integer | Days from now |
| `daysBeforeNow` | date → integer | Days before now |

## Filter Chaining

Filters are chained with **spaces** (not pipes). Use them in captures and assertions.

### Extract token from redirect URL

```
header "Location" urlQueryParam "token"
```

### Navigate nested JSON

```
body jsonpath "$.items" nth 2 jsonpath "$.name"
```

### Format and compare date

```
jsonpath "$.created_at" dateFormat "%Y-%m-%d" == "2024-01-15"
```

### Count collection elements

```
jsonpath "$.items" count > 0
```

### Decode base64 and extract field

```
jsonpath "$.payload" base64Decode jsonpath "$.sub"
```

### Extract from URL

```
jsonpath "$.redirect_url" urlQueryParam "code"
```
