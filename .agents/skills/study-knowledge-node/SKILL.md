---
name: study-knowledge-node
description: Guide the learning or relearning of one selected Knowledge Node, normally from a Roadmap, including the author's explanation, research, evidence, optional experiments, review, and completion gate. Also continue an existing initial-learning Note created by Investigation promotion or explicit reactivation without requiring a Roadmap; route substantive changes to maintained knowledge through revise-knowledge-note.
---

# Study Knowledge Node

Turn one Knowledge Node into author-understood knowledge backed by its current, supported Knowledge Note, while recording a learning event only when a Roadmap owns it.

## Start

1. Read `CONTEXT.md`, the learning and publication sections of `KNOWLEDGE-SYSTEM.md`, and the relevant Domain files.
2. Confirm that the Domain is `active`. Do not start or continue learning in an archived Domain; resumed systematic learning requires explicit Domain reactivation and a new active Roadmap, while maintenance-only Note reactivation does not.
3. Confirm that the node exists in `map.yaml`, then choose exactly one mode:
   - Roadmap-backed: the selected Roadmap is `active` and contains the node;
   - standalone initial learning: an existing `draft` or `reviewed` Note has `knowledge_cycle: initial_learning` because Investigation promotion created it or the author explicitly reactivated its interrupted initial cycle. This mode must not create an arbitrary Note or Roadmap history.
4. Check `prerequisite` edges. Surface unmet prerequisites; the user may learn them first or explicitly defer them. Learn an external prerequisite through its own Domain and Roadmap rather than adding it to the current Roadmap.
5. In Roadmap-backed mode, if the selected item is `planned`, change only that item to `in_progress`; if it is already `in_progress`, leave it there and continue. `completed` and `skipped` are terminal within this Roadmap and must not be restarted; renewed learning uses another Roadmap. Standalone mode changes no Roadmap.
6. Only Roadmap-backed mode may create an absent Note here: create `domains/<domain>/knowledge/<node-slug>.md` from `templates/knowledge-note.md` with `maturity: draft` and `knowledge_cycle: initial_learning`; ensure its `<domain>.<node-slug>` ID, `domain`, and path correspond exactly. Standalone mode requires the Note to exist already.
7. If the Note exists, do not overwrite it: use a `published` Note as the current learning baseline; route substantive changes to it through `revise-knowledge-note` while keeping any Roadmap-backed item `in_progress`; route `draft` or `reviewed` deterministically by `knowledge_cycle`; follow the acyclic `superseded_by` chain to its eligible non-superseded endpoint and route an endpoint already in revision through `revise-knowledge-note`; and route explicit archived-Note reactivation through `revise-knowledge-note`. Restore an archived Note from `archived_from`, preserving an unfinished cycle, only after its Domain is active.

## Learning loop

1. Capture the learning goal, the author's initial explanation, and open questions before writing a polished explanation.
2. Teach through focused explanation and questions. Do not treat the author's agreement as demonstrated understanding.
3. Research important Claims against primary or authoritative sources. Keep traceable Evidence adjacent to each important Claim; label sourced facts, observations, and inferences, and record material scope or uncertainty. A bibliography alone is insufficient.
4. Create a Lab only when an experiment would materially strengthen or falsify a claim.
5. Ask the author to restate the central idea, relationships, and limits in their own words.
6. Review the resulting draft for factual error, important Claims without adjacent Evidence, invalid or abandoned Labs used as support, missing boundaries, and contradictions with existing knowledge.
7. If a `reviewed` Note receives any substantive edit before publication, return it to `draft` in the same `knowledge_cycle`, set `ai_reviewed` and `author_confirmed` to `false`, and clear `reviewed_at` and `published_at` before reviewing the new content again.
8. When the work reveals a missing node or edge, prepare a Structure Proposal; do not treat the Map/Graph change as formal until its exact Proposal Snapshot is accepted and committed.

Keep ordinary conceptual questions, authoritative-source lookups, and explanatory Labs in this workflow. Escalate to an Investigation only when competing hypotheses, a concrete anomaly, conflicting evidence, or another independently valuable reasoning trail should survive after the conclusion is distilled. Direct entry is allowed only while this Note is active: its Domain is `active` and its maturity is `draft`, `reviewed`, or `published`. Because the problem is already triaged, create the Investigation directly with this Knowledge Note's node ID as `origin`; do not create an Inbox Item. Add reciprocal links according to the matrix in `KNOWLEDGE-SYSTEM.md` immediately.

## State gates

- Set `maturity: reviewed`, `ai_reviewed: true`, and `reviewed_at` only after review is complete; preserve the current `knowledge_cycle`.
- Do not set `maturity: published`, `knowledge_cycle: null`, `author_confirmed: true`, or `published_at` without explicit author confirmation. In Roadmap-backed mode, also do not complete the item without explicit confirmation and set `completed_at` when completion is confirmed. Standalone mode never creates or changes a Roadmap item.
- If the user does not confirm, leave a Roadmap-backed item `in_progress`; in either mode, leave the Note in the maturity reached by its current initial-learning or revision workflow. Preserve an existing `published` Note unchanged when no revision was needed.
- In Roadmap-backed mode, item completion requires an existing `published` Knowledge Note. The completed item then remains a historical state even if the Note later returns to `draft`, becomes `superseded`, or is archived.
- In Roadmap-backed relearning from an already `published` Note, re-check the Note and the author's understanding against the current Roadmap goal. If no substantive Note change is needed, preserve its maturity and review/publication metadata; explicit confirmation of the current learning goal is sufficient to complete this item. If a substantive revision is needed, complete the item only after the revised Note is republished and the author confirms the current learning goal.
- In Roadmap-backed mode, after an item completes, if every Roadmap item is now `completed` or `skipped`, do not complete the Roadmap automatically. Surface the terminal-item state and require the author to confirm the goal before setting Roadmap `status: completed` and `ended_at`; otherwise leave it active or archive it with an explicit reason.
- A `planned` or `in_progress` item may become `skipped` only on the author's explicit decision. Do not restore a `completed` or `skipped` item; renewed learning belongs to another Roadmap.
- If a Lab stops without a valid result, mark it `abandoned` with `ended_at` and `end_reason`; do not misuse `invalid` for a merely stopped experiment or use either status as Evidence.

Apply the Note/Lab and Investigation backlink matrix in `KNOWLEDGE-SYSTEM.md`, update `updated_at` for every changed artifact, and run `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb` before finishing.
