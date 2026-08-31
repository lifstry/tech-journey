---
name: revise-knowledge-note
description: Revise maintained knowledge after its initial learning cycle, or explicitly archive, reactivate, or supersede any existing Knowledge Note. Use without requiring an active Roadmap; do not use to edit an in-progress initial-learning Note, for mechanical edits, or for an unrelated incident.
---

# Revise Knowledge Note

Maintain current knowledge without rewriting the historical fact that earlier learning was completed.

## Start

1. Read `CONTEXT.md`, the maintenance and publication sections of `KNOWLEDGE-SYSTEM.md`, the relevant Domain files, and the existing Note.
2. Confirm that the Note's Domain is `active`. Do not substantively revise a Note in an archived Domain; require explicit Domain reactivation first. Mechanical repairs remain allowed without reactivation.
3. Verify that the Note's `<domain>.<slug>` ID, `domain`, and `domains/<domain>/knowledge/<slug>.md` path correspond exactly.
4. Identify the revision trigger and distinguish a substantive claim, explanation, boundary, or conclusion change from a mechanical edit. Route mechanical consistency work to `knowledge-maintenance` without changing maturity.
5. Treat a `superseded` Note as terminal; follow its acyclic `superseded_by` chain to the non-superseded endpoint and revise that Note. The endpoint normally is `published`, but may already be `draft` or `reviewed` with `knowledge_cycle: revision` after an earlier publication; it must never be archived. Reactivating an `archived` Note requires explicit author direction and an active Domain: restore `archived_from`, clear archive metadata, and preserve an interrupted `knowledge_cycle`. A restored `initial_learning` Note continues in standalone mode through `study-knowledge-node` unless a new active Roadmap explicitly owns the work; a restored published Note enters revision normally if substantive changes are needed.
6. A revision does not require an active Roadmap and must not reopen or alter completed Roadmap items.
7. Normally start from a `published` Note. A `draft` or `reviewed` Note belongs here exactly when `knowledge_cycle: revision`; `initial_learning` routes to `study-knowledge-node`.

## Revision loop

1. Establish what changed and why. Keep traceable Evidence adjacent to each important changed Claim; label sourced facts, observations, and inferences, and preserve the author's own understanding separately.
2. For a substantive revision, set the Note to `draft` and `knowledge_cycle: revision`, and reset `ai_reviewed`, `author_confirmed`, `reviewed_at`, and `published_at` for the current version. The same reset is mandatory when a `reviewed` revision receives another substantive edit before publication.
3. Research important changed claims against primary or authoritative sources. Create a Lab only when experimentation adds useful evidence.
4. Escalate to an Investigation when the competing hypotheses, anomaly, or evidence trail is independently worth preserving; use the Note as its origin.
5. Update related links according to the field-level matrix in `KNOWLEDGE-SYSTEM.md`. If the revision requires a new node, changed node boundary, or Graph relationship, create a Structure Proposal and require Structural Acceptance of its exact Proposal Snapshot before it becomes eligible for commit.
6. Review the revised Note for factual error, important Claims without adjacent Evidence, invalid or abandoned Labs used as support, missing boundaries, stale statements, and contradictions with existing knowledge.

## State gates

- Set `maturity: reviewed`, retain `knowledge_cycle: revision`, and set `ai_reviewed: true` and `reviewed_at` only after review of the current revision is complete.
- Do not set `maturity: published`, `knowledge_cycle: null`, `author_confirmed: true`, or `published_at` without the author's explicit confirmation of the revised content.
- Leave completed Roadmap items unchanged throughout revision and republication.
- Validate changed frontmatter and affected cross-file links before finishing.

## Archive, reactivate, or supersede

- Perform each lifecycle action only on the author's explicit decision and only while the Domain is active. The action does not alter completed Roadmap items.
- Before archiving or superseding, find every `in_progress` Roadmap item for the source node. Require the author to complete or skip each item, or apply an accepted Structure Proposal that replaces the item node; never leave an in-progress item pointing to an archived or superseded Note.
- Before archiving any Note, find every superseded Note whose replacement chain currently terminates at it. Do not archive that endpoint while those chains depend on it; supersede a published endpoint with another eligible published Note to extend the chains, or leave the endpoint active. A chain endpoint may undergo normal revision and temporarily be `draft` or `reviewed` with `knowledge_cycle: revision`.
- To archive a `draft`, `reviewed`, or `published` Note, set `maturity: archived`, preserve its review/publication metadata, record the former maturity in `archived_from`, and set `archived_at` and a non-empty `archive_reason`. Preserve `knowledge_cycle` for unfinished `draft`/`reviewed` work and keep it `null` for a formerly published Note.
- To reactivate an archived Note, restore `maturity` from `archived_from`, clear `archived_from`, `archived_at`, and `archive_reason`, and preserve an unfinished cycle. Route restored `initial_learning` work to `study-knowledge-node`, which may continue it without manufacturing Roadmap history; if a restored published Note now needs substantive changes, enter `knowledge_cycle: revision` through the normal revision loop.
- Supersede only a currently `published` Note and only with a distinct, existing, currently `published` replacement Note. Verify that following `superseded_by` from the replacement cannot reach the source. Then set `maturity: superseded`, `knowledge_cycle: null`, `superseded_by`, and `superseded_at`, while preserving the source Note's review and publication metadata. A superseded Note is terminal; later replacement transitions may extend the acyclic chain. Its endpoint must be non-archived and non-superseded; `draft` or `reviewed` is allowed only for that endpoint's revision after an earlier publication.
- Any new replacement Node, Node boundary change, or Map/Graph update remains a Structure Proposal requiring Structural Acceptance of the exact Proposal Snapshot before commit.
- Update `updated_at` on every changed artifact and run `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb` before finishing.
