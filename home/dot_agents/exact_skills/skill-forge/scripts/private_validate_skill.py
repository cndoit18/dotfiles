#!/usr/bin/env python3
"""Validate core Agent Skills fields and local resource links using stdlib only.

This is an offline fallback, not a complete YAML implementation. Use the target
runtime's official validator for authoritative validation.
"""

import argparse
import json
import re
import sys
from pathlib import Path

NAME_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
FIELD_PATTERN = re.compile(r"^([A-Za-z][A-Za-z0-9_-]*):(?:[ \t]*(.*))?$")
RESOURCE_PATTERN = re.compile(
    r"(?:\]\(|\x60)((?:references|scripts|assets|evals)/[^)\s\x60]+)"
)
BLOCK_PATTERN = re.compile(r"^([>|])(?:[+-]?[0-9]?|[0-9]?[+-]?)$")


def parse_scalar(raw):
    raw = raw.strip()
    if not raw:
        return ""
    if raw.startswith('"'):
        try:
            value = json.loads(raw)
        except json.JSONDecodeError as error:
            raise ValueError("invalid double-quoted scalar: " + str(error))
        if not isinstance(value, str):
            raise ValueError("expected a string scalar")
        return value
    if raw.startswith("'"):
        if len(raw) < 2 or not raw.endswith("'"):
            raise ValueError("unterminated single-quoted scalar")
        return raw[1:-1].replace("''", "'")
    raw = re.split(r"\s+#", raw, maxsplit=1)[0].strip()
    if raw.startswith(("[", "{")):
        raise ValueError("required fields must use string scalars")
    return raw


def parse_block(lines, style):
    non_empty_indents = [
        len(line) - len(line.lstrip(" "))
        for line in lines
        if line.strip()
    ]
    indent = min(non_empty_indents) if non_empty_indents else 0
    normalized = [
        line[indent:] if line.strip() else ""
        for line in lines
    ]
    text = "\n".join(normalized)
    if style == ">":
        paragraphs = re.split(r"\n\s*\n", text)
        text = "\n".join(
            " ".join(part.splitlines()) for part in paragraphs
        )
    return text.strip()


def parse_frontmatter(lines):
    fields = {}
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line.strip() or line.lstrip().startswith("#"):
            index += 1
            continue
        if line[:1].isspace():
            index += 1
            continue
        match = FIELD_PATTERN.match(line)
        if not match:
            raise ValueError(
                "unsupported frontmatter structure at line " + str(index + 2)
            )
        key = match.group(1)
        raw = (match.group(2) or "").strip()
        if key in fields:
            raise ValueError("duplicate frontmatter field: " + key)
        block_match = BLOCK_PATTERN.match(raw)
        if block_match:
            block_lines = []
            index += 1
            while index < len(lines):
                candidate = lines[index]
                if candidate.strip() and not candidate[:1].isspace():
                    break
                block_lines.append(candidate)
                index += 1
            fields[key] = parse_block(block_lines, block_match.group(1))
            continue
        fields[key] = parse_scalar(raw)
        index += 1
    return fields


def validate_skill(skill_directory):
    root = Path(skill_directory).expanduser().resolve()
    result = {
        "skill": str(root),
        "valid": False,
        "errors": [],
        "warnings": [],
        "validation_scope": (
            "Core fields and local resource links only; "
            "not a complete YAML or runtime validator"
        ),
    }
    skill_file = root / "SKILL.md"
    if not root.is_dir():
        result["errors"].append("Skill directory does not exist")
        return result
    if not skill_file.is_file():
        result["errors"].append("SKILL.md is missing")
        return result
    try:
        text = skill_file.read_text(encoding="utf-8-sig")
        lines = text.splitlines()
        if not lines or lines[0].strip() != "---":
            raise ValueError("SKILL.md must start with YAML frontmatter")
        try:
            closing = next(
                index for index in range(1, len(lines))
                if lines[index].strip() == "---"
            )
        except StopIteration:
            raise ValueError("frontmatter closing --- is missing")
        fields = parse_frontmatter(lines[1:closing])
    except (OSError, UnicodeError, ValueError) as error:
        result["errors"].append(str(error))
        return result

    name = fields.get("name", "")
    description = fields.get("description", "")
    compatibility = fields.get("compatibility", "")
    if not 1 <= len(name) <= 64 or not NAME_PATTERN.fullmatch(name):
        result["errors"].append(
            "name must be 1-64 lowercase letters, digits, or single hyphens"
        )
    if name != root.name:
        result["errors"].append("name must match the parent directory")
    if not 1 <= len(description) <= 1024:
        result["errors"].append("description must contain 1-1024 characters")
    if compatibility and len(compatibility) > 500:
        result["errors"].append("compatibility must contain at most 500 characters")

    body = "\n".join(lines[closing + 1:])
    if len(lines[closing + 1:]) > 500:
        result["warnings"].append("SKILL.md body exceeds 500 lines")
    for reference in sorted(set(RESOURCE_PATTERN.findall(body))):
        if not (root / reference).exists():
            result["errors"].append("referenced resource is missing: " + reference)

    result["valid"] = not result["errors"]
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_directory", help="Directory containing SKILL.md")
    arguments = parser.parse_args()
    result = validate_skill(arguments.skill_directory)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["valid"] else 1


if __name__ == "__main__":
    sys.exit(main())
