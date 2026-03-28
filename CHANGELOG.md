# Changelog

All notable changes to this project will be recorded here.

Format: [Semantic Versioning](https://semver.org/). Dates are YYYY-MM-DD.

---

## [Unreleased]

---

## [0.2.1] — 2026-03-28

### Fixed
- `README.md` — fixed Mermaid code block syntax (added `mermaid` language identifier) and corrected newline syntax in diagram node labels (`\n` → `<br/>`). Diagrams now render correctly on GitHub.

---

## [0.2.0] — 2026-03-28

### Added
- `skills/sync.sh` — generator script that produces `CLAUDE.md`, `.cursorrules`, and `.github/copilot-instructions.md` from `skills/*.md` and `project.md`. Run after adding or modifying a skill.
- `project.md` — user-editable file for AI tool project context. Replaces the manual Project Context section previously maintained inside `CLAUDE.md`.
- `assets/scaffold-architecture.svg` — diagram showing the generation data flow from source files through `sync.sh` to output files.
- `assets/semver-decision-tree.svg` — visual decision guide for choosing the correct push command.
- `.cursorrules` — generated placeholder, now produced by `sync.sh` alongside `CLAUDE.md`.
- Push command system: `push:breaking`, `push:new`, `push:fix` — explicit version-bump commands replacing the previous freeform release trigger phrases.
- Skill command system: skills are now invoked with explicit typed commands (`scribe:document`, `scribe:update`, `scribe:review`). No automatic triggers.

### Changed
- `CLAUDE.md` — converted from a manually authored file to a generated artifact. The template version is a placeholder; `setup.sh` runs `sync.sh` to produce the real file. Never edit directly.
- `.github/copilot-instructions.md` — converted from manually authored to generated. Produced by `sync.sh` alongside `CLAUDE.md`.
- `skills/scribe.md` — added `## Commands` section in the format required by `sync.sh`. This is the standard that all skill files must follow.
- `setup.sh` — added `project.md` and `skills/sync.sh` to the placeholder replacement pass; added `bash skills/sync.sh` call before self-cleanup; updated summary output.
- `CONTRIBUTING.md` — replaced freeform release trigger phrases with the push command table and decision tree reference; added skill commands section; added `bash skills/sync.sh` documentation.
- `README.md` — major update covering generated file architecture, push commands with decision tree, skill commands, updated file tree, updated quick start, updated AI tool support table, updated philosophy.

---

## [0.1.0] — 2026-03-27

Initial release of the Project Scaffold template.

### Added
- `PROJECT.md` — living system document template
- `CLAUDE.md` — AI agent standing orders
- `CONTRIBUTING.md` — semantic versioning rules and release process
- `CHANGELOG.md` — change record
- `VERSION` — canonical version file, starting at `0.1.0`
- `README.md` / `README.template.md` — scaffold README and project README template
- `LICENSE` — MIT license with placeholder fields
- `.gitignore` — sensible defaults for most stacks
- `setup.sh` — five-prompt setup script with self-cleanup
- `skills/scribe.md` — documentation specialist skill
- `.github/copilot-instructions.md` — GitHub Copilot instructions
