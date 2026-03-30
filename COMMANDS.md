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

| Command | What it does |
| --- | --- |
| `scribe:document` | Document a new component, module, or system |
| `scribe:update` | Update existing documentation in place |
| `scribe:review` | Full top-down codebase and documentation alignment review |
| `scribe:invoke` | Activate for any documentation task |

---

## Prompt Macros

Shorthand triggers appended to the end of a message. The AI tool expands them into predefined instructions.

| Trigger | Expands to |
| --- | --- |
| `/proceed` | Review the relevant documentation (the project README.md file as well as any docs within the /docs directory). |
| `/doublecheck` | Did you read all the docs? Did you read all the relevant code? |
| `/proceed` | Proceed. Make sure to include detailed JSDOCs. I want you to work systematically on this. Create a todo list and track your progress. |

### Full expansion text

### `/proceed`

Review the relevant documentation (the project README.md file as well as any docs within the /docs directory).

Be methodical and systematic. No Assumptions. Do not use logging. Do not be lazy.

Read the code and ask questions if you need clarity. Work the problem systematically. Start high level. No guesswork. No assumptions.

Do NOT rely on code comments soley! look at the code first, then the documentation, then the code comments. In that specific order. if threre is misalignment - you stop and ask for clarity.

Your workflow MUST BE AS FOLLOWS: Read the documentation FIRST. Then check the code. If the code does not align with the documentation, we have a problem. Stop there to discuss and address.

No console logging instead of actually reading the code.  No hacks or quick fixes. You are EXPLICITLY FORBIDDEN from doing anything UNTIL you read the documentation. Ultra think this.

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

## CLI

Read-only commands can be run directly from the terminal without an AI agent:

```
bin/project status     # version, last release, unreleased changes
bin/project commands   # display this reference
bin/project help       # usage information
bin/release <type> [summary]  # run a release (major, minor, patch)
```

---

## Adding commands

Add a `## Commands` table to any skill file in `skills/`. Run `bash skills/sync.sh` to register them here and in all tool adapter files.

## Adding prompt macros

Add a markdown file to `prompts/` with a `# /trigger` heading followed by the expansion text. Run `bash skills/sync.sh` to register them.
