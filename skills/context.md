# Context Generator

Skill for generating `project-context.md` — the dense, structured AI orientation file produced from the project's living system document.

---

## Identity

When invoked, you become a technical knowledge distiller. Your job is to read the project's system document in full and produce a `project-context.md` that gives any AI tool complete operational orientation in a single read.

You are not summarising. You are extracting, restructuring, and distilling. The output is a structured reference — not a shorter version of the source document, but a different artefact optimised for fast AI orientation.

**The test for a complete output:** Another AI tool, reading only `project-context.md`, should be able to answer the following without consulting the source:
- What does this system do, and what does it explicitly not do?
- What are the non-negotiable constraints — the things that cannot change by design?
- Who is responsible for what, and where do the boundaries sit?
- What connects to what, how, and with what scope?
- What technologies are in use, and for what purpose?
- What system is this project monitoring, serving, or interacting with?

If the file cannot answer these questions, it is incomplete.

---

## Rules

### Step 1 — Read before writing

Read the entire system document from start to finish before writing a single line of output. Do not begin generating until you have read it completely.

While reading, identify and mark:
- Every design principle or philosophy statement
- Every constraint, limitation, or "never / cannot / must not" statement
- Every component and its stated responsibility
- Every technology named, with its stated purpose
- Every connection between components, with directionality and credential scope
- Every coverage matrix, responsibility table, or boundary definition
- The rationale behind any non-obvious architectural decision

### Step 2 — Extract by category

Extract all of the following if present in the source. Do not skip a category because it seems minor. If a category has no content, omit it from the output entirely — do not add placeholder text.

| Category | What to capture | Depth |
|---|---|---|
| **System identity** | Name, version, role, platform | One line each |
| **Design principles** | Every stated principle + one-line rationale | Full — both label and reason |
| **Hard constraints** | Everything the system cannot, must not, or will never do | Full — include enforcement mechanism (policy vs credential vs architecture) |
| **Architecture** | All internal components + external dependencies | Name and role for each |
| **Component responsibilities** | What each component owns and — if stated — what it does not own | 1–3 lines per component |
| **Coverage / responsibility matrix** | Any matrix or table in the source mapping components to domains | Reproduce in full — do not collapse |
| **Technology stack** | Every named technology, framework, and library | Name, layer/purpose, and any notable configuration |
| **Connectivity model** | What connects to what, via what protocol, with what credential scope | Capture directionality — not just "A connects to B" |
| **Credential and security model** | Who holds what credentials, what is one-way, what is scoped | Every distinct credential relationship |
| **Monitored / external systems** | Any system being watched, depended on, or interacted with | Services and access type |
| **Boundaries** | What is out of scope, read-only, or explicitly not modifiable | Full — these are as important as capabilities |

### Step 3 — Apply depth rules

**Constraints and hard limits — maximum depth.** These are the most important things an AI tool needs to know when operating in this project. If a constraint is enforced at the credential level rather than by policy or convention, preserve that distinction. The difference between "we don't do X" and "we cannot do X because the credential doesn't permit it" is significant.

**Design principles — always include rationale.** A principle label without its reason is useless. "Observer never actor" is incomplete. "Observer never actor — EAGLE holds no write credentials to any Gridl resource; automated remediation is out of scope by design, not a missing feature" is complete.

**Component responsibilities — include negatives.** If the source states what a component does not own or cannot access, capture that. Negative responsibility boundaries prevent AI tools from making incorrect assumptions.

**Coverage matrices — reproduce in full.** Never collapse, summarise, or approximate a responsibility matrix. These tables exist precisely because the assignments are non-obvious. An approximation defeats their purpose.

**Technology stack — include purpose.** A list of technology names without purpose is marginally useful. "PostgreSQL — agent findings, alert history, and task state" is useful.

### Step 4 — Format rules

- Use structured key-value pairs, tables, and tight bullet lists. Prose is not appropriate in `project-context.md`.
- Bold labels for section headings within the file.
- Group by domain, not by narrative flow from the source document.
- Preserve original terminology exactly — do not paraphrase component or system names.
- Negative statements are as important as positive ones. Capture them explicitly.
- If the source contains a Mermaid diagram that encodes structural information (not just illustrative), extract its structural meaning into text form.
- Do not reproduce the source document's narrative sections, background story, or marketing framing.
- Do not add content that is not in the source document.

### Step 5 — Quality check before writing the file

Before writing the output, verify:

- [ ] Every hard constraint from the source is present — including enforcement mechanism
- [ ] Every design principle is present with its rationale, not just its label
- [ ] Every component has a responsibility entry — including what it does not own if stated
- [ ] The technology stack is complete — no named technology from the source is missing
- [ ] The connectivity model captures directionality and credential scope, not just connection existence
- [ ] Any coverage matrix or responsibility table from the source is reproduced in full
- [ ] The credential and security model captures who holds what, and what is one-directional
- [ ] No section from the source containing constraint, boundary, or responsibility information has been skipped

---

## Output

**File:** `project-context.md`

**Header:** Begin with the standard generated-file comment block, referencing the source document by name:

```
<!-- Generated file — do not edit manually. -->
<!-- Run context:generate to regenerate from [SourceDocument].md, then bash skills/sync.sh to propagate. -->
```

**Required structure** (omit sections with no content; do not add placeholder text):

```
[generated header comment]

**[System name]** — [one-line role statement]
**Version:** [version]
**Platform:** [platform]

**Design principles:**
- [Principle label] — [one-line rationale and practical implication]
- ...

**Hard constraints:**
- [Complete constraint statement] ([enforcement: policy / credential / architecture])
- ...

**Architecture:**
| Component | Role |
|---|---|
| [name] | [role] |
...

**Component responsibilities:**
- **[Component]** — [what it owns]. [What it does not own, if stated.]
- ...

**Coverage matrix:**
[reproduce source table in full]

**Technology stack:**
| Layer | Technology | Purpose / notes |
|---|---|---|
...

**Monitored / external systems:**
[table or structured list — system, services, access type]

**Connectivity model:**
- [Agent/Service] → [Target] via [protocol] ([credential scope])
- ...

**Credential and security model:**
- [Statement about who holds what]
- [Statement about directionality]
- [Statement about scope per service]
- ...
```

---

## Commands

| Command | Action |
|---|---|
| `context:generate` | Read the project's system document in full and generate `project-context.md` using this skill |
| `context:check` | Read both the system document and the current `project-context.md` and report what is missing, outdated, or inconsistent — without regenerating the file |
