---
name: study-knowledge-node
description: Guide the learning or relearning of one selected Knowledge Node from a Roadmap, including the author's explanation, research, evidence, optional experiments, review, and completion gate. Use when the user starts or continues that Roadmap item, even when the node already has a Note; route substantive changes to maintained knowledge through revise-knowledge-note.
---

# Study Knowledge Node

Turn one planned Knowledge Node into an author-understood learning event backed by the node's current, supported Knowledge Note.

## Start

1. Read `CONTEXT.md`, the learning and publication sections of `KNOWLEDGE-SYSTEM.md`, and the relevant Domain files.
2. Confirm that the Domain and selected Roadmap are both `active`. Do not start or continue learning in an archived Domain; require explicit Domain reactivation and a new active Roadmap first.
3. Confirm that the node exists in `map.yaml` and appears in the selected Roadmap.
4. Check `prerequisite` edges. Surface unmet prerequisites; the user may learn them first or explicitly defer them. Learn an external prerequisite through its own Domain and Roadmap rather than adding it to the current Roadmap.
5. If the selected item is `planned`, change only that item to `in_progress`; if it is already `in_progress`, leave it there and continue. Do not restart a completed or skipped item implicitly.
6. If the Note is absent, create `domains/<domain>/knowledge/<node-slug>.md` from `templates/knowledge-note.md` with `maturity: draft`; ensure its `<domain>.<node-slug>` ID, `domain`, and path correspond exactly.
7. If the Note exists, do not overwrite it: use a `published` Note as the current learning baseline; route substantive changes to it through `revise-knowledge-note` while keeping this item `in_progress`; continue an existing `draft` or `reviewed` Note in its owning initial-learning or revision workflow; follow `superseded_by` for a superseded Note; and require explicit author direction before reactivating an archived Note. Determine whether `draft` or `reviewed` is initial learning or revision from available Git history, completed items, and workflow context; ask the author if it cannot be determined reliably.

## Learning loop

1. Capture the learning goal, the author's initial explanation, and open questions before writing a polished explanation.
2. Teach through focused explanation and questions. Do not treat the author's agreement as demonstrated understanding.
3. Research important Claims against primary or authoritative sources. Keep traceable Evidence adjacent to each important Claim; label sourced facts, observations, and inferences, and record material scope or uncertainty. A bibliography alone is insufficient.
4. Create a Lab only when an experiment would materially strengthen or falsify a claim.
5. Ask the author to restate the central idea, relationships, and limits in their own words.
6. Review the resulting draft for factual error, important Claims without adjacent Evidence, invalid Labs used as support, missing boundaries, and contradictions with existing knowledge.
7. Update Map or Graph when the work reveals a missing node or edge.

Keep ordinary conceptual questions, authoritative-source lookups, and explanatory Labs in this workflow. Escalate to an Investigation only when competing hypotheses, a concrete anomaly, conflicting evidence, or another independently valuable reasoning trail should survive after the conclusion is distilled. Because the problem is already triaged, create the Investigation directly with this Knowledge Note's node ID as `origin`; do not create an Inbox Item. Add reciprocal links immediately.

## State gates

- Set `maturity: reviewed`, `ai_reviewed: true`, and `reviewed_at` only after review is complete.
- Do not set `maturity: published`, `author_confirmed: true`, `published_at`, or the Roadmap item to `completed` without explicit author confirmation. Set the item's `completed_at` when completion is confirmed.
- If the user does not confirm, leave the Roadmap item `in_progress`. Preserve an existing `published` Note unchanged when no revision was needed; otherwise leave the Note in the maturity reached by its current initial-learning or revision workflow.
- At the moment of completion, `completed` requires an existing `published` Knowledge Note. It then remains a historical state even if the Note later returns to `draft`, becomes `superseded`, or is archived.
- When relearning from an already `published` Note, re-check the Note and the author's understanding against the current Roadmap goal. If no substantive Note change is needed, preserve its maturity and review/publication metadata; explicit confirmation of the current learning goal is sufficient to complete this item. If a substantive revision is needed, complete the item only after the revised Note is republished and the author confirms the current learning goal.
- After an item completes, if every Roadmap item is now `completed` or `skipped`, do not complete the Roadmap automatically. Surface the terminal-item state and require the author to confirm the goal before setting Roadmap `status: completed` and `ended_at`; otherwise leave it active or archive it with an explicit reason.

Validate changed YAML and frontmatter against `schemas/` before finishing.
