# {{PROJECT_NAME}} — AI Agent Instructions

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

### On "push", "ship it", "done", "merge this", or any equivalent

Stop. Do not proceed until the following checklist is confirmed:

- [ ] Version bumped in all required locations
- [ ] `CHANGELOG.md` updated — `[Unreleased]` section has an entry for this change
- [ ] Git tag command prepared and ready to run

Always provide the exact tag command:

```
git tag -a vX.Y.Z -m "Release vX.Y.Z — <one line summary>"
git push origin vX.Y.Z
```

Then remind to create a GitHub Release from that tag using the `CHANGELOG.md` entry as release notes.

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
| `CONTRIBUTING.md` | SemVer rules, release process, and reminder rules |
| `VERSION` | Canonical version number for the repo |

---

## Skills

Skills are specialised behavioral modules that extend what an AI tool can do within this project. Each skill is a self-contained markdown file in the `skills/` directory. A skill defines a focused identity, scope, rules, and output standards for a specific type of work.

**To invoke a skill:** read the corresponding file in `skills/` and adopt its identity, rules, and constraints for the duration of the task.

| Skill | File | Purpose |
|---|---|---|
| **Scribe** | `skills/scribe.md` | Documentation specialist — maintains all project documentation |

**Invoke Scribe when:** documenting a new component, updating the system design, writing up an architectural decision, or any time documentation needs to be created or maintained.

---

## Project Context

**{{PROJECT_NAME}}:** {{PROJECT_DESCRIPTION}}  
**Platform:** {{PROJECT_PLATFORM}}

For non-negotiable constraints and critical design decisions, read the `## Key Constraints`
section of `{{PROJECT_NAME}}.md` before making any changes. That section is maintained
alongside the system design and is the authoritative quick-reference for AI tools.
