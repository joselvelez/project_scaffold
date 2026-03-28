# {{PROJECT_NAME}} — Agent Instructions

You are working on {{PROJECT_NAME}}. Read `{{PROJECT_NAME}}.md` before making any changes. It is the source of truth for what this system is and how it is structured. If something about the system is unclear, read that file before making assumptions.

---

## Mandatory: Changelog and Version Tracking

These rules apply to every session and every change without exception. They are not optional.

### On any file change

1. Determine whether the change is PATCH, MINOR, or MAJOR per the rules in `CONTRIBUTING.md`.
2. Bump the version in **all** of the following — they must always be identical:
   - `VERSION` (repo root)
   - `{{PROJECT_NAME}}.md` header
   - `package.json` if this is a JS/TS project and the file exists
3. Add an entry to the `[Unreleased]` section of `CHANGELOG.md` describing what changed and why. Never leave a change undocumented.

### On `project:release` (aliases: `push` · `ship it` · `done` · `merge this`)

Stop. Do not proceed until the following checklist is confirmed:

- Version bumped in all required locations
- `CHANGELOG.md` updated — `[Unreleased]` section has an entry for this change
- Git tag command prepared and ready to run

Always provide the exact three-command release sequence. Extract the release notes from the versioned entry just written to `CHANGELOG.md` and populate them inline — do not leave placeholders:

```
git tag -a vX.Y.Z -m "Release vX.Y.Z — <one line summary>"
git push origin vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z — <one line summary>" --notes "<changelog entry for this version>"
```

### Never

- Never make a change without updating `CHANGELOG.md`
- Never skip a version bump, even for small changes
- Never let version numbers drift out of sync across files
- Never silently increment — always state the new version and the reason for the bump level

---

## Key Files

| File | Purpose |
|---|---|
| `README.md` | Project README — brief overview and links to documentation |
| `{{PROJECT_NAME}}.md` | Living system document — always reflects the current state of the system |
| `CHANGELOG.md` | Chronological record of every change |
| `CONTRIBUTING.md` | SemVer rules and the full release process |
| `VERSION` | Canonical version number for the repo |
| `COMMANDS.md` | All available commands and trigger phrases, grouped by namespace |
| `docs/` | Project documentation — grows with the project |

---

## Skills

Skills are specialised behavioural modules that extend what an AI tool can do within this project. Each skill is a self-contained markdown file in `skills/`. A skill defines a focused identity, scope, rules, and output standards for a specific type of work.

**To invoke a skill:** read the corresponding file in `skills/` and adopt its identity, rules, and constraints for the duration of the task.

| Skill | File | Invoke when... |
|---|---|---|
| **Scribe** | `skills/scribe.md` | Any documentation needs to be created or maintained |

For the full list of skill commands and trigger phrases, see `COMMANDS.md` or run `bin/project commands` from the terminal.

---

## Prompt Macros

Prompt macros are shorthand triggers that expand into predefined text. When a user's message ends with a prompt macro trigger (e.g. `/doublecheck`), treat the message as if the full expansion text was appended to it.

**Rules:**
- The trigger must appear at the end of the user's message
- Append the expansion text to the user's original message — do not replace it
- Follow every instruction in the expanded text for the duration of that response

Prompt macros are defined in `prompts/`. Each file contains a `# /trigger` heading followed by the expansion text. Run `bash skills/sync.sh` after adding or changing a prompt macro.

For the full list of prompt macros and their expansion text, see `COMMANDS.md`.

---

## Project Context

**{{PROJECT_NAME}}:** {{PROJECT_DESCRIPTION}}
**Platform:** {{PROJECT_PLATFORM}}

[After running setup.sh, add further context here — what the system does, key constraints, important design decisions that should not be reversed, and anything an AI tool should know before making changes. This section is what lets a tool work sensibly without reading the full system document first.]
