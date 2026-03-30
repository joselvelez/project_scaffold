# Tooling

This directory contains AI tool adapter files — the tool-specific configurations that translate project rules into whatever format a given tool expects.

**The project rules are not defined here.** They live in:

- `tooling/agent-instructions.md` — edit this to change agent behaviour project-wide
- `project-context.md` — generated via `context:generate` from the system document
- `skills/*.md` — edit these to add or change skill commands
- `prompts/*.md` — edit these to add or change prompt macros

Never edit the generated files directly. Run `bash skills/sync.sh` instead.

---

## How it works

```
tooling/agent-instructions.md   ← you edit this
project-context.md                      ← generated via context:generate
skills/*.md                     ← you edit these
prompts/*.md                    ← you edit these
         │
         └── bash skills/sync.sh
                    │
                    ├── tooling/claude.md                (generated)
                    ├── COMMANDS.md                      (generated)
                    ├── CLAUDE.md                        (generated, thin pointer)
                    ├── .cursor/rules/agent.mdc          (generated)
                    ├── .github/copilot-instructions.md  (generated)
                    ├── .clinerules                      (generated)
                    └── .roo/rules/agent.md              (generated)
```

`sync.sh` reads `agent-instructions.md`, aggregates `## Commands` tables from every file in `skills/`, reads prompt macros from `prompts/`, appends `project-context.md` context (generated via `context:generate`), and writes the result to each tool's required location and format.

---

## Generated files

| File | Tool | Notes |
|---|---|---|
| `tooling/claude.md` | Claude Code | Full generated instructions. Loaded via `@` import in root `CLAUDE.md`. |
| `CLAUDE.md` (root) | Claude Code | Thin pointer only — two `@` import lines. Auto-loaded by Claude Code at session start. |
| `COMMANDS.md` | All tools | Human-readable command reference. Aggregated from `skills/*.md`. |
| `.cursor/rules/agent.mdc` | Cursor | Full instructions with MDC frontmatter (`alwaysApply: true`). |
| `.github/copilot-instructions.md` | GitHub Copilot | Full instructions. Auto-loaded by Copilot. |
| `.clinerules` | Cline | Full instructions. Auto-loaded from project root. |
| `.roo/rules/agent.md` | Roo Code | Full instructions. Auto-loaded from `.roo/rules/`. |

---

## Adding a new tool

1. Add a generation step to `skills/sync.sh` that writes to the path the tool requires
2. Add the tool to the generated files table above
3. Never put project logic into a generation step — all logic belongs in `agent-instructions.md`
