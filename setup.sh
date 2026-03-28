#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "Project Scaffold Setup"
echo "======================"
echo ""

# ── Collect project info ──────────────────────────────────────────────────────
# Note: PROJECT_NAME must not contain spaces, forward slashes, or pipe characters.
# Spaces break markdown links; slashes and pipes break sed replacements.
read -p "Project name (e.g. EAGLE, Nexus, Atlas): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
  echo "Error: project name cannot be empty."
  exit 1
fi

read -p "One-line description: " PROJECT_DESC
read -p "Platform (e.g. Railway, AWS, Vercel): " PROJECT_PLATFORM
read -p "Author name (for LICENSE): " AUTHOR

echo ""
echo "Project type:"
echo "  1) JavaScript / TypeScript (version also tracked in package.json)"
echo "  2) Other (Python, Go, etc. — VERSION file only)"
read -p "Select [1/2]: " PROJECT_TYPE_INPUT

echo ""

DATE=$(date +%Y-%m-%d)
YEAR=$(date +%Y)

# ── Validate PROJECT.md exists ────────────────────────────────────────────────
if [ ! -f "PROJECT.md" ]; then
  echo "Error: PROJECT.md not found. Run this script from the repo root."
  exit 1
fi

# ── Rename PROJECT.md ─────────────────────────────────────────────────────────
mv PROJECT.md "${PROJECT_NAME}.md"

# ── Replace placeholders in all templated files ───────────────────────────────
# skills/sync.sh is included here so its embedded heredoc has the correct
# project name before it runs and generates CLAUDE.md.
FILES=(
  "${PROJECT_NAME}.md"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  "README.template.md"
  "LICENSE"
  "project.md"
  "skills/scribe.md"
  "skills/sync.sh"
)

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    sed -i.bak \
      -e "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" \
      -e "s|{{PROJECT_DESCRIPTION}}|${PROJECT_DESC}|g" \
      -e "s/{{PROJECT_PLATFORM}}/${PROJECT_PLATFORM}/g" \
      -e "s/{{DATE}}/${DATE}/g" \
      -e "s/{{YEAR}}/${YEAR}/g" \
      -e "s/{{AUTHOR}}/${AUTHOR}/g" \
      "$FILE"
    rm -f "${FILE}.bak"
  fi
done

# ── Swap READMEs: project README replaces the scaffold README ─────────────────
mv README.template.md README.md

# ── JS/TS: remove package.json row from CONTRIBUTING.md if not applicable ─────
if [ "$PROJECT_TYPE_INPUT" != "1" ]; then
  sed -i.bak '/package.json/d' CONTRIBUTING.md && rm -f CONTRIBUTING.md.bak
fi

# ── Generate AI tool files ────────────────────────────────────────────────────
# sync.sh reads skills/*.md and project.md to produce CLAUDE.md, .cursorrules,
# and .github/copilot-instructions.md. Never edit those files directly.
chmod +x skills/sync.sh
bash skills/sync.sh

# ── Summary ───────────────────────────────────────────────────────────────────
echo "Done. ${PROJECT_NAME} is ready."
echo ""
echo "Files:"
echo "  README.md               ← your project README"
echo "  ${PROJECT_NAME}.md      ← fill in your system design"
echo "  project.md              ← add project context for AI tools"
echo "  CONTRIBUTING.md         ← versioning rules and push commands"
echo "  CHANGELOG.md            ← change history, ready to use"
echo "  VERSION                 ← 0.1.0"
echo "  LICENSE                 ← MIT, ${YEAR}, ${AUTHOR}"
echo ""
echo "Generated (never edit directly — run bash skills/sync.sh to update):"
echo "  CLAUDE.md"
echo "  .cursorrules"
echo "  .github/copilot-instructions.md"
echo ""
echo "Next steps:"
echo "  1. Fill in ${PROJECT_NAME}.md with your system design"
echo "  2. Add project context to project.md, then run: bash skills/sync.sh"
if [ "$PROJECT_TYPE_INPUT" = "1" ]; then
  echo "  3. Set \"version\": \"0.1.0\" in your package.json"
fi
echo ""
echo "When ready to commit:"
echo "  git add ."
echo "  git commit -m \"Initial scaffold\""
echo "  git tag -a v0.1.0 -m \"Release v0.1.0 — initial scaffold\""
echo "  git push origin main"
echo ""
echo "  If no remote is configured yet (fresh git init):"
echo "    git remote add origin <your-repo-url>"
echo "    git push -u origin main"
echo ""

# ── Self-cleanup ──────────────────────────────────────────────────────────────
rm -- "$0"
