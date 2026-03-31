# Changelog

All notable changes to this project will be recorded here.

Format: [Semantic Versioning](https://semver.org/). Dates are YYYY-MM-DD.

---

## [Unreleased]

---

## [0.11.2] — 2026-03-31

### Changed
- `setup.sh` — automated the end-of-setup workflow: JS/TS projects now get `package.json` created (or version updated) to `0.1.0` automatically; setup now commits (`Initial scaffold`), tags (`v0.1.0`), and pushes to `origin main` without manual intervention; fails loudly if no git remote is configured; self-cleanup moved before git commands so the deletion is captured in the initial commit; removed manual "Next steps" and "When ready to commit" instructions from output
- `README.md` — updated mermaid flowchart to reflect package.json handling and git automation; updated "Option 2" instructions to require remote configuration before running `setup.sh`; updated "That's it" summary to mention automatic commit and push

## [0.11.1] — 2026-03-31

### Fixed
- `bin/update` — corrected DEFAULT_UPSTREAM GitHub username from `velezjose` to `joselvelez`; typo caused HTTP 404 when child projects ran `bin/update` because the URL pointed to a nonexistent GitHub user
- `README.md` — corrected same `velezjose` → `joselvelez` typo in the "Custom upstream" documentation section

## [0.11.0] — 2026-03-30

- Update `README.md`
- Fixed `tooling/agent-instructions.md` push command section to explicitly instruct agents to read `[Unreleased]` from `.scaffold/CHANGELOG.md` when it exists; agents were defaulting to `CHANGELOG.md` (which has an empty `[Unreleased]` section in the template repo)
- Fixed `tooling/agent-instructions.md` Key files table to mention `.scaffold/CHANGELOG.md` fallback alongside `CHANGELOG.md`
- Fixed CONTRIBUTING.md release process description to include scaffold.json version bump (scribe:review finding #001)
- Added tooling/claude.md to the generated files list in CONTRIBUTING.md (scribe:review finding #002)
- Added Prerequisites section to CONTRIBUTING.md documenting the GitHub CLI (gh) dependency required by bin/release (scribe:review finding #003)
- Fixed bin/project to use .scaffold/CHANGELOG.md fallback, matching bin/release behavior (scribe:review finding #004)


### Fixed
- `prompts/begin.md` — renamed trigger from `# /proceed` to `# /begin`; was producing duplicate `/proceed` entries in all generated adapter files since both `begin.md` and `proceed.md` declared the same trigger
- `scaffold.json` — updated version from `0.9.0` to `0.10.0` to match `VERSION`; was out of sync since the 0.10.0 release

### Added
- `bin/release` — now bumps `scaffold.json` version (if present) alongside `VERSION`, `package.json`, and project `.md` header; prevents scaffold manifest version drift on future releases
- `CONTRIBUTING.md` — added `scaffold.json` to "Where the version lives" table (template repo only)
- `README.md` — added `prompts/begin.md` and `skills/context.md` to the file tree
- `README.md` — added Context Generator skill mention to §"Skill commands" narrative (both shipped skills now documented)
- `README.md` — added note near file tree that `scaffold.json` and `.scaffold/` are template-only files removed by `setup.sh`
- `README.md` — added note that `.github/` contains only the generated Copilot file — no CI/CD config by design
- `README.md` — added note to §"Two independent version tracks" explaining `PROJECT.md` stays at `v0.1.0` as the template default
- `README.md` — added default upstream URL to §"Custom upstream"

### Changed
- `skills/scribe.md` — added Resolution Phase to `scribe:review`: after presenting findings, walk through each one individually with the user (present, propose, confirm, then next); no batch-mode resolution
- `skills/scribe.md` — added No-Action Documentation Rule to `scribe:review`: findings resolved as "no action" must be documented in the relevant file so future reviews don't re-surface them; an undocumented no-action finding is not resolved
- Regenerated all adapter files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `.clinerules`, `.roo/rules/agent.md`)

## [0.10.0] — 2026-03-30

### Added
- `scaffold.json` — manifest declaring scaffold version, core infrastructure files, skills, prompts, and removed files; lives in the template repo only — deleted by `setup.sh` during project setup
- `bin/update` — shell script that pulls scaffold infrastructure updates from the template repo; supports `--yes` (auto-accept new files) and `--core-only` (skip new skills/prompts) flags; uses proper semver comparison via awk; downloads to temp directory with atomic move; configurable upstream URL via `.scaffold-upstream` file; handles deprecated files via manifest `removed` array
- `.scaffold-version` tracking — `setup.sh` now reads the scaffold version from `scaffold.json` and writes it to `.scaffold-version` before deleting the manifest; `bin/update` updates `.scaffold-version` after successful updates
- "Keeping up to date" section in `README.md` documenting `bin/update` usage, update behavior categories, independent version tracks, and custom upstream configuration

### Changed
- `setup.sh` — added `.scaffold-version` creation from `scaffold.json`, `scaffold.json` deletion, and `bin/update` to post-setup summary output
- `README.md` — added `.scaffold-version` and `bin/update` to file tree

## [0.9.0] — 2026-03-30

### Changed
- `project-context.md` is now a generated file — replaced manual-edit instructions with a "generated file" header; content is produced by `context:generate` skill command from the system document, then consumed by `sync.sh`
- `setup.sh` — updated "Next steps" output to direct users to run `context:generate` instead of manually editing `project-context.md`
- `tooling/agent-instructions.md` — added "After any change to `{PROJECT_NAME}.md`" rule requiring agents to run `context:generate` then `sync.sh`; updated Key files table entry for `project-context.md` from "Edit this" to "Generated via context:generate"
- `skills/sync.sh` — updated header comments and fallback message to reflect `project-context.md` is now generated, not manually edited
- `README.md` — updated file tree annotation, mermaid file-category diagram (moved `project-context.md` from "User-edited" to "Generated"), Quick Start step 7, generated files description, and AI tool support section to reflect new `context:generate` workflow
- `CONTRIBUTING.md` — updated "Updating AI tool files" section to reference `context:generate` instead of manual editing
- `tooling/README.md` — updated source files list, architecture diagram, and description to reflect `project-context.md` is generated
- Regenerated all adapter files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `.clinerules`, `.roo/rules/agent.md`)

## [0.8.0] — 2026-03-29

### Changed
- Removed `.cursor/`, `.roo/`, `CLAUDE.md`, and `.clinerules` from git tracking — these are generated files produced by `setup.sh`/`sync.sh` and should not ship in the template; added to `.gitignore`
- Reset `CHANGELOG.md` to a clean template with `{{PROJECT_NAME}}` placeholders for new projects
- Created `.scaffold/` directory to preserve the scaffold's own changelog history (deleted by `setup.sh` during project setup)
- `setup.sh` now resets `VERSION` to `0.1.0` when creating a new project
- `setup.sh` now deletes `.scaffold/` directory during setup
- Removed `CLAUDE.md` from the `FILES` array in `setup.sh` (generated by `sync.sh`, not templated)
- `bin/release` now auto-detects `.scaffold/CHANGELOG.md` and uses it when present; falls back to `CHANGELOG.md` for derived projects
- `tooling/agent-instructions.md` updated to instruct agents to use `.scaffold/CHANGELOG.md` when it exists

## [0.7.5] — 2026-03-29

### Fixed
- `setup.sh` — next-steps output directed users to wrong file for project context (`tooling/agent-instructions.md` instead of `project-context.md`); now correctly says `project-context.md` and includes the `bash skills/sync.sh` reminder
- `setup.sh` — added input validation for `PROJECT_NAME` rejecting spaces, forward slashes, and pipe characters; previously the comment documented this restriction but the code did not enforce it, allowing names that break sed replacements and markdown links
- `README.md` — "Other tools" row in AI tool support table pointed to `CLAUDE.md` (a thin pointer using Claude-specific `@` imports); changed to `tooling/claude.md` which contains the full generated instructions
- `README.md` — corrected claim that adapter files are "always identical in content"; `.cursor/rules/agent.mdc` has MDC frontmatter that other adapters do not
- `README.md` — added `COMMANDS.md` to the file tree (was present in the mermaid diagram and referenced throughout docs but missing from the tree listing)
- `skills/sync.sh` — added optional `[summary]` parameter to `bin/release` in the COMMANDS.md CLI section; the parameter exists in `bin/release` code and header comment but was omitted from the generated reference
- Regenerated all adapter files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`, `.clinerules`, `.roo/rules/agent.md`)

## [0.7.4] — 2026-03-29

### Fixed
- `setup.sh` — added `project-context.md` to FILES array so its `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, and `{{PROJECT_PLATFORM}}` placeholders are replaced during setup (previously left as raw template text, causing broken placeholder output in all generated adapter files)
- `README.md` — added `.clinerules` and `.roo/rules/agent.md` to file tree, mermaid file-category diagram, generated files description, and AI tool support table; added Cline and Roo Code as supported tools; corrected "All three files" → "All adapter files"
- `CONTRIBUTING.md` — added `.clinerules` and `.roo/rules/agent.md` to the list of generated files that must not be edited directly
- `tooling/README.md` — added `.clinerules` and `.roo/rules/agent.md` to the generated files table and architecture diagram
- `skills/sync.sh` — replaced `{{PROJECT_NAME}}` in CLAUDE.md heredoc with generic `# Claude Code` heading to prevent unreplaced placeholder appearing in derived projects
- `CLAUDE.md` — updated heading to match sync.sh change
- `setup.sh` — added `.clinerules` and `.roo/rules/agent.md` to the post-setup summary output under "AI tooling"
- `bin/release` — added comment clarifying that the project .md version replacement uses global sed (all occurrences, not just header)

## [0.7.3] — 2026-03-29

### Changed
- `skills/scribe.md` — excluded `CHANGELOG.md` from `scribe:review` scope; added exclusion note at top of review section and removed it from the Phase 2 documentation file list (changelog is a chronological record, not a behavioral specification — reviewing it for code alignment produces unnecessary noise)
- `skills/sync.sh` — added Cline (`.clinerules`) and Roo Code (`.roo/rules/agent.md`) adapter generation; agent instructions are now surfaced to all supported AI tools automatically

## [0.7.2] — 2026-03-29

### Added
- `PROJECT.md` — living system document template with `{{PROJECT_NAME}}` placeholders and sections for Overview, Architecture, Components, and Data Flow; this is the file `setup.sh` expects and renames to `${PROJECT_NAME}.md` during setup
- Mermaid file-category diagram in `README.md` — visual showing which files are templates, user-edited, generated, and living documents

### Changed
- Renamed `project.md` → `project-context.md` to eliminate case-only confusion with `PROJECT.md`; updated all references in `skills/sync.sh`, `tooling/agent-instructions.md`, `tooling/README.md`, `README.md`, and `CONTRIBUTING.md`
- Regenerated all adapter files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`)

### Fixed
- `skills/scribe.md` — renamed `invoke scribe` command to `scribe:invoke` for consistency with the colon-delimited command pattern; fixes sync.sh parsing bug that stripped internal spaces producing `invokescribe`
- `setup.sh` — replaced inline Copilot/Cursor adapter generation with `bash skills/sync.sh` call; inline generation produced files with raw placeholder comments instead of actual skill/prompt/context content
- `README.md` — replaced all `.cursorrules` references with `.cursor/rules/agent.mdc` (file tree, generated files description, AI tool support table); updated generated files list to include `tooling/claude.md` and `COMMANDS.md` with full source list; updated push command description to reflect `bin/release` automation; added `bin/release`, `prompts/`, and `tooling/` to file tree
- `CONTRIBUTING.md` — replaced `.cursorrules` reference with `.cursor/rules/agent.mdc` in "Updating AI tool files" section
- Regenerated all adapter files (`tooling/claude.md`, `COMMANDS.md`, `.cursor/rules/agent.mdc`, `.github/copilot-instructions.md`)

## [0.7.1] — 2026-03-29

### Fixed
- `README.md` — removed phantom `scribe:review` command from skill commands table (command was removed in 0.3.0 but the README table was never updated); replaced inline commands table with a reference to `COMMANDS.md` to prevent future drift
- `CONTRIBUTING.md` — same phantom `scribe:review` in skill commands table; replaced inline table with reference to `COMMANDS.md`

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
