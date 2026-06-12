#!/usr/bin/env python3
import argparse
import json
import mimetypes
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

API_URL = "https://www.showyourcode.app/api/pages"
SHARE_URL_PREFIX = "https://www.showyourcode.app/share/"
UUID_PATTERN = re.compile(
    r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
)


def is_html_file(path: Path) -> bool:
    if path.suffix.lower() not in {".html", ".htm"}:
        return False

    guessed_type, _ = mimetypes.guess_type(path.name)
    if guessed_type and guessed_type not in {"text/html", "application/xhtml+xml"}:
        return False

    return True


def build_request(html_content: str) -> urllib.request.Request:
    payload = json.dumps(
        {
            "htmlContent": html_content,
            "isProtected": False,
            "codeType": "html",
        }
    ).encode("utf-8")

    headers = {
        "Accept": "application/json, text/plain, */*",
        "Content-Type": "application/json",
        "Origin": "https://www.showyourcode.app",
        "Referer": "https://www.showyourcode.app/",
        "User-Agent": "show-your-code-skill/1.0",
    }

    return urllib.request.Request(API_URL, data=payload, headers=headers, method="POST")


def create_share_url(html_path: Path) -> str:
    try:
        html_content = html_path.read_text(encoding="utf-8")
    except UnicodeDecodeError as error:
        raise RuntimeError("无法按 UTF-8 读取该 HTML 文件，请先转换为 UTF-8 编码。") from error
    except OSError as error:
        raise RuntimeError(f"无法读取该 HTML 文件：{error}") from error

    request = build_request(html_content)

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            response_body = response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Show Your Code API returned HTTP {error.code}: {detail}") from error
    except urllib.error.URLError as error:
        raise RuntimeError(f"Failed to reach Show Your Code API: {error.reason}") from error

    try:
        data = json.loads(response_body)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"Show Your Code API returned non-JSON response: {response_body}") from error

    uuid = data.get("uuid")
    if not isinstance(uuid, str) or not UUID_PATTERN.fullmatch(uuid):
        raise RuntimeError(f"Show Your Code API response did not include a valid uuid: {response_body}")

    return f"{SHARE_URL_PREFIX}{uuid}"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create a Show Your Code share link for an HTML file.")
    parser.add_argument("html_file", help="Path to a local .html or .htm file")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    html_path = Path(args.html_file).expanduser()

    if not html_path.is_file():
        print("输入必须是一个本地 HTML 文件：请传入 .html 或 .htm 文件路径。", file=sys.stderr)
        return 2

    if not is_html_file(html_path):
        print("输入必须是 HTML 文件：请传入扩展名为 .html 或 .htm 的文件。", file=sys.stderr)
        return 2

    try:
        share_url = create_share_url(html_path)
    except RuntimeError as error:
        print(str(error), file=sys.stderr)
        return 1

    print(share_url)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
