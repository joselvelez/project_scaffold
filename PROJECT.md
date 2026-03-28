# {{PROJECT_NAME}}
## {{PROJECT_DESCRIPTION}}

---

| | |
|---|---|
| **Version** | 0.1.0 |
| **Date** | {{DATE}} |
| **Status** | Design |

---

## Document Guidelines

All additions and modifications to this document must follow these rules without exception.

- **Living document** — This document describes what {{PROJECT_NAME}} is. It is updated in-place as the system evolves. Sections are organised by what they describe, not by when they were written. The document always reflects the current state of the system.
- **Change history** — All changes are recorded in `CHANGELOG.md`. That file is the chronological record. This file is the truth about the system.
- **Versioning** — This document and the repository share a single version number. They are always identical. When either changes, both change. The full versioning and release process is defined in `CONTRIBUTING.md`.
- **Writing** — Clear and direct. No filler, no unexplained jargon. Write for a technical reader who may not have been present when a decision was made. Every section must stand on its own.
- **Code** — Included only when a concept cannot be expressed without it. Never paste implementation code. Configuration snippets are acceptable only when they are the clearest way to express a constraint.
- **Visuals** — Every architectural concept, structural relationship, data flow, or system responsibility must be accompanied by a diagram or table. Mermaid is the preferred diagram format for compatibility across platforms. Do not describe a relationship in prose when a diagram expresses it more clearly.
- **Scope** — This document describes {{PROJECT_NAME}} only. External systems are referenced only as they relate to {{PROJECT_NAME}}.

---

## 1. System Identity

**Name:** {{PROJECT_NAME}}  
**Role:** {{PROJECT_DESCRIPTION}}  
**Platform:** {{PROJECT_PLATFORM}}

[Describe what this system is in 2–3 sentences. Be explicit about what it is not — constraints matter as much as capabilities.]

---

## 2. Design Philosophy

[Define the core principles that govern every design decision in this project. These principles are used to evaluate all future changes — new components, features, and architectural decisions must respect them. Aim for 3–5 principles. Each should have a short name and a clear, direct explanation.]

---

## 3. System Architecture

[Describe the system's structure. Use Mermaid diagrams for every architectural relationship, component boundary, and data flow. Do not describe in prose what a diagram expresses more clearly. Start with the highest-level view and add detail in subsections.]

---

## 4. Technology Stack

| Layer | Technology | Notes |
|---|---|---|
| | | |
