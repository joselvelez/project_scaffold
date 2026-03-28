#!/usr/bin/env bash
# skills/sync.sh
#
# Regenerates tooling/agent-instructions.md, COMMANDS.md,
# .cursor/rules/agent.mdc, and .github/copilot-instructions.md
# from skills/*.md, prompts/*.md, and project.md.
#
# Run this after adding or modifying a skill or prompt macro:
#   bash skills/sync.sh
#
# Do not edit tooling/agent-instructions.md, COMMANDS.md,
# .cursor/rules/agent.mdc, or .github/copilot-instructions.md directly.
# They will be overwritten the next time this script runs.
#
# CLAUDE.md (root) is a permanent thin pointer — this script never touches it.

set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SKILLS_DIR")"
TOOLING_DIR="$ROOT/tooling"
PROMPTS_DIR="$ROOT/prompts"
OUT="$TOOLING_DIR/claude.md"
COMMANDS_OUT="$ROOT/COMMANDS.md"
PROJECT_CONTEXT="$ROOT/project.md"

mkdir -p "$TOOLING_DIR"
mkdir -p "$ROOT/.cursor/rules"
mkdir -p "$ROOT/.github"

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
# Parse prompt macro files from prompts/*.md.
# Expected format in each prompts/*.md file:
#
#   # /trigger
#
#   <expansion text — everything after the heading>
#
# ---------------------------------------------------------------------------

