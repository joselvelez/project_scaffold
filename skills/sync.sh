#!/usr/bin/env bash
# skills/sync.sh
#
# Regenerates CLAUDE.md, .cursorrules, and .github/copilot-instructions.md
# from skills/*.md and project.md.
#
# Run this after adding or modifying a skill:
#   bash skills/sync.sh
#
# Never edit CLAUDE.md, .cursorrules, or copilot-instructions.md directly.
# They will be overwritten the next time this script runs.

set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SKILLS_DIR")"
OUT="$ROOT/CLAUDE.md"
PROJECT_CONTEXT="$ROOT/project.md"

# ---------------------------------------------------------------------------
# Parse ## Commands tables from each skill file.
# Expected format in each skills/*.md file:
#
#   ## Commands
#   | Command | Description |
#   |---|---|
#   | `skill:action` | What it does |
#
# ---------------------------------------------------------------------------
build_commands_table() {
  local in_commands=false
  local found_any=false

  for skill_file in "$SKILLS_DIR"/*.md; do
    [[ -f "$skill_file" ]] || continue

    in_commands=false
    while IFS= read -r line; do
      if [[ "$line" =~ ^##[[:space:]]Commands ]]; then
        in_commands=true
        continue
      fi
      # Stop at the next section heading
      if $in_commands && [[ "$line" =~ ^## ]]; then
        break
      fi
      # Match data rows: lines starting with | ` (skips header and separator rows)
      if $in_commands && [[ "$line" =~ ^\|[[:space:]]\` ]]; then
        cmd=$(echo "$line" | awk -F'|' '{gsub(/[`[:space:]]/, "", $2); print $2}')
        desc=$(echo "$line" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3}')
        if [[ -n "$cmd" ]]; then
          echo "| \`$cmd\` | $desc |"
          found_any=true
        fi
      fi
    done < "$skill_file"
  done

  if ! $found_any; then
    echo "| _(no skills installed)_ | — |"
  fi
}

# ---------------------------------------------------------------------------
# Write CLAUDE.md
# ---------------------------------------------------------------------------
cat > "$OUT" << 'STATIC_HEADER'
<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to regenerate after adding or changing a skill. -->

# {{PROJECT_NAME}} — AI Agent Instructions

You are working on {{PROJECT_NAME}}. Read `{{PROJECT_NAME}}.md` before making any changes.
It is the source of truth for what this system is and how it is structured.

---

## Session start

Before any other action:

1. Read `{{PROJECT_NAME}}.md` — understand the current system state.
2. Read the version from `VERSION` and confirm it aloud: "Ready. Current version: X.Y.Z."

---

## Versioning and push commands

Use one of these commands when you are ready to commit and push.
Never use bare "push" — it will be rejected until a qualifier is given.

| Command | Bump | Example |
| --- | --- | --- |
| `push:breaking` | Major | `0.1.0 → 1.0.0` |
| `push:new` | Minor | `0.1.0 → 0.2.0` |
| `push:fix` | Patch | `0.1.0 → 0.1.1` |

When a push command is detected:

1. State: "Current version is X. This will become Y."
2. Wait for explicit confirmation before changing any file.
3. Bump the version in all required locations: `VERSION`, `{{PROJECT_NAME}}.md` header, `package.json` (if it exists).
4. Update `CHANGELOG.md` — move `[Unreleased]` into a new versioned section with today's date.
5. Provide the exact tag command:
   ```
   git tag -a vX.Y.Z -m "Release vX.Y.Z — <one line summary>"
   git push origin vX.Y.Z
   ```
6. Remind to create a GitHub Release from that tag using the `CHANGELOG.md` entry as release notes.

If "push" appears without a qualifier, respond: "Which type — `push:breaking`, `push:new`, or `push:fix`?
See `CONTRIBUTING.md` for the decision tree." Do not proceed without a qualified command.

**Never:**
- Touch any file without updating `CHANGELOG.md [Unreleased]`
- Bump the version without an explicit push command
- Let version numbers drift out of sync across files
- Act without stating what will happen first

---

## Skill commands

STATIC_HEADER

# Append the generated commands table
echo "| Command | What it does |" >> "$OUT"
echo "| --- | --- |" >> "$OUT"
build_commands_table >> "$OUT"

cat >> "$OUT" << 'STATIC_FOOTER'

When a skill command is detected:

1. Read the corresponding file in `skills/`.
2. Adopt its identity, rules, and output standards for the duration of that task.
3. Announce: "Invoking [Skill] — operating under `skills/[file].md`."

Skill commands are the only way to invoke a skill. There are no automatic triggers.
If a skill command is unrecognised, list available commands from the table above.

---

## Key files

| File | Purpose |
| --- | --- |
| `{{PROJECT_NAME}}.md` | Living system document — current state of the system |
| `CHANGELOG.md` | Chronological record of every change |
| `CONTRIBUTING.md` | Versioning rules, push commands, decision tree |
| `VERSION` | Canonical version number |
| `project.md` | Edit this to update AI tool context, then run `bash skills/sync.sh` |
| `skills/sync.sh` | Run this after adding or changing a skill |
| `assets/semver-decision-tree.svg` | Visual guide to choosing the right push command |

---

## Project context

STATIC_FOOTER

# Append the user's project context (or a placeholder if missing)
if [[ -f "$PROJECT_CONTEXT" ]]; then
  cat "$PROJECT_CONTEXT" >> "$OUT"
else
  cat >> "$OUT" << 'NO_CONTEXT'
_No project context yet. Edit `project.md` to add it, then run `bash skills/sync.sh`._
NO_CONTEXT
fi

# ---------------------------------------------------------------------------
# Copy to other tool files
# ---------------------------------------------------------------------------
cp "$OUT" "$ROOT/.cursorrules"
mkdir -p "$ROOT/.github"
cp "$OUT" "$ROOT/.github/copilot-instructions.md"

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
skill_count=$(find "$SKILLS_DIR" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
cmd_count=$(build_commands_table | grep -c "^\| \`" || true)

echo ""
echo "✓  CLAUDE.md regenerated"
echo "✓  .cursorrules updated"
echo "✓  .github/copilot-instructions.md updated"
echo "   Skills loaded: $skill_count"
echo "   Commands registered: $cmd_count"
echo ""
