# Contributing to {{PROJECT_NAME}}

This document defines how {{PROJECT_NAME}} is versioned, released, and maintained. These rules apply to all changes — documentation, configuration, and code.

---

## Versioning

{{PROJECT_NAME}} uses Semantic Versioning (`MAJOR.MINOR.PATCH`).

### When to bump

| Change | Bump | Example |
|---|---|---|
| Bug fix, typo, small correction | PATCH | `0.1.1` → `0.1.2` |
| New feature or section, nothing breaks | MINOR | `0.1.2` → `0.2.0` |
| Breaking architectural change | MAJOR | `0.2.0` → `1.0.0` |

New projects start at `0.1.0`.

### Where the version lives

The version must be identical in every location it appears. Updating one means updating all.

| Location | Notes |
|---|---|
| `VERSION` | Repo root. Canonical source of truth. Always present. |
| `{{PROJECT_NAME}}.md` header | Always matches `VERSION`. |
| `CHANGELOG.md` | Every release entry carries the version. |
| `package.json` | JS/TS projects only. `"version"` field must match `VERSION`. |
| Git tag | `vX.Y.Z` applied at every release. |
| GitHub Release | Created from the git tag. |

---

## Release Process

When a change is complete, follow these steps in order. Do not skip steps.

**1. Bump the version** in all locations listed above.

**2. Update `CHANGELOG.md`** — move staged changes from `[Unreleased]` into a new versioned entry with today's date.

**3. Tag the release:**

```
git tag -a vX.Y.Z -m "Release vX.Y.Z — <one line summary>"
git push origin vX.Y.Z
```

**4. Create a GitHub Release** using that tag. Use the `CHANGELOG.md` entry for that version as the release notes.

---

## Reminders

These rules apply in every session, without exception.

- If the words **"ship it"**, **"done"**, **"merge this"**, or **"push this"** appear — stop and confirm the full release checklist has been completed before proceeding.
- Whenever a file is edited that changes the version, always show the exact `git tag` command to run next.
- Never skip a version bump silently. Always state what the new version should be and why.