# Build a summary table of prompt macros (trigger + first line as description)
build_prompts_table() {
  local found_any=false

  for prompt_file in "$PROMPTS_DIR"/*.md; do
    [[ -f "$prompt_file" ]] || continue

    local trigger=""
    local first_body_line=""
    local past_heading=false

    while IFS= read -r line; do
      if [[ -z "$trigger" ]] && [[ "$line" =~ ^#[[:space:]]+(/.+) ]]; then
        trigger="${BASH_REMATCH[1]}"
        continue
      fi
      if [[ -n "$trigger" ]] && $past_heading && [[ -n "$line" ]]; then
        first_body_line="$line"
        break
      fi
      if [[ -n "$trigger" ]] && [[ -z "$line" ]]; then
        past_heading=true
      fi
    done < "$prompt_file"

    if [[ -n "$trigger" ]]; then
      echo "| \`$trigger\` | ${first_body_line:-(no description)} |"
      found_any=true
    fi
  done

  if ! $found_any; then
    echo "| _(no prompt macros installed)_ | — |"
  fi
}

# Build the full prompt macros section with trigger headings and expansion text
build_prompts_section() {
  local found_any=false

  for prompt_file in "$PROMPTS_DIR"/*.md; do
    [[ -f "$prompt_file" ]] || continue

    local trigger=""
    local body=""
    local past_heading=false

    while IFS= read -r line; do
      if [[ -z "$trigger" ]] && [[ "$line" =~ ^#[[:space:]]+(/.+) ]]; then
        trigger="${BASH_REMATCH[1]}"
        continue
      fi
      if [[ -n "$trigger" ]]; then
        if [[ -z "$line" ]] && ! $past_heading; then
          past_heading=true
          continue
        fi
        if $past_heading; then
          body+="$line"$'\n'
        fi
      fi
    done < "$prompt_file"

    if [[ -n "$trigger" ]]; then
      echo "### \`$trigger\`"
      echo ""
      echo "$body"
      found_any=true
    fi
  done

  if ! $found_any; then
    echo "_No prompt macros installed. Add a file to \`prompts/\` and run \`bash skills/sync.sh\`._"
  fi
}

# ---------------------------------------------------------------------------
# Write tooling/claude.md
# ---------------------------------------------------------------------------
cat > "$OUT" << 'STATIC_HEADER'
<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to regenerate after adding or changing a skill. -->

# {{PROJECT_NAME}} — Agent Instructions

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
5. Provide the exact three-command release sequence. Extract the release notes from the versioned entry just written to `CHANGELOG.md` and populate them inline — do not leave placeholders:
   ```
   git tag -a vX.Y.Z -m "Release vX.Y.Z — <one line summary>"
   git push origin vX.Y.Z
   gh release create vX.Y.Z --title "vX.Y.Z — <one line summary>" --notes "<changelog entry for this version>"
   ```

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

cat >> "$OUT" << 'SKILL_FOOTER'

When a skill command is detected:

1. Read the corresponding file in `skills/`.
2. Adopt its identity, rules, and output standards for the duration of that task.
3. Announce: "Invoking [Skill] — operating under `skills/[file].md`."

Skill commands are the only way to invoke a skill. There are no automatic triggers.
If a skill command is unrecognised, list available commands from the table above.

---

## Prompt macros

Prompt macros are shorthand triggers that expand into predefined text. When a user's message ends with a prompt macro trigger (e.g. `/doublecheck`), treat the message as if the full expansion text below was appended to it.

**Rules:**
- The trigger must appear at the end of the user's message
- Append the expansion text to the user's original message — do not replace it
- Follow every instruction in the expanded text for the duration of that response

SKILL_FOOTER

# Append the generated prompt macros section
build_prompts_section >> "$OUT"

cat >> "$OUT" << 'STATIC_FOOTER'

---

## Key files

| File | Purpose |
| --- | --- |
| `{{PROJECT_NAME}}.md` | Living system document — current state of the system |
| `CHANGELOG.md` | Chronological record of every change |
| `CONTRIBUTING.md` | Versioning rules, push commands, decision tree |
| `VERSION` | Canonical version number |
| `COMMANDS.md` | All available commands — generated by `bash skills/sync.sh` |
| `project.md` | Edit this to update AI tool context, then run `bash skills/sync.sh` |
| `skills/sync.sh` | Run this after adding or changing a skill |
| `prompts/` | Prompt macro definitions — edit these, then run `bash skills/sync.sh` |
| `docs/` | Project documentation — grows with the project |

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
# Write COMMANDS.md — human-readable command reference, generated from skills
# ---------------------------------------------------------------------------
cat > "$COMMANDS_OUT" << 'COMMANDS_HEADER'
<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to regenerate after adding or changing a skill. -->

# Command Reference

Commands are natural language trigger phrases recognised by any AI tool working in this project. All tools read the same instructions and respond to the same commands.

---

## push: — Release

| Command | What it does |
| --- | --- |
| `push:fix` | Patch version bump + release checklist |
| `push:new` | Minor version bump + release checklist |
| `push:breaking` | Major version bump + release checklist |

---

## Skills

COMMANDS_HEADER

# Append the generated skill commands table
echo "| Command | What it does |" >> "$COMMANDS_OUT"
echo "| --- | --- |" >> "$COMMANDS_OUT"
build_commands_table >> "$COMMANDS_OUT"

cat >> "$COMMANDS_OUT" << 'COMMANDS_PROMPTS_HEADER'

---

## Prompt Macros

Shorthand triggers appended to the end of a message. The AI tool expands them into predefined instructions.

COMMANDS_PROMPTS_HEADER

# Append the prompt macros summary table
echo "| Trigger | Expands to |" >> "$COMMANDS_OUT"
echo "| --- | --- |" >> "$COMMANDS_OUT"
build_prompts_table >> "$COMMANDS_OUT"

# Append full expansion text for reference
echo "" >> "$COMMANDS_OUT"
echo "### Full expansion text" >> "$COMMANDS_OUT"
echo "" >> "$COMMANDS_OUT"
build_prompts_section >> "$COMMANDS_OUT"

cat >> "$COMMANDS_OUT" << 'COMMANDS_FOOTER'

---

## CLI

Read-only commands can be run directly from the terminal without an AI agent:

```
bin/project status     # version, last release, unreleased changes
bin/project commands   # display this reference
bin/project help       # usage information
```

---

## Adding commands

Add a `## Commands` table to any skill file in `skills/`. Run `bash skills/sync.sh` to register them here and in all tool adapter files.

## Adding prompt macros

Add a markdown file to `prompts/` with a `# /trigger` heading followed by the expansion text. Run `bash skills/sync.sh` to register them.
COMMANDS_FOOTER

# ---------------------------------------------------------------------------
# Generate .cursor/rules/agent.mdc — Cursor requires MDC frontmatter
# alwaysApply: true loads these rules for every session in this project
# ---------------------------------------------------------------------------
{
  printf -- '---\ndescription: Project agent instructions and command reference\nalwaysApply: true\n---\n\n'
  cat "$OUT"
} > "$ROOT/.cursor/rules/agent.mdc"

# ---------------------------------------------------------------------------
# Generate .github/copilot-instructions.md — full self-contained file
# (Copilot does not support file imports)
# ---------------------------------------------------------------------------
cp "$OUT" "$ROOT/.github/copilot-instructions.md"

# ---------------------------------------------------------------------------
# Restore root CLAUDE.md — always overwrite to prevent accidental edits
# from drifting. This is the canonical thin pointer; content never lives here.
# ---------------------------------------------------------------------------
cat > "$ROOT/CLAUDE.md" << 'CLAUDE_POINTER'
<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to restore if modified. -->

# {{PROJECT_NAME}} — Claude Code

@tooling/claude.md
@COMMANDS.md
CLAUDE_POINTER

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
skill_count=$(find "$SKILLS_DIR" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
cmd_count=$(build_commands_table | grep -c "^\| \`" || true)
prompt_count=$(find "$PROMPTS_DIR" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "✓  tooling/claude.md regenerated"
echo "✓  COMMANDS.md updated"
echo "✓  .cursor/rules/agent.mdc updated"
echo "✓  .github/copilot-instructions.md updated"
echo "✓  CLAUDE.md (root) restored to thin pointer"
echo "   Skills loaded: $skill_count"
echo "   Commands registered: $cmd_count"
echo "   Prompt macros registered: $prompt_count"
echo ""
