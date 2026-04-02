#!/bin/bash
# project-detector.sh
# 通用项目检测脚本，支持多种语言，从markdown文件读取提示词

set -euo pipefail

# 读取hook输入
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANGUAGES_DIR="$SCRIPT_DIR/languages"

LANGUAGE="unknown"

if [ -f "$CWD/package.json" ]; then
	LANGUAGE="nodejs"
elif [ -f "$CWD/Cargo.toml" ]; then
	LANGUAGE="rust"
elif [ -f "$CWD/go.mod" ]; then
	LANGUAGE="go"
elif [ -f "$CWD/pyproject.toml" ] || [ -f "$CWD/setup.py" ]; then
	LANGUAGE="python"
elif [ -f "$CWD/pom.xml" ]; then
	LANGUAGE="java"
elif [ -f "$CWD/build.gradle" ] || [ -f "$CWD/build.gradle.kts" ]; then
	LANGUAGE="java"
fi

# 读取对应语言的提示词文件
LANGUAGE_FILE="$LANGUAGES_DIR/${LANGUAGE}.md"
if [ -f "$LANGUAGE_FILE" ]; then
	ADDITIONAL_CONTEXT=$(cat "$LANGUAGE_FILE")
else
	exit 0
fi

# 返回JSON格式的额外上下文
jq -n --arg ctx "$ADDITIONAL_CONTEXT" '{
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": $ctx
    }
}'

exit 0
