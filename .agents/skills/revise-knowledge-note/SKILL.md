---
name: revise-knowledge-note
description: Revise an existing Knowledge Note after its initial learning cycle because new evidence, version changes, or improved understanding materially changes its content. Use without requiring an active Roadmap; do not use for mechanical edits, an in-progress node's initial learning, or an unrelated incident.
---

# Revise Knowledge Note

Maintain current knowledge without rewriting the historical fact that earlier learning was completed.

## Start

1. Read `CONTEXT.md`, the maintenance and publication sections of `KNOWLEDGE-SYSTEM.md`, the relevant Domain files, and the existing Note.
2. Confirm that the Note's Domain is `active`. Do not substantively revise a Note in an archived Domain; require explicit Domain reactivation first. Mechanical repairs remain allowed without reactivation.
3. Verify that the Note's `<domain>.<slug>` ID, `domain`, and `domains/<domain>/knowledge/<slug>.md` path correspond exactly.
4. Identify the revision trigger and distinguish a substantive claim, explanation, boundary, or conclusion change from a mechanical edit. Route mechanical consistency work to `knowledge-maintenance` without changing maturity.
5. Do not revise a `superseded` Note by default; follow `superseded_by` and revise the replacement. Reactivating an `archived` Note requires explicit author direction.
6. A revision does not require an active Roadmap and must not reopen or alter completed Roadmap items.
7. Normally start from a `published` Note. A `draft` or `reviewed` Note belongs here only when a Knowledge Revision is already underway; otherwise continue its initial learning workflow.

## Revision loop

1. Establish what changed and why. Keep traceable Evidence adjacent to each important changed Claim; label sourced facts, observations, and inferences, and preserve the author's own understanding separately.
2. For a substantive revision, set the Note to `draft` and reset `ai_reviewed`, `author_confirmed`, `reviewed_at`, and `published_at` for the current version.
3. Research important changed claims against primary or authoritative sources. Create a Lab only when experimentation adds useful evidence.
4. Escalate to an Investigation when the competing hypotheses, anomaly, or evidence trail is independently worth preserving; use the Note as its origin.
5. Update related links. If the revision requires a new node, changed node boundary, or Graph relationship, create a Structure Proposal and require Structural Acceptance before it becomes eligible for commit.
6. Review the revised Note for factual error, important Claims without adjacent Evidence, invalid Labs used as support, missing boundaries, stale statements, and contradictions with existing knowledge.

## State gates

- Set `maturity: reviewed`, `ai_reviewed: true`, and `reviewed_at` only after review of the current revision is complete.
- Do not set `maturity: published`, `author_confirmed: true`, or `published_at` without the author's explicit confirmation of the revised content.
- Leave completed Roadmap items unchanged throughout revision and republication.
- Validate changed frontmatter and affected cross-file links before finishing.
