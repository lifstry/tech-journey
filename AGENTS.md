# Repository Instructions

## Purpose

This repository is a personal engineering knowledge system. AI assists research, learning, review, and editing, but never substitutes its output for the author's understanding or evidence.

Read [CONTEXT.md](CONTEXT.md) for canonical terminology and [KNOWLEDGE-SYSTEM.md](KNOWLEDGE-SYSTEM.md) for the workflow and state model.

## Invariants

- The tree of the currently checked-out commit (`HEAD`) is the Formal Baseline. Committed Markdown, YAML, and JSON in that tree are the authoritative repository records within the responsibilities assigned below. This means Git records the system's current state; it does not make every recorded Claim true or verified. Working-tree and index changes are candidate changes, not current authority.
- `AGENTS.md` owns global invariants and workflow routing; `CONTEXT.md` owns canonical terminology; `KNOWLEDGE-SYSTEM.md` owns workflow and lifecycle semantics; `schemas/*.json` own machine-validatable structure. Templates and project Skills must conform to those authorities and cannot override them. Treat any disagreement as a defect to resolve, not as permission to choose one silently.
- Treat every semantic change to `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, or project Skills and their supporting validation resources as a Governance Proposal. Until it is committed, apply the Formal Baseline when deciding what actions are authorized; a candidate rule may not authorize its own adoption or weaken a baseline gate. Do not commit it without the author's explicit Governance Acceptance of one exact Proposal Snapshot, identified by the base commit and candidate Git tree. Any change to that snapshot invalidates the acceptance. Acceptance makes only that snapshot eligible for commit and is not itself an instruction to commit. Mechanical edits that do not change system meaning are excluded.
- Treat every new or structurally changed Domain, Knowledge Map, Dependency Graph, or Roadmap as a Structure Proposal. Do not commit it without the author's explicit Structural Acceptance of one exact Proposal Snapshot under the same snapshot rules. Acceptance makes only that snapshot eligible for commit and is not itself an instruction to commit.
- Before requesting either acceptance, stage exactly the complete proposal, validate the index rather than relying on the working-tree view, identify the base commit and candidate tree, and disclose any working-tree changes outside the snapshot. Commit the accepted index atomically; partial commits and post-acceptance index changes require a new acceptance. If evidence of acceptance for the exact snapshot is unavailable, do not commit and request acceptance again.
- One Proposal Snapshot may contain both governance and structural changes, but each gate remains independent: do not commit it until that exact snapshot has every applicable Governance and Structural Acceptance.
- Treat accepted Map descriptions, Graph edges, and rationales as the current planning model, not as published or verified knowledge. Empirical or explanatory Claims belong in Knowledge Notes and remain subject to Evidence, Review, and Publish gates.
- `AI generated` does not mean `learned`, `understood`, or `verified`.
- Never invent a source, experiment, production observation, or personal conclusion.
- Clearly distinguish sourced facts, observations, inferences, and the author's current understanding.
- Treat Evidence as support for a specific Claim, not as a document section. Keep traceable Evidence adjacent to important Claims; a bibliography alone is insufficient.
- Explicit reasoning may support an Inference from stated premises, but it cannot replace a source or observation for an empirical Claim.
- Do not create empty Knowledge Notes for every Roadmap item. Create one only when work on that node starts.
- Do not mark a Knowledge Note `published`, or a Roadmap item `completed`, without the author's explicit confirmation.
- Roadmap item states `completed` and `skipped` are terminal historical records within that Roadmap. Later changes to the Knowledge Note do not revert a completed item; later interest in a skipped node uses another Roadmap rather than reopening the item.
- Do not mark a Roadmap `completed` automatically. It requires no `planned` or `in_progress` items, at least one `completed` item, and the author's explicit confirmation that the goal was achieved.
- Completed and archived Roadmaps are terminal. Before archiving a Roadmap, explicitly resolve every `in_progress` item to `completed` or `skipped`; archiving then preserves the resulting item states, requires an `archive_reason`, and resuming the goal requires a new Roadmap.
- Archiving or reactivating a Domain requires the author's explicit decision. Archive only after every Roadmap is `completed` or `archived`, no item is `in_progress`, no non-archived Note is `draft` or `reviewed`, no active Investigation originates from one of its Notes, and no `planned` or `running` Lab is tied to it. Review every other active Investigation that mentions the Domain and either resolve it when it still intends to change the Domain or explicitly classify its use as read-only context.
- An archived Domain is read-only except for mechanical repairs: do not add Nodes, change its Map or Graph, create Roadmaps, start or revise Notes, or use one of its nodes as an Investigation `promotion_target`. Reactivation preserves the Domain ID, clears `archived_at` and `archive_reason`, and reassesses purpose/Scope/Map/Graph; only structural changes produced by that reassessment are a Structure Proposal. Create a new Roadmap only when systematic learning resumes; maintenance-only reactivation does not require one, and terminal Roadmaps are never reopened.
- A `draft` or `reviewed` Knowledge Note must record `knowledge_cycle: initial_learning` or `revision`; `published` and `superseded` Notes use `knowledge_cycle: null`. Archiving preserves the interrupted cycle when the Note was unfinished. A substantive edit to a reviewed Note returns it to `draft` in the same cycle and resets the current review and confirmation metadata.
- Archiving, reactivating, or superseding a Knowledge Note requires the author's explicit decision. An archived Note records its prior maturity, date, and reason. A superseded Note must previously have been published, and at the transition its distinct replacement must be published. The acyclic replacement chain must currently terminate at a non-archived, non-superseded Note; that endpoint may be `draft` or `reviewed` only while undergoing its own revision after an earlier publication.
- Do not leave an `in_progress` Roadmap item pointing to an archived or superseded Note. Before that Note transition, explicitly complete or skip the item, or structurally replace its node in the Roadmap through an accepted Structure Proposal.
- Do not silently change a stable ID. Treat a rename as one accepted, atomic Structure Proposal that updates every current and historical reference. Reference-only changes required inside archived Domains or terminal artifacts are migration repairs and do not reopen them; changing their meaning remains forbidden.
- Prefer updating an existing Knowledge Node over creating a duplicate.
- A Lab is optional. Create one only when an experiment is useful for validating a claim.
- An `invalid` Lab may document a failed experiment but cannot support or refute a Claim.
- A stopped but otherwise not invalid Lab is `abandoned`, not `invalid`; completed, invalid, and abandoned Labs record `ended_at`, and invalid or abandoned Labs record a reason.
- An Investigation may close without producing or changing a Knowledge Note.
- An Investigation with a promotion outcome has exactly one `promotion_target`, distinct from every contextual `related_nodes` entry. When `origin.type: knowledge_note`, the target may equal `origin.reference` because an Investigation may update the Note that started it. Record a promotion outcome only after the target action exists; publication remains a separate author gate.
- Keep each Investigation's `domains` as a complete inventory of materially involved Domains. It must include at least the Domains implied by a Knowledge Note origin, `related_nodes`, `promotion_target`, and linked Labs' `related_nodes`.
- A Knowledge Note is active for direct Investigation entry exactly when its Domain is active and its maturity is `draft`, `reviewed`, or `published`; `archived` and `superseded` Notes are not active workflow origins.
- Apply the reciprocal-link matrix in `KNOWLEDGE-SYSTEM.md`: contextual `related_nodes` do not require Note backlinks; origin and promotion-target Notes do; each Investigation-owned Lab names exactly that Investigation; and a Note/Lab link is reciprocal through the Note's `labs` and the Lab's `related_nodes`.
- Promoted and closed Inbox Items, and closed and abandoned Investigations, are terminal. Later work starts a new Inbox Item or Investigation instead of reopening history. Before an Investigation becomes terminal, every linked Lab must also be terminal.

## Workflow routing

- When the user wants to define or systematically learn a new field, use `domain-bootstrap`.
- When the user starts, continues, or studies again a node from a Roadmap, use `study-knowledge-node`, including when the node already has a Knowledge Note. Also use it to continue a `draft` or `reviewed` Note whose `knowledge_cycle` is `initial_learning` after Investigation promotion or explicit Note reactivation, even when no Roadmap owns that initial-learning cycle.
- When the user materially revises a Knowledge Note after its initial learning cycle, or archives, reactivates, or supersedes any existing Knowledge Note, use `revise-knowledge-note`; lifecycle actions may apply to unfinished initial learning, no active Roadmap is required, and completed items remain unchanged.
- When a concrete question, incident, anomaly, or observation has an independently valuable reasoning or evidence trail, use `investigate-problem`.
- When the user asks to validate, clean, synchronize, or review the knowledge repository, use `knowledge-maintenance`.
- When the user explicitly asks to change the knowledge-system contract itself, use `knowledge-maintenance` to prepare and validate a Governance Proposal; do not treat the requested edits as accepted or commit-eligible until the exact Proposal Snapshot receives Governance Acceptance.
- Do not create repository files for an ordinary conceptual question unless the user asks to record it or the question belongs to an active workflow.
- Use Inbox only for untriaged capture. A problem already triaged within an Active Knowledge Note may start an Investigation directly and must record that Note as its origin.
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
- `schema_version` is versioned independently for each artifact type. Any committed change to machine-validation semantics must increment it, update its template, and explicitly migrate every existing instance before the new Schema becomes current; documentation-only Schema metadata such as `description` does not require a bump.
- Validate Schemas, templates, and existing instances with `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb` before requesting acceptance or finishing a maintenance change.
