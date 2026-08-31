---
name: knowledge-maintenance
description: Validate or repair the knowledge repository's schemas, stable IDs, links, state transitions, Roadmaps, Maps, and Graphs. Use when the user asks to audit, clean, synchronize, or maintain the knowledge system; report only unless the user also asks for fixes.
---

# Knowledge Maintenance

Check repository-wide invariants without changing knowledge claims or maturity on the user's behalf.

## Inspect

1. Read `CONTEXT.md`, `AGENTS.md`, `KNOWLEDGE-SYSTEM.md`, and the schemas relevant to files that exist.
2. Validate JSON Schema files as JSON, then validate Domain YAML and Markdown frontmatter against their schemas when a compatible validator is available.
3. Perform cross-file checks that JSON Schema cannot express:
   - available context showing a semantic change to `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, or a project Skill committed without explicit Governance Acceptance;
   - duplicate IDs, including Node IDs repeated across Maps;
   - Domain directory names, `domain.yaml` IDs, contained `domain` values, or Node and Roadmap ID prefixes that disagree;
   - active Domains with non-null `archived_at` or `archive_reason`, and archived Domains with missing archive metadata;
   - Domains archived while any Roadmap was active or any item was `in_progress`, or available context showing Domain archive/reactivation without an explicit author decision;
   - change history showing archived Domains with new Nodes, Map or Graph changes, new Roadmaps, initial Note work, or substantive Note revisions, plus current nodes used as Investigation `promotion_target`;
   - reactivated Domains whose stable ID changed, whose archive fields were not cleared, whose available context shows no Scope/Map/Graph reassessment, or whose terminal Roadmap was reopened instead of creating a new one;
   - artifact IDs that do not correspond to Knowledge Note, Inbox, Investigation, or Lab paths;
   - missing node and artifact references;
   - Map parents that are missing, cross-Map, self-referential, or cyclic;
   - self edges, duplicate Graph edges, and non-canonical `related` endpoint order;
   - cycles in `prerequisite` edges after combining all Domain Graphs;
   - Graph edges that violate Domain ownership, including cross-Domain `related` edges;
   - Roadmap items owned by a different Domain, duplicate phase IDs, or duplicate item node IDs;
   - completed Roadmaps with unfinished items, no completed items, or missing `ended_at`;
   - archived Roadmaps without `ended_at` or `archive_reason`, archived Roadmaps that still contain `in_progress` items, active Roadmaps with terminal metadata, or Git history showing that a terminal Roadmap was reopened;
   - `in_progress` Roadmap items without Knowledge Notes;
   - `completed` items without Knowledge Notes or `completed_at`;
   - `published` notes without AI review and author confirmation metadata;
   - published Notes whose important Claims lack adjacent traceable Evidence, visible scope when relevant, or that rely on invalid Labs;
   - `superseded` notes without a valid replacement;
   - promoted Inbox Items without an Investigation;
   - Investigations with missing or invalid origins;
   - missing reciprocal links from origin Inbox Items or Knowledge Notes;
   - closed Inbox Items without `closed_at` or `close_reason`;
   - closed Investigations with `pending` outcomes;
   - promotion outcomes without one valid `promotion_target`;
   - `pending` or `no_promotion` Investigations with a non-null target;
   - promotion targets duplicated in `related_nodes`, without the required target action, or without reciprocal Note links;
   - abandoned Investigations without `ended_at`, `outcome: no_promotion`, or `abandon_reason`;
   - missing reciprocal links among Knowledge Notes, Investigations, and Labs;
   - broken Markdown links and stale `updated_at` values.

## Report or repair

- For a validation or review request, return findings with file paths and do not modify files.
- For an explicit repair request, make only mechanical consistency fixes. Do not alter technical conclusions, claim new evidence, publish notes, complete Roadmap items, or rename stable IDs without author direction.
- Route substantive Knowledge Note content changes to `revise-knowledge-note`; mechanical corrections do not change Note maturity.
- Mechanical repairs may be applied to archived Domains; do not turn them into structural or substantive changes without explicit reactivation.
- Treat Governance Acceptance, Structural Acceptance, explicit author decisions, and structural reassessment as change-time or transition-time workflow gates. Check them only when interaction or change history supplies evidence; the absence of a separate approval record in repository files is not itself a violation.
- Separate Schema violations, cross-file consistency errors, and optional improvements.
- Re-run all affected checks after repairs.
