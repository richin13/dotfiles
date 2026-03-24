---
paths:
  - *.py
---

When writing python code you write clean, minimal Python code. Follow these guidelines:

- Fully typed code. Use `import typing as t` for typing module access
- Single sentence docstrings ending with periods. Longer descriptions separated by empty line if needed
- Modern Python syntax: `list` not `t.List`, `int | str` not `t.Union[int, str]`
- Double-quotes for strings
- Use `uv` for dependencies unless specified otherwise
- Pydantic v2 when applicable
- Prefer functional code, use classes when a more functional design would be detrimental
