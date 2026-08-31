---
name: knowledge-maintenance
description: Validate or mechanically repair the knowledge repository, prepare an explicitly requested Governance Proposal, or perform an explicitly directed stable-ID migration. Covers schemas, IDs, links, states, Roadmaps, Maps, Graphs, and proposal snapshots; report only unless the user asks for changes.
---

# Knowledge Maintenance

Check repository-wide invariants without changing knowledge claims or maturity on the user's behalf. Governance edits remain an unaccepted Governance Proposal until the author accepts the exact staged snapshot.

## Inspect

1. Read the Formal Baseline versions of `CONTEXT.md`, `AGENTS.md`, and `KNOWLEDGE-SYSTEM.md`, then inspect their working-tree and index diffs separately. Candidate governance rules cannot authorize themselves or weaken a baseline gate.
2. Run `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb`. Validate the working tree during construction and the Git index before requesting acceptance; for an explicitly directed stable-ID migration, pass every author-specified mapping as `--migration old=new`. Report any check the validator cannot perform, including an artifact modification date unavailable from the validated view.
3. Perform cross-file checks that JSON Schema cannot express:
   - Formal Baseline, index, and working tree conflated; a Proposal Snapshot missing its base commit or candidate tree; post-acceptance changes, partial commits, or available context showing a semantic change to `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, a project Skill, or supporting validation resources committed without Governance Acceptance of that exact snapshot;
   - an artifact Schema's machine-validation semantics changed without incrementing that artifact type's `schema_version`, a required template is absent or disagrees with the current version, or existing instances remain on an unsupported version without an explicit migration; documentation-only Schema metadata does not require a bump;
   - duplicate IDs, including Node IDs repeated across Maps;
   - Domain directory names, `domain.yaml` IDs, contained `domain` values, or Node and Roadmap ID prefixes that disagree;
   - active Domains with non-null `archived_at` or `archive_reason`, and archived Domains with missing archive metadata;
   - Domains archived while any Roadmap was active, any item was `in_progress`, any non-archived Note was `draft` or `reviewed`, any active Investigation originated from a Domain Note, or any `planned`/`running` Lab was tied through a Domain node, Note, or Investigation, plus available context showing another active Investigation still intended to modify the Domain or Domain archive/reactivation lacked an explicit author decision;
   - change history showing archived Domains with new Nodes, Map or Graph changes, new Roadmaps, initial Note work, or substantive Note revisions, plus current nodes used as Investigation `promotion_target`;
   - reactivated Domains whose stable ID changed, whose archive fields were not cleared, whose available context shows no purpose/Scope/Map/Graph reassessment, whose terminal Roadmap was reopened, or whose resumed systematic learning did not use a new Roadmap;
   - artifact IDs that do not correspond to Knowledge Note, Inbox, Investigation, or Lab paths;
   - missing node and artifact references;
   - Map parents that are missing, cross-Map, self-referential, or cyclic;
   - self edges, duplicate Graph edges, and non-canonical `related` endpoint order;
   - cycles in `prerequisite` edges after combining all Domain Graphs;
   - Graph edges that violate Domain ownership, including cross-Domain `related` edges;
   - Roadmap items owned by a different Domain, duplicate phase IDs, or duplicate item node IDs;
   - completed Roadmaps with unfinished items, no completed items, or missing `ended_at`; `completed` or `skipped` items restored within the same Roadmap;
   - archived Roadmaps without `ended_at` or `archive_reason`, archived Roadmaps that still contain `in_progress` items, active Roadmaps with terminal metadata, or Git history showing that a terminal Roadmap was reopened;
   - `in_progress` Roadmap items without Knowledge Notes;
   - `in_progress` Roadmap items whose Knowledge Notes are archived or superseded;
   - `completed` items without Knowledge Notes or `completed_at`;
   - `draft` or `reviewed` Notes without `knowledge_cycle: initial_learning|revision`, `published` or `superseded` Notes with a non-null cycle, or archived Notes whose cycle disagrees with `archived_from`;
   - `published` notes without AI review and author confirmation metadata;
   - published Notes whose important Claims lack adjacent traceable Evidence, visible scope when relevant, or that rely on invalid or abandoned Labs;
   - archived Notes without valid `archived_from`, `archived_at`, and `archive_reason`, restored Notes retaining archive metadata, or available context showing archival/reactivation without explicit author direction;
   - reviewed Notes substantively changed after Review without returning to `draft` and resetting current review metadata;
   - `superseded` Notes that were not previously published, lack `superseded_at`, replace themselves, target a missing Note, form a replacement cycle, or belong to a replacement chain whose endpoint is not `published` or a previously published `draft`/`reviewed` Note with `knowledge_cycle: revision`;
   - promoted Inbox Items without an Investigation;
   - Investigations with missing or invalid origins;
   - Investigation `domains` that omit a Domain implied by a Knowledge Note origin, `related_nodes`, `promotion_target`, or a linked Lab's `related_nodes`, or that name a missing Domain;
   - missing reciprocal links from origin Inbox Items or Knowledge Notes under the field-level matrix in `KNOWLEDGE-SYSTEM.md`;
   - closed Inbox Items without `closed_at` or `close_reason`;
   - closed Investigations with `pending` outcomes;
   - promotion outcomes without one valid `promotion_target`;
   - `pending` or `no_promotion` Investigations with a non-null target;
   - promotion targets duplicated in `related_nodes`, without the required target action, or without reciprocal Note links; available transition history showing `update_existing_node` used a missing, archived, or superseded Note, or `create_new_node` used a Node that already had a Note; a Knowledge Note origin equal to the target is valid when that source Note was the Note updated by the Investigation;
   - abandoned Investigations without `ended_at`, `outcome: no_promotion`, or `abandon_reason`;
   - closed or abandoned Investigations with linked `planned` or `running` Labs, or Git history showing a promoted/closed Inbox Item or closed/abandoned Investigation restored to a non-terminal state;
   - completed Labs without `ended_at`, invalid or abandoned Labs without `ended_at` and `end_reason`, terminal Labs restored to active states, or invalid/abandoned Labs used as Evidence;
   - reciprocal-link matrix violations: a contextual `related_nodes` entry incorrectly required as a Note backlink, Note `investigations` entries without origin/target semantics, Investigation-owned Labs without an exact singular owner, Labs owned by multiple Investigations, or asymmetric Note `labs` / Lab `related_nodes`;
   - broken Markdown links and stale `updated_at` values under the rule that every artifact content/frontmatter change, including mechanical repair and migration, updates the date.

## Report or repair

- For a validation or review request, return findings with file paths and do not modify files.
- For an explicit repair request, make only mechanical consistency fixes. Do not alter technical conclusions, claim new evidence, publish notes, complete Roadmap items, or rename stable IDs without author direction.
- For an explicit request to change this system contract, prepare the semantic edits as one Governance Proposal under the Formal Baseline. Stage and validate the complete proposal only when it is ready for review; report the base commit, candidate tree, and excluded working-tree changes. Do not commit without Governance Acceptance of that exact snapshot.
- For an explicit stable-ID rename, follow the atomic migration contract in `KNOWLEDGE-SYSTEM.md`; Domain/Node/Roadmap renames also require Structural Acceptance. Reference-only migration repairs may update archived or terminal artifacts without reopening them. Supply the author's complete old → new mapping to validation with repeated `--migration old=new` arguments so history checks follow renamed artifacts and terminal item references.
- Route substantive Knowledge Note content changes to `revise-knowledge-note`; mechanical corrections do not change Note maturity.
- Mechanical repairs may be applied to archived Domains; do not turn them into structural or substantive changes without explicit reactivation.
- Treat Governance Acceptance, Structural Acceptance, explicit author decisions, and structural reassessment as change-time or transition-time workflow gates. Check them only when interaction or change history supplies evidence; the absence of a separate approval record in repository files is not itself a violation, but acceptance for one snapshot never transfers to another.
- Separate Schema violations, cross-file consistency errors, and optional improvements.
- Re-run all affected checks after repairs.
