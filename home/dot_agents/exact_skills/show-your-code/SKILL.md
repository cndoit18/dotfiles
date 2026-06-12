---
name: show-your-code
description: This skill should be used only when the user explicitly wants to upload an existing local .html or .htm file to Show Your Code/showyourcode.app and receive a https://www.showyourcode.app/share/<uuid> sharing link. Do not use it for creating, editing, previewing, analyzing, or reviewing HTML; do not use it for URLs, screenshots, snippets, Markdown, or non-HTML files.
---

# Show Your Code

Use this skill to turn a local HTML file into a Show Your Code share link.

## Workflow

1. Confirm the user provided a local HTML file path.
   - Accept files ending in `.html` or `.htm`.
   - Do not accept Markdown, screenshots, URLs, or arbitrary text snippets.
   - If the user did not provide a file path, ask for the HTML file path.
   - Because this creates an unprotected third-party share link, do not upload HTML that may contain secrets, personal data, private URLs, or unreleased business content unless the user explicitly confirms it is safe to share.
2. Run the bundled CLI from this skill directory:

   ```bash
   python scripts/share-html.py /path/to/file.html
   ```

3. Return the generated `https://www.showyourcode.app/share/<uuid>` URL to the user.

## Output style

When the CLI succeeds, answer briefly:

```text
已生成 Show Your Code 分享链接：<url>
```

If validation fails, tell the user the input must be a local `.html` or `.htm` file and ask them to provide the correct file.
