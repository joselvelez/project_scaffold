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

if [[ "$PROJECT_NAME" =~ [[:space:]/\|] ]]; then
  echo "Error: project name must not contain spaces, forward slashes, or pipe characters."
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

FILES=(
  "${PROJECT_NAME}.md"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  "COMMANDS.md"
  "README.template.md"
  "LICENSE"
  "skills/scribe.md"
  "tooling/agent-instructions.md"
  "project-context.md"
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

# ── Create docs directory ──────────────────────────────────────────────────────

mkdir -p docs
cat > docs/README.md << 'DOCS_README'
# Documentation

This directory is yours. The scaffold has no opinion on how you organise it or what you put in it — structure it however makes sense for your project.

For AI tool instructions and command references, see [`tooling/`](../tooling/).
DOCS_README

# ── Swap READMEs: project README replaces the scaffold README ─────────────────

mv README.template.md README.md

# ── JS/TS: handle package.json ────────────────────────────────────────────────

if [ "$PROJECT_TYPE_INPUT" = "1" ]; then
  if [ -f "package.json" ]; then
    # Update existing package.json version to 0.1.0
    sed -i.bak 's/"version":[[:space:]]*"[^"]*"/"version": "0.1.0"/' package.json && rm -f package.json.bak
    echo "  ✓ Updated package.json version to 0.1.0"
  else
    # Create a minimal package.json
    cat > package.json << PKGJSON
{
  "name": "$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')",
  "version": "0.1.0",
  "private": true
}
PKGJSON
    echo "  ✓ Created package.json with version 0.1.0"
  fi
else
  sed -i.bak '/package.json/d' CONTRIBUTING.md && rm -f CONTRIBUTING.md.bak
fi

# ── Reset VERSION for new project ─────────────────────────────────────────────

echo "0.1.0" > VERSION

# ── Write .scaffold-version from scaffold.json ────────────────────────────────

if [ -f "scaffold.json" ]; then
  SCAFFOLD_VERSION=$(awk -F'"' '/"version"/ { print $4; exit }' scaffold.json)
  echo "$SCAFFOLD_VERSION" > .scaffold-version
fi

# ── Remove scaffold development files ─────────────────────────────────────────

rm -rf .scaffold
rm -f scaffold.json

# ── Generate tool-specific adapter files ─────────────────────────────────────

bash skills/sync.sh

# ── Self-cleanup (before git so the deletion is captured in the commit) ───────

SELF="$0"
rm -- "$SELF"

# ── Verify git remote ────────────────────────────────────────────────────────

if ! git remote get-url origin >/dev/null 2>&1; then
  echo ""
  echo "Error: no git remote 'origin' is configured."
  echo ""
  echo "Add a remote and run the initial commit manually:"
  echo "  git remote add origin <your-repo-url>"
  echo "  git add ."
  echo "  git commit -m \"Initial scaffold\""
  echo "  git tag -a v0.1.0 -m \"Release v0.1.0 — initial scaffold\""
  echo "  git push -u origin main"
  exit 1
fi

# ── Initial commit, tag, and push ─────────────────────────────────────────────

echo ""
echo "Committing and pushing initial scaffold..."

git add .
git commit -m "Initial scaffold"
git tag -a v0.1.0 -m "Release v0.1.0 — initial scaffold"
git push origin main
git push origin v0.1.0

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "Done. ${PROJECT_NAME} is ready."
echo ""
echo "Next steps:"
echo "  1. Fill in ${PROJECT_NAME}.md with your system design"
echo "  2. Run context:generate in your AI tool to generate project-context.md from ${PROJECT_NAME}.md"
echo ""
