---
name: domain-bootstrap
description: Define, refine, archive, or reactivate a knowledge Domain, its scope, Knowledge Map, Dependency Graph, and goal-specific Roadmap. Use when the user wants to systematically learn a field or change a Domain's lifecycle or structure; do not use for a single concrete problem or an already-selected Roadmap node.
---

# Domain Bootstrap

Create the smallest usable Domain structure without pretending the first model is complete.

## Before writing

1. Read `CONTEXT.md` and the Domain-related sections of `KNOWLEDGE-SYSTEM.md`.
2. Inspect existing `domains/*/domain.yaml` and node IDs to avoid duplicates.
3. Determine whether the subject is a new Domain, an active Domain, an archived Domain to reactivate, or one Knowledge Node.
4. Establish the user's goal, current background, included scope, and explicit exclusions. Ask only for information that materially changes the boundary.

## Workflow

1. For a new Domain, copy and adapt `templates/domain.yaml`, `templates/map.yaml`, and `templates/graph.yaml` into `domains/<domain>/`; initialize it as `active` with `archived_at: null` and `archive_reason: null`.
2. Build a minimal Knowledge Map with stable node IDs. Do not create Knowledge Notes.
3. Record only `prerequisite` and `related` edges in V1. Include a rationale for every edge and apply the Graph ownership and canonical-order rules below.
4. When the user has a concrete learning goal, copy and adapt `templates/roadmap.yaml` into `domains/<domain>/roadmaps/`.
5. Treat every new or structurally changed Domain, Map, Graph, and Roadmap as a Structure Proposal. Make uncertainty and disputed boundaries visible. Routine Roadmap progress updates and mechanical edits are not Structure Proposals.
6. Validate the result against the matching files in `schemas/` and the cross-file rules in `KNOWLEDGE-SYSTEM.md`.
7. Do not commit the Structure Proposal unless the author has reviewed it and explicitly given Structural Acceptance.

## Archive or reactivate

- Archive only on the author's explicit decision. Before archiving an active Roadmap, explicitly resolve each `in_progress` item to `completed` or `skipped`; an archived Roadmap must contain no `in_progress` items. Confirm that every Roadmap in the Domain is then `completed` or `archived` and no item is `in_progress`; then set `status: archived`, `archived_at`, and a non-empty `archive_reason`.
- Treat an archived Domain as read-only except for mechanical repairs. Preserve its ID, Scope, Map, Graph, Roadmaps, Notes, and existing cross-Domain references.
- Reactivate only on the author's explicit decision. Preserve the Domain ID, set `status: active`, clear `archived_at` and `archive_reason` to `null`, and reassess Scope, Map, and Graph.
- Treat structural changes discovered during reactivation as a Structure Proposal. Create a new active Roadmap for resumed learning; never reopen a completed or archived Roadmap.

## Constraints

- Do not create an empty Knowledge Note for each Map or Roadmap node.
- Map classifies nodes; Graph relates nodes; Roadmap orders nodes. Do not duplicate their responsibilities.
- Keep the Domain directory, `domain.yaml.id`, contained `domain` values, and Node and Roadmap ID prefixes aligned.
- Map parents must exist in the same Map and remain acyclic; multiple root nodes are allowed.
- Keep all prerequisite edges globally acyclic across Domain Graphs. For `related`, store the lexicographically smaller node ID in `from`.
- A Roadmap item may reference only a node in that Roadmap's Domain Map. Express an external prerequisite only as a Graph edge; if the user decides to study it, use a Roadmap in the prerequisite node's own Domain.
- Keep phase IDs and item node IDs unique within a Roadmap. Array order is the formal phase and learning order.
- Initialize Roadmaps with `status: active`, `ended_at: null`, and `archive_reason: null`. Never complete one automatically; completion and archival require the author's explicit decision. Resolve every `in_progress` item before archival, and never reopen a terminal Roadmap.
- Do not add Nodes, change Map or Graph relationships, create a Roadmap, or start or revise a Note while the Domain remains archived.
- Store a cross-Domain `prerequisite` in the `to` node's Domain Graph. Every referenced node must exist in exactly one Domain Map.
- Do not create cross-Domain `related` edges in V1.
- Never silently rename an existing stable ID.
- Stop after the minimal Domain model and requested Roadmap are reviewable. Do not start teaching the first node unless the user also asks to begin it.
