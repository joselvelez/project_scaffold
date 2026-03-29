#!/usr/bin/env bash
# skills/sync.sh
#
# Reads tooling/agent-instructions.md as the canonical template and generates
# tool-specific adapter files by replacing placeholder comment lines with
# dynamic content aggregated from skills/*.md, prompts/*.md, and project-context.md.
#
# Run this after adding or modifying a skill, prompt macro, or agent instruction:
#   bash skills/sync.sh
#
# Source files (edit these):
#   tooling/agent-instructions.md  — agent behaviour (the template)
#   project-context.md                     — project-specific context
#   skills/*.md                    — skill definitions with ## Commands tables
#   prompts/*.md                   — prompt macro definitions
#
# Generated files (do not edit):
#   tooling/claude.md
#   COMMANDS.md
#   CLAUDE.md
#   .cursor/rules/agent.mdc
#   .github/copilot-instructions.md
#   .clinerules
#   .roo/rules/agent.md
#
# CLAUDE.md (root) is a permanent thin pointer — this script always restores it.

set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$SKILLS_DIR")"
TOOLING_DIR="$ROOT/tooling"
PROMPTS_DIR="$ROOT/prompts"
AGENT_INSTRUCTIONS="$TOOLING_DIR/agent-instructions.md"
OUT="$TOOLING_DIR/claude.md"
COMMANDS_OUT="$ROOT/COMMANDS.md"
PROJECT_CONTEXT="$ROOT/project-context.md"

mkdir -p "$TOOLING_DIR"
mkdir -p "$ROOT/.cursor/rules"
mkdir -p "$ROOT/.github"
mkdir -p "$ROOT/.roo/rules"

# ── Guards ────────────────────────────────────────────────────────────────────

if [[ ! -f "$AGENT_INSTRUCTIONS" ]]; then
  echo "Error: $AGENT_INSTRUCTIONS not found." >&2
  exit 1
fi

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
# Build the dynamic content for each placeholder
# ---------------------------------------------------------------------------

build_skill_commands_replacement() {
  echo "| Command | What it does |"
  echo "| --- | --- |"
  build_commands_table
  echo ""
  echo "When a skill command is detected:"
  echo ""
  echo "1. Read the corresponding file in \`skills/\`."
  echo "2. Adopt its identity, rules, and output standards for the duration of that task."
  echo "3. Announce: \"Invoking [Skill] — operating under \`skills/[file].md\`.\""
  echo ""
  echo "Skill commands are the only way to invoke a skill. There are no automatic triggers."
  echo "If a skill command is unrecognised, list available commands from the table above."
}

build_prompt_macros_replacement() {
  echo "Prompt macros are shorthand triggers that expand into predefined text. When a user's message ends with a prompt macro trigger (e.g. \`/doublecheck\`), treat the message as if the full expansion text below was appended to it."
  echo ""
  echo "**Rules:**"
  echo "- The trigger must appear at the end of the user's message"
  echo "- Append the expansion text to the user's original message — do not replace it"
  echo "- Follow every instruction in the expanded text for the duration of that response"
  echo ""
  build_prompts_section
}

build_project_context_replacement() {
  if [[ -f "$PROJECT_CONTEXT" ]]; then
    cat "$PROJECT_CONTEXT"
  else
    echo "_No project context yet. Edit \`project-context.md\` to add it, then run \`bash skills/sync.sh\`._"
  fi
}

# ---------------------------------------------------------------------------
# Write tooling/claude.md — read template, replace placeholders
# ---------------------------------------------------------------------------

# Pre-build replacement content into temp files for reliable substitution
SKILL_CONTENT=$(build_skill_commands_replacement)
PROMPT_CONTENT=$(build_prompt_macros_replacement)
CONTEXT_CONTENT=$(build_project_context_replacement)

{
  echo "<!-- GENERATED FILE — do not edit manually. -->"
  echo "<!-- Edit tooling/agent-instructions.md, then run \`bash skills/sync.sh\` to regenerate. -->"
  echo ""

  # Read the template, stripping the source-file HTML comment block and
  # replacing placeholder lines with dynamic content
  in_header_comment=false
  while IFS= read -r line; do
    # Skip the source-file header comment (<!-- ... -->)
    if [[ "$line" == "<!--" ]]; then
      in_header_comment=true
      continue
    fi
    if $in_header_comment; then
      if [[ "$line" == "-->" ]]; then
        in_header_comment=false
      fi
      continue
    fi

    # Replace placeholder lines
    if [[ "$line" == "<!-- {{SKILL_COMMANDS}} -->" ]]; then
      echo "$SKILL_CONTENT"
    elif [[ "$line" == "<!-- {{PROMPT_MACROS}} -->" ]]; then
      echo "$PROMPT_CONTENT"
    elif [[ "$line" == "<!-- {{PROJECT_CONTEXT}} -->" ]]; then
      echo "$CONTEXT_CONTENT"
    else
      echo "$line"
    fi
  done < "$AGENT_INSTRUCTIONS"
} > "$OUT"

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
bin/release <type>     # run a release (major, minor, patch)
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
# Generate .clinerules — Cline auto-loads this from the project root
# ---------------------------------------------------------------------------
cp "$OUT" "$ROOT/.clinerules"

# ---------------------------------------------------------------------------
# Generate .roo/rules/agent.md — Roo Code auto-loads rules from .roo/rules/
# ---------------------------------------------------------------------------
cp "$OUT" "$ROOT/.roo/rules/agent.md"

# ---------------------------------------------------------------------------
# Restore root CLAUDE.md — always overwrite to prevent accidental edits
# from drifting. This is the canonical thin pointer; content never lives here.
# ---------------------------------------------------------------------------
cat > "$ROOT/CLAUDE.md" << 'CLAUDE_POINTER'
<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to restore if modified. -->

# Claude Code

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
echo "✓  tooling/claude.md regenerated (from tooling/agent-instructions.md)"
echo "✓  COMMANDS.md updated"
echo "✓  .cursor/rules/agent.mdc updated"
echo "✓  .github/copilot-instructions.md updated"
echo "✓  .clinerules updated"
echo "✓  .roo/rules/agent.md updated"
echo "✓  CLAUDE.md (root) restored to thin pointer"
echo "   Skills loaded: $skill_count"
echo "   Commands registered: $cmd_count"
echo "   Prompt macros registered: $prompt_count"
echo ""
