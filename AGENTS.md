# Repository Instructions

## Purpose

This repository is a personal engineering knowledge system. AI assists research, learning, review, and editing, but never substitutes its output for the author's understanding or evidence.

Read [CONTEXT.md](CONTEXT.md) for canonical terminology and [KNOWLEDGE-SYSTEM.md](KNOWLEDGE-SYSTEM.md) for the workflow and state model.

## Invariants

- Committed Markdown, YAML, and JSON are the authoritative repository records within the responsibilities assigned below. This means Git records the system's current state; it does not make every recorded Claim true or verified.
- `AGENTS.md` owns global invariants and workflow routing; `CONTEXT.md` owns canonical terminology; `KNOWLEDGE-SYSTEM.md` owns workflow and lifecycle semantics; `schemas/*.json` own machine-validatable structure. Templates and project Skills must conform to those authorities and cannot override them. Treat any disagreement as a defect to resolve, not as permission to choose one silently.
- Treat every semantic change to `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, or project Skills as a Governance Proposal. Do not commit it without the author's explicit Governance Acceptance; acceptance makes the proposal eligible for commit but is not itself an instruction to commit. Mechanical edits that do not change system meaning are excluded.
- Treat every new or structurally changed Domain, Knowledge Map, Dependency Graph, or Roadmap as a Structure Proposal. Do not commit it without the author's explicit Structural Acceptance; acceptance makes a proposal eligible for commit but is not itself an instruction to commit.
- `AI generated` does not mean `learned`, `understood`, or `verified`.
- Never invent a source, experiment, production observation, or personal conclusion.
- Clearly distinguish sourced facts, observations, inferences, and the author's current understanding.
- Treat Evidence as support for a specific Claim, not as a document section. Keep traceable Evidence adjacent to important Claims; a bibliography alone is insufficient.
- Explicit reasoning may support an Inference from stated premises, but it cannot replace a source or observation for an empirical Claim.
- Do not create empty Knowledge Notes for every Roadmap item. Create one only when work on that node starts.
- Do not mark a Knowledge Note `published`, or a Roadmap item `completed`, without the author's explicit confirmation.
- A Roadmap item `completed` is a historical learning record. Later changes to the Knowledge Note do not revert it.
- Do not mark a Roadmap `completed` automatically. It requires no `planned` or `in_progress` items, at least one `completed` item, and the author's explicit confirmation that the goal was achieved.
- Completed and archived Roadmaps are terminal. Before archiving a Roadmap, explicitly resolve every `in_progress` item to `completed` or `skipped`; archiving then preserves the resulting item states, requires an `archive_reason`, and resuming the goal requires a new Roadmap.
- Archiving or reactivating a Domain requires the author's explicit decision. Archive only after every Roadmap in that Domain is `completed` or `archived` and no item is `in_progress`.
- An archived Domain is read-only except for mechanical repairs: do not add Nodes, change its Map or Graph, create Roadmaps, start or revise Notes, or use one of its nodes as an Investigation `promotion_target`. Reactivation preserves the Domain ID, clears `archived_at` and `archive_reason`, reassesses Scope/Map/Graph as a Structure Proposal, and creates a new Roadmap instead of reopening a terminal one.
- Do not silently change a stable ID. Treat renames as migrations and update every reference.
- Prefer updating an existing Knowledge Node over creating a duplicate.
- A Lab is optional. Create one only when an experiment is useful for validating a claim.
- An `invalid` Lab may document a failed experiment but cannot support or refute a Claim.
- An Investigation may close without producing or changing a Knowledge Note.
- A promoted Investigation has exactly one `promotion_target`, distinct from its `origin` and contextual `related_nodes`. Record a promotion outcome only after the target action exists; publication remains a separate author gate.

## Workflow routing

- When the user wants to define or systematically learn a new field, use `domain-bootstrap`.
- When the user starts, continues, or studies again a node from a Roadmap, use `study-knowledge-node`, including when the node already has a Knowledge Note.
- When the user materially revises an existing Knowledge Note after its initial learning cycle, use `revise-knowledge-note`; no active Roadmap is required and completed items remain unchanged.
- When a concrete question, incident, anomaly, or observation has an independently valuable reasoning or evidence trail, use `investigate-problem`.
- When the user asks to validate, clean, synchronize, or review the knowledge repository, use `knowledge-maintenance`.
- Do not create repository files for an ordinary conceptual question unless the user asks to record it or the question belongs to an active workflow.
- Use Inbox only for untriaged capture. A problem already triaged within an active Knowledge Note may start an Investigation directly and must record that Note as its origin.
- If routing is ambiguous, determine whether the starting point is a systematic learning goal, a selected Roadmap node, or a concrete observed problem before creating files.

## Repository conventions

- Use the schemas in `schemas/` and starting structures in `templates/`.
- YAML uses two-space indentation, `snake_case` keys, stable lowercase IDs, UTF-8, quoted ISO date strings (`"YYYY-MM-DD"`), explicit `null`, and no anchors, aliases, or custom tags.
- Domain IDs use lowercase kebab-case, for example `kubernetes`.
- Knowledge Node IDs use `<domain>.<slug>`, for example `kubernetes.pod`.
- Investigation and Lab IDs use `investigation.<slug>` and `lab.<slug>`.
- A Roadmap contains only nodes owned by its Domain. A cross-Domain `prerequisite` is stored in the `to` node's Domain Graph; cross-Domain `related` edges are not allowed in V1.
- Domain directory names and every contained `domain` value must match `domain.yaml.id`; Node and Roadmap ID prefixes must match that Domain.
- Map parents must exist in the same Map and form an acyclic forest. Prerequisites must be acyclic across all Domain Graphs.
- Store same-Domain `related` edges canonically with the lexicographically smaller node ID in `from`.
- Roadmap phase IDs and item node IDs are unique within the Roadmap; phase and item array order is the formal learning order.
- Artifact paths must correspond to stable IDs: Knowledge Notes use `domains/<domain>/knowledge/<slug>.md`, Inbox Items use `inbox/<date>-<slug>.md`, Investigations use `investigations/<slug>.md`, and Labs use `labs/<slug>/README.md`.
- Use standard Markdown links so files remain portable across GitHub and local Markdown tools.
