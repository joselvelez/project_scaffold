# Tooling

This directory contains AI tool adapter files — the tool-specific configurations that translate project rules into whatever format a given tool expects.

**The project rules are not defined here.** They live in:

- `tooling/agent-instructions.md` — edit this to change agent behaviour project-wide
- `project.md` — edit this to update project-specific context
- `skills/*.md` — edit these to add or change skill commands

Never edit the generated files directly. Run `bash skills/sync.sh` instead.

---

## How it works

```
tooling/agent-instructions.md   ← you edit this
project.md                      ← you edit this
skills/*.md                     ← you edit these
         │
         └── bash skills/sync.sh
                    │
                    ├── tooling/claude.md                (generated)
                    ├── COMMANDS.md                      (generated)
                    ├── CLAUDE.md                        (generated, thin pointer)
                    ├── .cursor/rules/agent.mdc          (generated)
                    └── .github/copilot-instructions.md  (generated)
```

`sync.sh` reads `agent-instructions.md`, aggregates `## Commands` tables from every file in `skills/`, appends `project.md` context, and writes the result to each tool's required location and format.

---

## Generated files

| File | Tool | Notes |
|---|---|---|
| `tooling/claude.md` | Claude Code | Full generated instructions. Loaded via `@` import in root `CLAUDE.md`. |
| `CLAUDE.md` (root) | Claude Code | Thin pointer only — two `@` import lines. Auto-loaded by Claude Code at session start. |
| `COMMANDS.md` | All tools | Human-readable command reference. Aggregated from `skills/*.md`. |
| `.cursor/rules/agent.mdc` | Cursor | Full instructions with MDC frontmatter (`alwaysApply: true`). |
| `.github/copilot-instructions.md` | GitHub Copilot | Full instructions. Auto-loaded by Copilot. |

---

## Adding a new tool

1. Add a generation step to `skills/sync.sh` that writes to the path the tool requires
2. Add the tool to the generated files table above
3. Never put project logic into a generation step — all logic belongs in `agent-instructions.md`
