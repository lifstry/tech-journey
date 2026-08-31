---
name: investigate-problem
description: Capture and investigate a concrete technical question, incident, anomaly, or observation whose reasoning or evidence trail is worth preserving. Use Inbox for untriaged entry, or start directly from an active Knowledge Note when the problem is already triaged; do not create files for an ordinary unrecorded question.
---

# Investigate Problem

Preserve the reasoning and evidence behind a concrete problem without forcing every investigation to become permanent knowledge.

## Determine the entry

1. Read `CONTEXT.md` and the problem-driven sections of `KNOWLEDGE-SYSTEM.md`.
2. Search existing Inbox Items, Investigations, Labs, Knowledge Notes, and node IDs for overlap.
3. If the problem is untriaged and did not arise within an active Knowledge Note workflow, create `inbox/<date>-<slug>.md` from `templates/inbox.md` with observed facts, context, guesses, and questions.
4. Triage whether the reasoning and evidence trail is worth preserving independently of the eventual conclusion. A directly closed Inbox Item must set `closed_at` and `close_reason` and must leave `investigation: null`.
5. If the problem was already triaged within an active Knowledge Note whose Domain is also active, do not create an Inbox Item. Confirm that it meets the Investigation threshold and use the Note as its origin.

## Investigation

1. When independent preservation is justified, create `investigations/<slug>.md` from `templates/investigation.md`; keep its `investigation.<slug>` ID aligned with the filename, and apply the same ID/path correspondence to any Inbox Item or Lab created by this workflow.
2. For Inbox entry, set `origin.type: inbox`, point `origin.reference` to the Inbox path, then set the Inbox Item to `promoted` and add its Investigation path.
3. For active-Note entry, set `origin.type: knowledge_note`, use the Note's node ID as `origin.reference`, and add the Investigation path to the Note immediately.
4. Record hypotheses, Evidence, rejected explanations, current conclusions, uncertainty, and open questions as the work evolves. For each Evidence item, identify which hypothesis or Claim it supports or refutes.
5. Keep primary-source facts, Lab observations, production observations, and inference distinguishable. Record scope and uncertainty, and never use an `invalid` Lab as support or refutation.
6. Create `labs/<slug>/README.md` from `templates/lab.md` only when experimentation adds useful evidence. Link it from the Investigation.

## Close and promote

Close with exactly one outcome:

- `update_existing_node`: distill the reusable conclusion into the existing target Note and continue that Note's current workflow—initial learning when its first learning cycle is incomplete, otherwise Knowledge Revision;
- `create_new_node`: obtain Structural Acceptance for the target node, create its draft Note, and distill the reusable conclusion into it;
- `no_promotion`: preserve the Investigation without changing formal knowledge.

`origin` identifies the input, `related_nodes` lists contextual nodes other than the target, and `promotion_target` identifies the one primary Knowledge Node actually changed. For `pending` and `no_promotion`, keep `promotion_target: null`. For either promotion outcome, set it to the target node ID, do not duplicate that ID in `related_nodes`, and add the Investigation backlink to the target Note. Do not record a promotion outcome for a recommendation that has not been carried out; keep the Investigation `active` with `outcome: pending`.

Existing `origin` references to archived Domains remain valid, and their nodes may be referenced in `domains` or `related_nodes` as read-only context, but cannot be a `promotion_target`. Do not start a new active-Note Investigation from an archived Domain. Reactivate the target Domain explicitly before creating or revising a target Note; reactivation preserves its Domain ID and does not reopen a terminal Roadmap.

When knowledge is promoted:

1. Distill reusable conclusions; do not copy the full Investigation into the Knowledge Note.
2. Add links in both directions between Knowledge Note, Investigation, and Lab.
3. Update Map or Graph if a new node or relationship was discovered.
4. For `update_existing_node`, continue `study-knowledge-node` when the target Note's initial learning cycle is incomplete; otherwise follow `revise-knowledge-note`. For a newly created Note, follow the initial learning and publication gates. Never publish without explicit author confirmation.

V1 permits one primary promotion target per Investigation. If the conclusion also requires substantive changes to other Notes, start separate Knowledge Revisions for them.

Set `status: closed`, a non-`pending` outcome, and `ended_at` when the conclusion is complete. Use `abandoned` when work stops without a conclusion; set `ended_at`, `outcome: no_promotion`, and `abandon_reason`.

Validate changed frontmatter and YAML against `schemas/` before finishing.
