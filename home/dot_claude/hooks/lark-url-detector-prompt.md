## Lark URL Detection — Mandatory Routing Protocol

A Lark/Feishu URL was detected. You **MUST** follow this protocol. Deviations are unacceptable.

### Mandatory Constraints

- You **MUST** use `lark-*` skills to operate on Lark resources
- You **MUST NOT** manually parse URL paths, construct raw HTTP requests, or use browser tools
- You **MUST NOT** guess which skill to invoke — use the routing table or fallback strategy below

### Routing Table

Match the URL path segment against these keywords (first match wins):

| URL Path Keywords          | Skill              | Resource Type    |
| -------------------------- | ------------------ | ---------------- |
| `docx`, `doc`             | `/lark-doc`        | Document         |
| `sheets`, `sheet`         | `/lark-sheets`     | Spreadsheet      |
| `base`, `bitable`         | `/lark-base`       | Base (Bitable)   |
| `drive`, `folder`, `file` | `/lark-drive`      | Drive            |
| `wiki`, `ospace`          | `/lark-kjwiki`     | Wiki             |
| `slides`, `presentation`  | `/lark-slides`     | Slides           |
| `im`, `chat`, `message`   | `/lark-im`         | Messaging        |
| `whiteboard`, `board`     | `/lark-whiteboard` | Whiteboard       |
| `calendar`                | `/lark-calendar`   | Calendar         |
| `mail`                    | `/lark-mail`       | Mail             |
| `task`, `todo`            | `/lark-task`       | Task             |
| `vc`, `meeting`           | `/lark-vc`         | Video Conference |
| `minutes`                 | `/lark-minutes`    | Minutes          |
| `approval`                | `/lark-approval`   | Approval         |
| `contacts`                | `/lark-contact`    | Contacts         |

### Fallback Strategy

When no path keyword matches:

1. Use `/lark-openapi-explorer` to search for a relevant API
2. Extract the token/ID from the URL, query its resource type via `/lark-drive`, then re-route using the table above

### Enforcement

- Routing errors caused by guessing constitute a protocol violation
- When uncertain, always apply the fallback strategy — two-step resolution is always preferable to a wrong route
