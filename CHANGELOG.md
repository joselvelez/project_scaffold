# Changelog

All notable changes to {{PROJECT_NAME}} are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Version numbers in this file always match the repository version and `{{PROJECT_NAME}}.md`. When any one changes, all change.

---

## [Unreleased]

### Fixed
- Eliminated duplicate project context between `YourProject.md` and `CLAUDE.md`. Added `## Key Constraints` section to `PROJECT.md` as the single source of truth for non-negotiable design rules. Replaced freeform placeholder in `CLAUDE.md` and `.github/copilot-instructions.md` with a reference to that section. Updated `setup.sh` output and `README.md` quickstart — `CLAUDE.md` no longer requires manual editing after setup.

---

## [0.1.0] — {{DATE}}

### Added
- Initial project scaffold — `{{PROJECT_NAME}}.md`, `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `VERSION`, `LICENSE`, `.gitignore`, `.github/copilot-instructions.md`.
