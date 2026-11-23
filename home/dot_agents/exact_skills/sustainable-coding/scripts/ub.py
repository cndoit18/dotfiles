#!/usr/bin/env python3
"""Install and run ub-mode's companion tools from any project directory."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile

TOOLS = ("crapper", "dryer", "mutator", "uml")
SOURCES = (
    "git+https://github.com/unclebob/crapper.git",
    "git+https://github.com/unclebob/dryer.git",
    "git+https://github.com/unclebob/mutator.git",
)
USAGE = """usage: ub <tool> [arguments ...]
       ub install

Run a companion tool in the current project. The first use installs it.

Tools:
  crapper   Measure complexity, coverage, and CRAP scores
  dryer     Find structurally duplicated code
  mutator   Run mutation tests
  uml       Install and launch uml-viewer for the current project

Commands:
  install   Install or update the Python tools
  help      Show this help

Tool sources follow their upstream default branches. They are stored outside
the project in UB_MODE_HOME (default: ~/.local/share/ub-mode).
"""


def data_home():
    configured = os.environ.get("UB_MODE_HOME")
    if configured:
        return Path(configured).expanduser()
    xdg_home = Path(os.environ.get("XDG_DATA_HOME", "~/.local/share")).expanduser()
    return xdg_home / "ub-mode"


def venv_python(home):
    executable = "Scripts/python.exe" if os.name == "nt" else "bin/python"
    return home / "venv" / executable


def install_python_tools(home):
    home.mkdir(parents=True, exist_ok=True)
    python = venv_python(home)
    if not python.exists():
        subprocess.run([sys.executable, "-m", "venv", str(home / "venv")], check=True)
    with tempfile.TemporaryDirectory(prefix="ub-mode-install-") as directory:
        requirements = Path(directory) / "requirements.txt"
        requirements.write_text("\n".join(SOURCES) + "\n", encoding="utf-8")
        subprocess.run(
            [str(python), "-m", "pip", "install", "-r", str(requirements)],
            check=True,
        )


def ensure_python_tool(home, tool):
    executable = venv_python(home).parent / tool
    if not executable.exists():
        install_python_tools(home)
    return executable


def run_uml(arguments):
    if not Path("uml").exists():
        subprocess.run(
            [
                "curl",
                "-fsSL",
                "https://raw.githubusercontent.com/unclebob/uml-viewer/master/scripts/get-uml-viewer",
                "-o",
                "get-uml-viewer",
            ],
            check=True,
        )
        Path("get-uml-viewer").chmod(0o755)
        subprocess.run(["./get-uml-viewer", "--install-only"], check=True)
    return subprocess.run(["./uml", *arguments]).returncode


def main(arguments):
    if not arguments or arguments[0] in {"help", "-h", "--help"}:
        print(USAGE, end="")
        return 0
    tool, *arguments = arguments
    if tool not in (*TOOLS, "install"):
        print(f"ub: unknown tool: {tool}\n\n{USAGE}", end="", file=sys.stderr)
        return 2
    if tool == "install":
        install_python_tools(data_home())
        return 0
    if tool == "uml":
        return run_uml(arguments)
    executable = ensure_python_tool(data_home(), tool)
    return subprocess.run([str(executable), *arguments]).returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
