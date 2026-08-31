# Glossary

## Domain

A long-lived area of knowledge with a stable purpose, scope, and boundary, such as Kubernetes or Linux. Concrete learning goals belong to Roadmaps. A topic is not automatically a Domain. An archived Domain may later be reactivated under the same stable ID; its terminal Roadmaps are never reopened.

## Knowledge Node

A stable, uniquely identified concept that can appear in a Knowledge Map, Dependency Graph, or Roadmap. A Knowledge Node may exist before a Knowledge Note is created.

## Knowledge Note

The maintained Markdown document containing the author's current best understanding of one Knowledge Node. It is created only when work on the node begins, and its `knowledge_cycle` distinguishes unfinished initial learning from an unfinished later revision.

## Active Knowledge Note

A Knowledge Note that may serve as a direct Investigation origin: its Domain is `active` and its maturity is `draft`, `reviewed`, or `published`. This is a derived workflow condition, not another persisted Note status; `archived` and `superseded` Notes are not active.

## Knowledge Revision

A substantive update to an existing Knowledge Note after its initial learning cycle, prompted by new evidence, version changes, or improved understanding. It excludes mechanical edits and does not reopen completed Roadmap items.

## Knowledge Map

The accepted planning inventory and classification of Knowledge Nodes. It answers what the Domain contains, not what order to learn it in, and does not by itself assert that a Node description has passed knowledge Review or Publish.

## Dependency Graph

The accepted planning model of typed relationships between Knowledge Nodes. V1 supports `prerequisite` and `related` relationships. Edges and rationales guide structure and learning order but are not substitutes for Evidence in a Knowledge Note. A cross-Domain prerequisite is owned by the `to` node's Domain Graph; cross-Domain `related` relationships are outside V1.

## Roadmap

A goal-specific learning path that selects and orders existing Knowledge Nodes. A Domain can have multiple Roadmaps.

## Structure Proposal

An uncommitted addition or structural change to a Domain, Knowledge Map, Dependency Graph, or Roadmap that is awaiting the author's review as an exact Proposal Snapshot. Routine learning-progress updates and mechanical edits are not Structure Proposals.

## Structural Acceptance

The author's explicit approval of one exact Structure Proposal Snapshot, identified by its base commit and candidate Git tree. It makes only that unchanged snapshot eligible to be committed as the current formal structure. It neither instructs AI to perform the commit nor confirms the understanding or publication of Knowledge Note content.

## Governance Proposal

An uncommitted semantic change to the knowledge system contract: `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, or the project Skills and their supporting validation resources. It is reviewed as an exact Proposal Snapshot and cannot authorize its own adoption. Mechanical edits that do not change system meaning are not Governance Proposals.

## Governance Acceptance

The author's explicit approval of one exact Governance Proposal Snapshot, identified by its base commit and candidate Git tree. It makes only that unchanged snapshot eligible to be committed as the current system contract. It does not instruct AI to commit the change and does not imply Structural Acceptance or publication of knowledge content.

## Formal Baseline

The tree of the currently checked-out commit (`HEAD`). It is the current authoritative repository state while working-tree and index changes remain candidates. A Governance Proposal is evaluated under this baseline and cannot use its candidate rules to weaken a baseline gate.

## Proposal Snapshot

The exact candidate Git tree reviewed for Governance Acceptance or Structural Acceptance, paired with its base commit. Acceptance is invalidated by any change to the candidate tree; working-tree content outside that tree is not part of the accepted proposal.

## Inbox Item

An untriaged record of a concrete question, incident, observation, or idea that did not arise already triaged within an Active Knowledge Note workflow.

## Investigation

A time-bounded inquiry whose hypotheses, evidence, rejected explanations, and reasoning trail are worth preserving independently of its final conclusion. It originates from either a triaged Inbox Item or an Active Knowledge Note. Its closed and abandoned states are terminal; materially renewed work uses a new Investigation and preserves the old one as history.

## Knowledge Promotion

The completed transfer of one Investigation's reusable conclusion into one primary Knowledge Node, either by updating its existing Note through that Note's current learning or revision workflow, or by creating the node and a draft Note. Promotion does not mean that the target Note is published.

## Lab

A reproducible experiment used to test a hypothesis or observe behaviour. A Lab is optional and exists only when experimentation adds useful evidence. `invalid` means its result cannot support or refute a Claim; `abandoned` means the experiment stopped without being completed and is not a synonym for invalidity.

## Claim

A statement presented as true or plausible in a Knowledge Note or Investigation. Important Claims require traceable support and a visible scope or uncertainty when relevant.

## Evidence

The role played by a source, valid Lab result, production observation, or explicit reasoning when it supports or refutes a specific Claim. Evidence is not an artifact or required section; its type, scope, and uncertainty must remain visible next to the Claim.

## Knowledge Formation Stage

A stage in the work of turning a question or planned topic into maintained knowledge, such as Explore or Review. It describes what work is happening and is not a persisted status shared by every artifact.

## Learning Status

The progress of a Knowledge Node within one Roadmap: `planned`, `in_progress`, `completed`, or `skipped`. `completed` is an independent historical record that the author achieved and confirmed that Roadmap's learning goal for the item; `skipped` records an explicit decision not to pursue it in that Roadmap. Both are terminal within that Roadmap. Relearning from an unchanged published Note does not require artificial republication, and later Note changes do not rewrite the completed event.

## Knowledge Maturity

The state of a Knowledge Note: `draft`, `reviewed`, `published`, `superseded`, or `archived`.

## Knowledge Cycle

The workflow owning an unfinished Knowledge Note: `initial_learning` or `revision`. Initial learning is usually Roadmap-backed, but may instead continue without a Roadmap when an Investigation creates a new Note or an explicitly reactivated Note resumes its interrupted first learning cycle. The cycle is required while maturity is `draft` or `reviewed`, becomes `null` after publication or supersession, and is preserved when unfinished work is explicitly archived.
