# Development Guidelines

This document contains critical information about working with this codebase. Follow these guidelines precisely.

## Core Development Rules

- Always use `Context7` MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.
- Always load skill `go-uber-style` when working with `.go` files.
- Always load skill `excalidraw` when the user requests architecture diagrams, system diagrams, codebase visualization, or Excalidraw file generation.
- When working with Python projects, always check for a virtual environment (venv) and activate it if present. Prefer using `uv run` instead of `python` when available.

## Comments & Communication

- Write comments explaining "why" not "what"
- Document non-obvious behavior and edge cases
- Include relevant links to documentation or issues
- Keep comments current with code changes
