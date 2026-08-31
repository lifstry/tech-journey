# Glossary

## Domain

A long-lived area of knowledge with an explicit learning goal, scope, and boundary, such as Kubernetes or Linux. A topic is not automatically a Domain. An archived Domain may later be reactivated under the same stable ID; its terminal Roadmaps are never reopened.

## Knowledge Node

A stable, uniquely identified concept that can appear in a Knowledge Map, Dependency Graph, or Roadmap. A Knowledge Node may exist before a Knowledge Note is created.

## Knowledge Note

The maintained Markdown document containing the author's current best understanding of one Knowledge Node. It is created only when work on the node begins.

## Knowledge Revision

A substantive update to an existing Knowledge Note after its initial learning cycle, prompted by new evidence, version changes, or improved understanding. It excludes mechanical edits and does not reopen completed Roadmap items.

## Knowledge Map

The domain inventory and classification of Knowledge Nodes. It answers what the Domain contains, not what order to learn it in.

## Dependency Graph

The typed relationships between Knowledge Nodes. V1 supports `prerequisite` and `related` relationships. A cross-Domain prerequisite is owned by the `to` node's Domain Graph; cross-Domain `related` relationships are outside V1.

## Roadmap

A goal-specific learning path that selects and orders existing Knowledge Nodes. A Domain can have multiple Roadmaps.

## Structure Proposal

An uncommitted addition or structural change to a Domain, Knowledge Map, Dependency Graph, or Roadmap that is awaiting the author's review. Routine learning-progress updates and mechanical edits are not Structure Proposals.

## Structural Acceptance

The author's explicit approval of a Structure Proposal, making it eligible to be committed as the current formal structure. It neither instructs AI to perform the commit nor confirms the understanding or publication of Knowledge Note content.

## Governance Proposal

An uncommitted semantic change to the knowledge system contract: `AGENTS.md`, `CONTEXT.md`, `KNOWLEDGE-SYSTEM.md`, `schemas/`, `templates/`, or the project Skills. Mechanical edits that do not change system meaning are not Governance Proposals.

## Governance Acceptance

The author's explicit approval of a Governance Proposal, making it eligible to be committed as the current system contract. It does not instruct AI to commit the change and does not imply Structural Acceptance or publication of knowledge content.

## Inbox Item

An untriaged record of a concrete question, incident, observation, or idea that did not arise already triaged within an active Knowledge Note workflow.

## Investigation

A time-bounded inquiry whose hypotheses, evidence, rejected explanations, and reasoning trail are worth preserving independently of its final conclusion. It originates from either a triaged Inbox Item or an active Knowledge Note.

## Knowledge Promotion

The completed transfer of one Investigation's reusable conclusion into one primary Knowledge Node, either by updating its existing Note through that Note's current learning or revision workflow, or by creating the node and a draft Note. Promotion does not mean that the target Note is published.

## Lab

A reproducible experiment used to test a hypothesis or observe behaviour. A Lab is optional and exists only when experimentation adds useful evidence.

## Claim

A statement presented as true or plausible in a Knowledge Note or Investigation. Important Claims require traceable support and a visible scope or uncertainty when relevant.

## Evidence

The role played by a source, valid Lab result, production observation, or explicit reasoning when it supports or refutes a specific Claim. Evidence is not an artifact or required section; its type, scope, and uncertainty must remain visible next to the Claim.

## Knowledge Formation Stage

A stage in the work of turning a question or planned topic into maintained knowledge, such as Explore or Review. It describes what work is happening and is not a persisted status shared by every artifact.

## Learning Status

The progress of a Knowledge Node within one Roadmap: `planned`, `in_progress`, `completed`, or `skipped`. `completed` is an independent historical record that the author achieved and confirmed that Roadmap's learning goal for the item. Relearning from an unchanged published Note does not require artificial republication, and later Note changes do not rewrite the completed event.

## Knowledge Maturity

The state of a Knowledge Note: `draft`, `reviewed`, `published`, `superseded`, or `archived`.
