<!-- GENERATED FILE — do not edit manually. -->
<!-- Edit tooling/agent-instructions.md, then run `bash skills/sync.sh` to regenerate. -->


# {{PROJECT_NAME}} — Agent Instructions

You are working on {{PROJECT_NAME}}. Read `{{PROJECT_NAME}}.md` before making any changes.
It is the source of truth for what this system is and how it is structured.
If something about the system is unclear, read that file before making assumptions.

---

## Session start

Before any other action:

1. Read `{{PROJECT_NAME}}.md` — understand the current system state.
2. Read the version from `VERSION` and confirm it aloud: "Ready. Current version: X.Y.Z."

---

## Mandatory: Changelog tracking

These rules apply to every session and every change without exception.

### On any file change

1. Add an entry to the `[Unreleased]` section of `CHANGELOG.md` describing what changed and why. Never leave a change undocumented.
2. Do **not** bump the version number on individual changes — version bumping happens only when a push command is issued.

---

## Versioning and push commands

Use one of these commands when you are ready to commit and push.
Never use bare "push" — it will be rejected until a qualifier is given.

| Command | Bump | Example |
| --- | --- | --- |
| `push:breaking` | Major | `0.1.0 → 1.0.0` |
| `push:new` | Minor | `0.1.0 → 0.2.0` |
| `push:fix` | Patch | `0.1.0 → 0.1.1` |

### When a push command is detected

Present a **single confirmation prompt** containing all of the following, then stop and wait for one explicit "yes" before proceeding:

1. The current version and the new version: "Current version is X.Y.Z. This will become A.B.C."
2. The `[Unreleased]` entries that will be moved into the new versioned section.
3. State that `bin/release` will handle everything: version bump, changelog update, git commit, tag, push, and GitHub release.

**After receiving confirmation, run `bin/release` as a single command.** Map the push command to the release type:

| Push command | Release command |
| --- | --- |
| `push:fix` | `bin/release patch` |
| `push:new` | `bin/release minor` |
| `push:breaking` | `bin/release major` |

Do not manually edit VERSION, CHANGELOG.md, or run git commands — `bin/release` does all of this. Execute it as one command and report the result. No further prompts or pauses after confirmation.

If "push" appears without a qualifier, respond: "Which type — `push:breaking`, `push:new`, or `push:fix`? See `CONTRIBUTING.md` for the decision tree." Do not proceed without a qualified command.

### Never

- Never make a change without updating `CHANGELOG.md` `[Unreleased]`
- Never bump the version without an explicit push command
- Never let version numbers drift out of sync across files
- Never act without stating what will happen first

---

## Skill commands

| Command | What it does |
| --- | --- |
| `scribe:document` | Document a new component, module, or system |
| `scribe:update` | Update existing documentation in place |
| `scribe:review` | Full top-down codebase and documentation alignment review |
| `invokescribe` | Activate for any documentation task |

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

### `/doublecheck`

Did you read all the docs? Did you read all the relevant code?

Double-check your work. No shortcuts. You are absolutely FORBIDDEN from operating on assumptions.

Dont be lazy. Are you using best practices? Are you following the SOLID / FAIL FAST principles? No "quick fixes" I want long term, scalable solutions. Did you review the chat history to make sure you are not trying something you already tried? if you have a question, you stop and ask for clarification

I do not want any left over code that is no longer used. I also do not want to maintain any backwards compatibility UNLESS I explicitly say so. Skip testing. Continue referring and RESPECTING the patterns described in the relevant docs

### `/proceed`

Proceed. Make sure to include detailed JSDOCs. I want you to work systematically on this. Create a todo list and track your progress.

You must ALWAYS use SOLID / FAIL FAST principles and work the problem systematically. Start high level. No guesswork. No assumptions. READ the code. You are FORBIDDEN from using any type of lint ignore or disable language. Ultra think this. Do not include or add any test scripts. do NOT rely on code comments soley! look at the code first, then the documentation, then the code comments. In that specific order. if threre is misalignment - you stop and ask for clarity.

No "quick fixes" or workarounds.

Continue referring and RESPECTING the patterns described in the relevant docs

If updates to the documentation are necessary, do so carefully and thoughtfully. We dont need detailed examples. We need to focus on high level and specifics but not actual examples.

No assumptions should be made in the docs. Do NOT add transitory information like migration patterns and other details that are not long term. Do NOT be lazy.

I do not want any left over code that is no longer used. I also do not want to maintain any backwards compatibility UNLESS I explicitly say so. Skip testing. I dont want any prisma migrations. I will handle any prisma generate or db push commands.

Do not run any build commands. I will do this. Skip introductions. Skip conclusions. Skip context I already know.

---

## Key files

| File | Purpose |
|---|---|
| `{{PROJECT_NAME}}.md` | Living system document — current state of the system |
| `CHANGELOG.md` | Chronological record of every change |
| `CONTRIBUTING.md` | Versioning rules, push commands, decision tree |
| `VERSION` | Canonical version number |
| `COMMANDS.md` | All available commands — generated by `bash skills/sync.sh` |
| `project.md` | Edit this to update AI tool context, then run `bash skills/sync.sh` |
| `bin/release` | Automated release script — run by agents after push command confirmation |
| `skills/sync.sh` | Run this after adding or changing a skill |
| `prompts/` | Prompt macro definitions — edit these, then run `bash skills/sync.sh` |
| `docs/` | Project documentation — grows with the project |

---

## Project context

**{{PROJECT_NAME}}:** {{PROJECT_DESCRIPTION}}
**Platform:** {{PROJECT_PLATFORM}}

---

[Replace this section with context for your AI tools. Include:
- What the system does in 2-3 sentences
- Key constraints or design decisions that must not be reversed
- Anything the tool should know before making changes
- External dependencies or integrations worth flagging

This file is injected into agent instructions every time `bash skills/sync.sh` runs.
Edit it freely — it is the one file in this system you are meant to change.]
