# CLI Options Reference

## Table of Contents

- [Synopsis](#synopsis)
- [Global Options](#global-options)
- [Exit Codes](#exit-codes)
- [Environment Variables](#environment-variables)
- [Report Formats](#report-formats)
- [hurlfmt](#hurlfmt)
- [Debug Techniques](#debug-techniques)

## Synopsis

```bash
hurl [options] [file...]
```

Multiple files run sequentially by default. Use `--test` for parallel execution.

## Global Options

### Execution

| Option | Description |
|--------|-------------|
| `--test` | Test mode: parallel execution, test-oriented output |
| `--parallel` | Run files in parallel (implied by `--test`) |
| `--jobs N` | Max parallel jobs (default: number of CPUs) |
| `--to-entry N` | Run up to entry N (1-indexed) |
| `--repeat N` | Repeat the file N times |
| `--ignore-asserts` | Disable all assertions |
| `--continue-on-error` | Continue on error |
| `--glob "pattern"` | Select files matching glob pattern |
| `--file-root DIR` | Root directory for file bodies |
| `--json` | Output JSON for each file to stdout |

### Variables

| Option | Description |
|--------|-------------|
| `--variable name=value` | Set variable |
| `--variables-file file` | Load variables from `.env` file |
| `--secret name=value` | Set secret (redacted from logs) |
| `--secrets-file file` | Load secrets from file |

### HTTP

| Option | Description |
|--------|-------------|
| `--location` | Follow redirects |
| `--location-trusted` | Follow redirects with credentials |
| `--max-redirs N` | Maximum redirects (default: 50) |
| `--compressed` | Request compressed response |
| `--connect-timeout SECS` | Connection timeout |
| `--max-time SECS` | Maximum time per request |
| `--limit-rate RATE` | Limit transfer rate in bytes/sec (e.g. `32000`) |
| `--user user:password` | Basic auth for all requests |
| `--proxy [proto://]host[:port]` | Proxy server |
| `--resolve host:port:addr` | Custom DNS resolution |
| `--connect-to host:port:target` | Connect to specific host:port |
| `--path-as-is` | No URL normalization |

### TLS

| Option | Description |
|--------|-------------|
| `--insecure` | Skip TLS verification |
| `--cert file` | Client certificate (PEM) |
| `--key file` | Private key (PEM) |
| `--cacert file` | CA certificate bundle |
| `--pinnedpubkey hash` | Public key pinning (SHA-256) |

### Protocol

| Option | Description |
|--------|-------------|
| `--http1.0` | Use HTTP/1.0 |
| `--http1.1` | Use HTTP/1.1 |
| `--http2` | Use HTTP/2 |
| `--http3` | Use HTTP/3 |
| `--ipv4` | Resolve to IPv4 only |
| `--ipv6` | Resolve to IPv6 only |
| `--unix-socket file` | Unix domain socket |

### Auth

| Option | Description |
|--------|-------------|
| `--user user:password` | Basic auth |
| `--netrc` | Use ~/.netrc |
| `--netrc-file file` | Specify .netrc file |
| `--netrc-optional` | Optional .netrc |
| `--aws-sigv4 profile` | AWS Signature V4 |

### Retry

| Option | Description |
|--------|-------------|
| `--retry N` | Max retries on error |
| `--retry-interval D` | Retry interval (e.g. `2s`) |

### Output

| Option | Description |
|--------|-------------|
| `--verbose` | Verbose: headers, cookies, timing |
| `--very-verbose` | Very verbose: adds bodies, libcurl logs |
| `--output file` | Output response body to file (`-` for stdout) |
| `--include` / `-i` | Output last entry's headers |
| `--color` | Color output |
| `--error-format short/long` | Error format (long shows headers+body) |

### Reports

| Option | Description |
|--------|-------------|
| `--report-html dir` | HTML report directory |
| `--report-json dir` | JSON report directory |
| `--report-junit file` | JUnit XML report file |
| `--report-tap FILE` | TAP format to file |

### Export

| Option | Description |
|--------|-------------|
| `--curl file` | Export curl commands to file |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success — all requests and assertions passed |
| 1 | CLI parse error — invalid command-line arguments |
| 2 | File parse error — malformed `.hurl` file |
| 3 | Runtime error — connection failure, timeout, etc. |
| 4 | Assert error — response didn't match expectations |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `http_proxy` | HTTP proxy |
| `https_proxy` | HTTPS proxy |
| `all_proxy` | All protocols proxy |
| `no_proxy` | Proxy bypass list |
| `HURL_VARIABLE_name` | Inject variable `name` |
| `HURL_SECRET_name` | Inject secret `name` (redacted from logs) |
| `NO_COLOR` | Disable color output |

## Report Formats

### HTML Report

```bash
hurl --test --report-html ./report *.hurl
```

Produces a browsable HTML report with request/response details for each entry.

### JSON Report

```bash
hurl --test --report-json ./report *.hurl
```

Structured JSON with all request/response data, captures, and assertion results.

### JUnit XML

```bash
hurl --test --report-junit report.xml *.hurl
```

Standard JUnit format for CI/CD integration (Jenkins, GitLab, etc.).

### TAP

```bash
hurl --test --report-tap report.tap *.hurl
```

Test Anything Protocol format for Unix-style test harnesses.

## hurlfmt

Companion tool for formatting and converting `.hurl` files.

```bash
# Format file (formatted and colorized hurl text by default)
hurlfmt file.hurl

# Check formatting without modifying
hurlfmt --check file.hurl

# Export to JSON
hurlfmt file.hurl --out json

# Export to hurl format
hurlfmt file.hurl --out hurl

# Format in-place
hurlfmt file.hurl --in-place

# Convert curl command to hurl
hurlfmt --in curl file.txt

# Standalone HTML (includes CSS)
hurlfmt file.hurl --standalone
```

## Debug Techniques

### Verbose Output Levels

| Level | Shows |
|-------|-------|
| default | Errors only |
| `--verbose` | Request/response headers, cookie store, curl command, duration (no body) |
| `--very-verbose` | Adds request/response bodies, libcurl logs, detailed timings |

### Per-Entry Verbose

```
[Options]
verbose: true
```

### Common Debug Workflows

**Inspect actual response without assertions:**
```bash
hurl --ignore-asserts --verbose test.hurl
```

**See response body for a specific entry:**
```bash
hurl --output - --to-entry 2 test.hurl
```

**Export as curl for manual testing:**
```bash
hurl --curl commands.txt test.hurl
```

**Check assert error details:**
```bash
hurl --error-format long test.hurl
```

**Use mitmproxy for deep inspection:**
```bash
hurl --proxy localhost:8888 test.hurl
```

**Export structured JSON for programmatic analysis:**
```bash
hurl --report-json /tmp/report test.hurl
```
