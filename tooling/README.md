# Tooling

This directory contains AI tool adapter files — the tool-specific configurations that translate project rules into whatever format a given tool expects.

**The project rules are not defined here.** They live in:

- `tooling/agent-instructions.md` — the source of truth for agent behaviour: versioning rules, changelog discipline, skills protocol, command handling
- `COMMANDS.md` — the canonical command registry

Tool adapters are thin. They load the project rules and add only what a specific tool requires — file naming conventions, include syntax, frontmatter, or output format. No project logic lives in an adapter.

---

## Adapters in this directory

| File | Tool | How it reaches the tool |
|---|---|---|
| `agent-instructions.md` | All tools | Referenced by all adapters. Edit this to change agent behaviour project-wide. |
| _(generated)_ | Claude Code | Root `CLAUDE.md` uses `@` imports to load `agent-instructions.md` and `COMMANDS.md` |
| _(generated)_ | GitHub Copilot | `setup.sh` concatenates sources into `.github/copilot-instructions.md` |
| _(generated)_ | Cursor | `setup.sh` concatenates sources into `.cursor/rules/agent.mdc` |

---

## How the generation works

`setup.sh` runs once at project setup. After replacing all placeholders, it:

1. Generates `.github/copilot-instructions.md` by concatenating `tooling/agent-instructions.md` and `COMMANDS.md`
2. Generates `.cursor/rules/agent.mdc` by prepending Cursor frontmatter and concatenating the same sources

Root `CLAUDE.md` is not generated — it uses Claude Code's native `@path` import syntax to load the source files directly at session start.

---

## Adding a new tool adapter

1. Add the tool's name and output path to this README
2. If the tool requires a specific file at a specific path (like Copilot's `.github/` requirement), add a generation step to `setup.sh`
3. If the tool supports file imports, model the adapter after root `CLAUDE.md`
4. If the tool requires a self-contained file, model the adapter after the Copilot/Cursor generation steps in `setup.sh`
5. Never put project logic into an adapter. Logic belongs in `agent-instructions.md`
