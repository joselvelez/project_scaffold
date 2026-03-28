<!-- GENERATED FILE — do not edit manually. -->
<!-- Run `bash skills/sync.sh` to regenerate after adding or changing a skill. -->

# Command Reference

Commands are natural language trigger phrases recognised by any AI tool working in this project. All tools read the same instructions and respond to the same commands.

---

## project: — Project

| Command | What it does |
| --- | --- |
| `project:commands` | Display this reference |
| `project:status` | Show current version, last changelog entry, and any unreleased changes |
| `push:fix` | Patch version bump + release checklist |
| `push:new` | Minor version bump + release checklist |
| `push:breaking` | Major version bump + release checklist |

---

## Skills

| Command | What it does |
| --- | --- |
| `scribe:document` | Document a new component, module, or system |
| `scribe:update` | Update existing documentation in place |
| `scribe:adr` | Write an architectural decision record |
| `invokescribe` | Activate for any documentation task |

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
