# Changelog

All notable changes to this project will be recorded here.

Format: [Semantic Versioning](https://semver.org/). Dates are YYYY-MM-DD.

---

## [Unreleased]

---

## [0.7.0] — 2026-03-29

### Added
- `bin/release` — single-command release script that handles version bump, changelog update, git commit, tag, push, and GitHub release creation
- Single-approval push command pattern — agents present one confirmation prompt then run `bin/release` as a single command

### Changed
- `tooling/agent-instructions.md` — rewritten as canonical template with placeholder markers (`<!-- {{SKILL_COMMANDS}} -->`, `<!-- {{PROMPT_MACROS}} -->`, `<!-- {{PROJECT_CONTEXT}} -->`), source-file header comment, session-start section, corrected changelog tracking (no version bump on individual changes), single-approval push behavior via `bin/release`
- `skills/sync.sh` — refactored to read `agent-instructions.md` as template source instead of hardcoded heredocs; substitutes placeholder lines with dynamic content; fixed header comment to identify `agent-instructions.md` as source file
- `CONTRIBUTING.md` — release process aligned with single-approval behavior; references `bin/release`
- `project.md` — fixed inaccurate instruction ("appended to CLAUDE.md" → "injected into agent instructions")
- Regenerated all adapter files (`tooling/claude.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `COMMANDS.md`)

### Fixed
- `skills/sync.sh` now actually reads `tooling/agent-instructions.md` as documented in `tooling/README.md` — previously the script ignored this file and used hardcoded heredocs

## [0.6.0] — 2026-03-28

### Changed
- Push command instructions in `tooling/agent-instructions.md` and `skills/sync.sh` — changed from "provide the commands" to explicitly "execute the full release sequence yourself via the terminal." Agents must run git commit, tag, push, and gh release commands directly — not display them for the user to run. Full 5-step release sequence now explicitly documented.
- Regenerated all tool adapter files (`tooling/claude.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `COMMANDS.md`)

---

## [0.5.0] — 2026-03-28

### Added
- `prompts/` directory — prompt macro system for shorthand triggers that expand into predefined text appended to user messages
- `prompts/doublecheck.md` — `/doublecheck` macro for code review and verification workflow
- `prompts/proceed.md` — `/proceed` macro for systematic implementation workflow
- Prompt macros section in `skills/sync.sh` — reads `prompts/*.md`, generates expansion text into all agent adapter files
- Prompt macros section in `COMMANDS.md` — trigger summary table and full expansion text reference
- Prompt macros section in `tooling/agent-instructions.md` — behavior rules for how agents handle prompt macro triggers

### Changed
- `skills/sync.sh` — extended to read `prompts/*.md` and inject prompt macros into generated files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`)
- `tooling/README.md` — added `prompts/*.md` to source files list and architecture diagram

---

## [0.4.1] — 2026-03-28

### Changed
- Removed `project:commands` and `project:status` as AI chat commands — these are now CLI-only via `bin/project`
- Added "Two command systems" section to `README.md` distinguishing AI chat commands (`push:*`, `scribe:*`) from terminal CLI commands (`bin/project`)
- Renamed `COMMANDS.md` "project:" section to "push: — Release" (only push commands remain as AI chat commands)
- Removed `project:commands` and `project:status` handler blocks from `tooling/agent-instructions.md`
- Regenerated all tool adapter files (`tooling/claude.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `COMMANDS.md`)

---

## [0.4.0] — 2026-03-28

### Added
- `bin/project` CLI — run read-only project commands (`status`, `commands`) directly from the terminal without consuming AI agent tokens. Documented in `COMMANDS.md`, `tooling/agent-instructions.md`, and all generated adapter files.
- `docs/` directory — dedicated location for project documentation that grows with the project. Referenced in key files tables, `README.md`, `README.template.md`, `setup.sh`, and all agent adapter files.

---

## [0.3.1] — 2026-03-28

### Fixed
- Release instructions across all agent files — replaced two-step "tag + remind to create GitHub Release" with a single three-command sequence (`git tag`, `git push origin`, `gh release create`). Affected files: `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `skills/sync.sh`, `tooling/agent-instructions.md`, `tooling/claude.md`.

---

## [0.3.0] — 2026-03-28

### Added
- `tooling/` directory — centralised source-of-truth for AI agent instructions (`agent-instructions.md`) and generated Claude Code instructions (`claude.md`)
- `tooling/README.md` — explains the tooling architecture, generation pipeline, and how to add new tools
- `COMMANDS.md` — generated command reference aggregated from all skill files; now a first-class file referenced by `CLAUDE.md`
- `.cursor/rules/agent.mdc` — Cursor adapter with MDC frontmatter (`alwaysApply: true`), generated by `sync.sh`
- `scribe:adr` command — write architectural decision records (ADR template added to `skills/scribe.md`)
- `invoke scribe` trigger phrase added to Scribe skill

### Changed
- `CLAUDE.md` — converted from a full generated file to a thin pointer using `@` imports (`@tooling/claude.md`, `@COMMANDS.md`). Claude Code auto-loads these at session start.
- `skills/sync.sh` — now generates `tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, and restores the root `CLAUDE.md` pointer. Replaces the previous `.cursorrules` output.
- `setup.sh` — generates Copilot and Cursor adapter files inline instead of calling `sync.sh`; updated placeholder list; improved output formatting and next-steps messaging
- `skills/scribe.md` — restructured with explicit output standards per command; added ADR template; tightened rules section
- `.github/copilot-instructions.md` — regenerated from new `agent-instructions.md` template with project commands, skill commands, and key files sections
- `README.md` — replaced scaffold README with tooling-focused README explaining the generation pipeline and adapter file table
- `README.template.md` — fixed relative link syntax; added `COMMANDS.md` to documentation table

### Removed
- `copilot-instructions.md` (root) — duplicate file; Copilot instructions now live exclusively at `.github/copilot-instructions.md`
- `scribe:review` command — replaced by `scribe:adr`

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
