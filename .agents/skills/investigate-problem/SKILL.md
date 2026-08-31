---
name: investigate-problem
description: Capture and investigate a concrete technical question, incident, anomaly, or observation whose reasoning or evidence trail is worth preserving. Use Inbox for untriaged entry, or start directly from an Active Knowledge Note when the problem is already triaged; do not create files for an ordinary unrecorded question.
---

# Investigate Problem

Preserve the reasoning and evidence behind a concrete problem without forcing every investigation to become permanent knowledge.

## Determine the entry

1. Read `CONTEXT.md` and the problem-driven sections of `KNOWLEDGE-SYSTEM.md`.
2. Search existing Inbox Items, Investigations, Labs, Knowledge Notes, and node IDs for overlap.
3. If the problem is untriaged and did not arise within an Active Knowledge Note workflow, create `inbox/<date>-<slug>.md` from `templates/inbox.md` with observed facts, context, guesses, and questions. A Note is active here exactly when its Domain is `active` and its maturity is `draft`, `reviewed`, or `published`.
4. Triage whether the reasoning and evidence trail is worth preserving independently of the eventual conclusion. A directly closed Inbox Item must set `closed_at` and `close_reason` and must leave `investigation: null`.
5. If the problem was already triaged within an Active Knowledge Note, do not create an Inbox Item. Confirm that it meets the Investigation threshold and use the Note as its origin. `archived` and `superseded` Notes cannot originate a new Investigation.

## Investigation

1. When independent preservation is justified, create `investigations/<slug>.md` from `templates/investigation.md`; keep its `investigation.<slug>` ID aligned with the filename, and apply the same ID/path correspondence to any Inbox Item or Lab created by this workflow.
2. For Inbox entry, set `origin.type: inbox`, point `origin.reference` to the Inbox path, then set the Inbox Item to `promoted` and add its Investigation path.
3. For Active-Note entry, set `origin.type: knowledge_note`, use the Note's node ID as `origin.reference`, and add the Investigation path to the Note immediately.
4. Record hypotheses, Evidence, rejected explanations, current conclusions, uncertainty, and open questions as the work evolves. For each Evidence item, identify which hypothesis or Claim it supports or refutes.
5. Keep primary-source facts, Lab observations, production observations, and inference distinguishable. Record scope and uncertainty, and never use an `invalid` or `abandoned` Lab as support or refutation.
6. Create `labs/<slug>/README.md` from `templates/lab.md` only when experimentation adds useful evidence. An Investigation-owned Lab must set its singular `investigation` field to this Investigation and be listed in `Investigation.labs`; a Note-only explanatory Lab keeps `investigation: null`. Follow the complete reciprocal-link matrix in `KNOWLEDGE-SYSTEM.md`.
7. Keep `domains` complete as references evolve. Include at least the Domain of a Knowledge Note origin and the Domains implied by `related_nodes`, `promotion_target`, and every linked Lab's `related_nodes`; retain any additional Domain materially involved only in the Investigation body.

If a Lab stops without a valid result, mark it `abandoned` with `ended_at` and `end_reason`. Use `invalid` only when an executed experiment cannot support or refute its hypothesis because of a validity problem; neither status may be used as Evidence.

## Close and promote

Close with exactly one outcome:

- `update_existing_node`: distill the reusable conclusion into the existing target Note and continue `initial_learning` when its `knowledge_cycle` says so; otherwise enter or continue Knowledge Revision;
- `create_new_node`: prepare one atomic snapshot containing the new target node, its draft Note, reciprocal links, and the promotion outcome; obtain Structural Acceptance for the structural portion before that exact snapshot is commit-eligible;
- `no_promotion`: preserve the Investigation without changing formal knowledge.

`origin` identifies the input, `related_nodes` lists contextual nodes other than the target, and `promotion_target` identifies the one primary Knowledge Node actually changed. For `pending` and `no_promotion`, keep `promotion_target: null`. For either promotion outcome, set it to the target node ID, do not duplicate that ID in `related_nodes`, and add the Investigation backlink to the target Note. A Knowledge Note origin may equal the promotion target when the Investigation updates the Note that started it. Do not record a promotion outcome for a recommendation that has not been carried out; keep the Investigation `active` with `outcome: pending`.

Existing `origin` references to archived or superseded Notes remain valid, and their nodes may be referenced in `domains` or `related_nodes` as read-only context, but cannot be a `promotion_target`. Do not start a new Investigation from a Note that is not active. Reactivate the target Domain explicitly before creating or revising a target Note; reactivation preserves its Domain ID and does not reopen a terminal Roadmap.

When knowledge is promoted:

1. Distill reusable conclusions; do not copy the full Investigation into the Knowledge Note.
2. Add only the required field-level backlinks defined in `KNOWLEDGE-SYSTEM.md`: origin and promotion-target Notes link the Investigation, contextual `related_nodes` do not; Investigation-owned Labs point to exactly one Investigation; Note/Lab relationships are reciprocal through `labs` and `related_nodes`.
3. If a new node or relationship was discovered, prepare a Structure Proposal and obtain Structural Acceptance of its exact Proposal Snapshot before commit.
4. For `update_existing_node`, require an existing target Note that is not `archived` or `superseded`; explicitly reactivate an archived Note first, or follow a superseded chain and use its eligible non-superseded endpoint as the actual target. Continue `study-knowledge-node` when the eligible target Note has `knowledge_cycle: initial_learning`; otherwise follow `revise-knowledge-note`.
5. For `create_new_node`, require the target Node not to have a Note in the Formal Baseline, create one with `knowledge_cycle: initial_learning` in the same Proposal Snapshot as the Map addition and promotion links, and use standalone mode in `study-knowledge-node` for the remaining initial-learning and publication gates. The snapshot must never commit a Note that references a node absent from the same candidate tree. Never publish without explicit author confirmation.

V1 permits one primary promotion target per Investigation. If the conclusion also requires substantive changes to other Notes, start separate Knowledge Revisions for them.

Before setting an Investigation to a terminal state, resolve every owned Lab to `completed`, `invalid`, or `abandoned`. Set `status: closed`, a non-`pending` outcome, and `ended_at` when the conclusion is complete. Use `abandoned` when work stops without a conclusion; set `ended_at`, `outcome: no_promotion`, and `abandon_reason`. Both states are terminal; renewed work creates a new Investigation instead of restoring this one to `active`.

Update `updated_at` on every changed artifact and run `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb` before finishing.
