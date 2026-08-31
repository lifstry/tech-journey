# `tech-journey` 知识沉淀体系

> 来源：[GitHub 工程命名建议（ChatGPT 共享对话）](https://chatgpt.com/share/6a8fab48-ef2c-83ea-a671-4dde185bd2b4)
>
> V1 整理日期：2026-08-27
>
> 本文只定义知识沉淀和 AI 协作流程，不包含仓库权限、分支、Pull Request 或合并策略；Git tree 和提交用于表达正式基线、提案快照以及治理和结构接受边界。

## 1. 项目定位

`tech-journey` 是一套长期维护的个人工程知识系统，用于记录技术学习、工程知识和认知变化。它的目标不是积累 AI 生成的文章，而是保存自己当前经过理解和适当验证的最佳认知，以及形成这些认知的依据和过程。V1 不建模项目执行日志或职业记录。

最高原则是：

```text
AI Generated != Learned != Understood != Verified
```

AI 可以承担导航、教学、研究、审查和编辑工作，但理解、判断和最终确认的主体始终是自己。

### 1.1 规范权威与治理边界

当前检出提交 `HEAD` 的 tree 是 **Formal Baseline**。其中提交到 Git 的 Markdown、YAML 和 JSON 是各自职责范围内的权威仓库记录；working tree 和 index 中尚未提交的内容只是候选变化，不是当前权威。这里的“权威”表示文件共同记录系统当前状态，不表示其中每个 Claim 都真实、已理解或已验证。发生冲突时不得静默任选一份解释，各文件的职责顺序是：

- `AGENTS.md` 定义全局不变量和工作流路由；
- `CONTEXT.md` 定义规范术语；
- `KNOWLEDGE-SYSTEM.md` 定义工作流和生命周期语义；
- `schemas/*.json` 定义可机器验证的文件结构，不得改变或削弱上面的语义；
- `templates/` 和项目级 Skill 负责实现和引导上述规则，不能覆盖它们。

对 `AGENTS.md`、`CONTEXT.md`、`KNOWLEDGE-SYSTEM.md`、`schemas/`、`templates/`、项目级 Skill 或其配套验证资源的语义修改都是 **Governance Proposal**。候选治理规则不能授权自身生效或削弱 Formal Baseline 的门槛；在它提交以前，其他仓库工作仍按 Formal Baseline 判断授权和状态。只有自己审阅一个由 base commit 和 candidate Git tree 唯一标识的 **Proposal Snapshot**，并明确作出 **Governance Acceptance** 后，完全相同的 snapshot 才具备提交资格。snapshot 发生任何变化都会使该次接受失效；接受不等于要求 AI 执行提交，也不代替 Structure Proposal 的 Structural Acceptance 或 Knowledge Note 的发布确认。不改变系统含义的格式、拼写和链接修复不属于 Governance Proposal。

请求 Governance Acceptance 或 Structural Acceptance 前，必须把该提案的全部文件完整放入 Git index，对 index 本身而不是只对 working tree 执行验证，记录 base commit 与 candidate tree，并披露未包含在 snapshot 中的其他 working-tree 修改。接受后只能原子提交该 index；部分提交、补充暂存、base commit 改变或任何接受后的语义修改都需要生成新 snapshot 并重新接受。同一个 snapshot 可以同时包含治理和结构变化，但必须分别取得所有适用的 Governance Acceptance 与 Structural Acceptance。为了避免未接受的 `AGENTS.md` 或 Skill 提前影响普通知识工作，治理提案工作区只用于构造和审查提案，不在同一未接受快照上执行无关的 Domain、学习、修订或 Investigation 工作。

## 2. 统一术语

所有规范术语见 [CONTEXT.md](CONTEXT.md)，其中最重要的区别是：

- **Domain**：具有稳定 purpose、明确范围和边界的长期知识领域；具体学习 goal 属于 Roadmap；
- **Knowledge Node**：Map、Graph 和 Roadmap 中具有稳定 ID 的知识主题；
- **Knowledge Note**：一个 Knowledge Node 当前最佳理解的正式 Markdown 文档；
- **Active Knowledge Note**：所属 Domain 为 `active`，且 maturity 为 `draft`、`reviewed` 或 `published` 的 Note；它是工作流判断，不是新的持久化状态；
- **Knowledge Revision**：初次学习周期结束后，因新证据、版本变化或理解改进而对已有 Knowledge Note 进行的实质修订；
- **Knowledge Cycle**：当前未完成 Note 由初次学习还是后续修订工作流负责；
- **Knowledge Map**：作为已接受的规划模型，说明 Domain 包含什么以及如何分类；
- **Dependency Graph**：作为已接受的规划模型，说明 Knowledge Node 之间的依赖和关联；
- **Roadmap**：针对某个目标，从 Map/Graph 中选择并排序的一条学习路径；
- **Structure Proposal**：尚未提交、等待自己审阅的 Domain、Map、Graph 或 Roadmap 结构变更；
- **Structural Acceptance**：自己明确接受一个 exact Structure Proposal Snapshot、允许该不变快照提交为正式结构的决定；
- **Governance Proposal**：对知识系统规范、Schema、模板或项目级 Skill 的未提交语义修改；
- **Governance Acceptance**：自己明确接受一个 exact Governance Proposal Snapshot、允许该不变快照提交为当前系统规范的决定；
- **Formal Baseline**：当前检出提交 `HEAD` 的权威 Git tree；
- **Proposal Snapshot**：由 base commit 与 candidate Git tree 精确标识、供 Governance 或 Structural Acceptance 审阅的候选快照；
- **Inbox Item**：尚未在活跃知识工作流中完成分诊的具体问题、异常、观察或想法；
- **Investigation**：推理和证据链本身值得独立保存的问题调查档案，来源只能是 Inbox Item 或 Active Knowledge Note；
- **Knowledge Promotion**：把一项 Investigation 的可复用结论通过目标 Note 当前所属的学习或修订流程，实际落实到一个主要 Knowledge Node 的动作，不等于该目标 Note 已发布；
- **Lab**：为验证假设而进行的可复现实验；
- **Claim**：在 Knowledge Note 或 Investigation 中被表达为成立或可能成立的陈述；
- **Evidence**：资料、有效实验结果、实践观察或明确推理对某个具体 Claim 提供支持或反驳时承担的角色，不是固定章节或独立工件。

Knowledge Node 不等于 Knowledge Note。节点可以先存在于 Map、Graph 和 Roadmap 中；只有真正开始学习或形成内容时才创建 Knowledge Note。因此，不需要为所有 Roadmap 节点批量创建空文档。

## 3. 内容组织

```text
tech-journey/
|-- AGENTS.md
|-- CONTEXT.md
|-- KNOWLEDGE-SYSTEM.md
|-- .agents/skills/
|   |-- domain-bootstrap/
|   |-- study-knowledge-node/
|   |-- revise-knowledge-note/
|   |-- investigate-problem/
|   `-- knowledge-maintenance/
|-- domains/
|   `-- <domain>/
|       |-- domain.yaml
|       |-- map.yaml
|       |-- graph.yaml
|       |-- roadmaps/
|       `-- knowledge/
|-- inbox/
|-- investigations/
|-- labs/
|-- schemas/
`-- templates/
```

`domains/`、`inbox/`、`investigations/` 和 `labs/` 下的实际目录按工作流需要延迟创建，不预先制造空目录或占位内容。

### 文件职责

| 文件 | 唯一职责 |
| --- | --- |
| `domain.yaml` | Domain 的身份、范围、排除项、状态和归档信息 |
| `map.yaml` | Knowledge Node 清单及分类层级 |
| `graph.yaml` | Knowledge Node 之间的有类型关系 |
| `roadmaps/*.yaml` | 某一目标的学习顺序和进度 |
| `knowledge/*.md` | 已开始或已完成节点的当前最佳理解 |
| `inbox/*.md` | 尚未分诊的问题捕获 |
| `investigations/*.md` | 假设、证据、推理过程和调查结果 |
| `labs/*/README.md` | 可复现实验及观察结果 |

## 4. 知识形成阶段

知识形成阶段描述“当前应该做什么工作”，不是所有文件共用的一套状态，也不要求每项内容机械经过所有阶段。具体文件状态由第 8 节分别定义。

### Capture / Plan：捕获或规划

- 问题驱动：把具体问题、异常、观察或想法记录为 Inbox Item，避免信息丢失；
- 系统学习：把 Knowledge Node 放入 Roadmap，并标记为 `planned`。

本阶段只确认“值得以后处理”，不表示已经理解或验证。

### Triage / Select：分诊或选择

- 问题驱动：判断问题是否重复、是否值得深入、归属哪个 Domain、推理和证据链是否值得通过 Investigation 独立保存；
- 系统学习：结合 Roadmap、前置依赖和当前目标选择下一个 Knowledge Node。

本阶段的输出是明确的下一步，也允许关闭、跳过或推迟。

### Explore：探索

围绕核心问题讨论、查阅资料、提出假设、建立概念关系并识别未知点。探索材料仍可能包含错误、推测和相互冲突的解释，不能直接视为正式知识。

### Evidence：建立依据

为重要 Claim 补充适合其类型的依据，包括权威资料、可复现实验、生产观察或明确推理。Evidence 是“依据支持或反驳哪个 Claim”的关系，不是固定章节；在 Knowledge Note 中应紧邻重要 Claim 记录。不是所有内容都需要 Lab，也不要求给普通连接句或无争议背景逐句标注，但必须遵守以下最小契约：

- `Sourced fact`：紧邻 Claim 链接权威来源；版本敏感内容记录版本或时间边界；
- `Observation`：记录观察来源；Lab 观察链接 Lab，生产观察记录作者提供的时间、环境和上下文；AI 不得生成生产观察；
- `Inference`：明确说明它基于哪些事实、观察或已陈述前提，以及仍有何不确定性；明确推理可以支撑 Inference，但不能代替经验性 Claim 所需的资料或观察；不得把 Inference 伪装成 sourced fact；
- `Author understanding`：保留作者自己的综合解释及适用边界；AI 不得代替作者制造个人结论；
- `invalid` 或 `abandoned` Lab 可以保留失败或停止过程和限制，但不能用于支持或反驳 Claim；
- 文末 `Sources` 只作为参考书目，不能代替 Claim 与 Evidence 的就地对应关系。

V1 通过上述 Markdown 写作契约表达 Claim 与 Evidence，不为它们分配稳定 ID，不创建独立 Evidence 文件，也不增加 Evidence Schema。

### Distill：提炼

把探索和证据中的可复用内容整理成 Knowledge Note 草稿，区分 sourced fact、observation、inference 和 author understanding，并让重要 Claim 与 Evidence 保持相邻。Investigation 的完整过程不会被复制到 Knowledge Note。

### Review：审查

检查事实错误、证据不足、逻辑漏洞、遗漏、重复节点、适用边界和与已有知识的冲突。审查完成后，Knowledge Note 可以从 `draft` 进入 `reviewed`。`reviewed` 表示当前内容快照通过了 AI Review；作者确认前发生任何实质内容修改，都必须在相同 `knowledge_cycle` 中回到 `draft`，把 `ai_reviewed`、`author_confirmed` 设为 `false`，并清空 `reviewed_at` 和 `published_at`，完成新一轮 Review 后才能再次进入 `reviewed`。

### Publish：发布

自己确认已经理解并接受当前内容后，将初次学习或修订后的 Knowledge Note 标记为 `published`。如果当前 Roadmap item 正通过这次初次发布或重新发布完成，同时将该 item 标记为 `completed` 并记录 `completed_at`。再次学习已有 `published` Note 且内容无需实质修改时，不发生新的 Publish 转换；自己确认达到本次 Roadmap 目标后直接完成该 item。`completed` 保存这次学习已经完成的历史事实，不表示 Knowledge Note 永远保持 `published`。AI 不得自行完成此阶段。

### Maintain：维护

在新资料、新实验或新实践出现后，由 `revise-knowledge-note` 复查和修订已有知识。需要实质修改时，Knowledge Note 从 `published` 回到 `draft`，设置 `knowledge_cycle: revision`，并重置当前版本的 `ai_reviewed`、`author_confirmed`、`reviewed_at` 和 `published_at`。重新发布后把 `knowledge_cycle` 清空为 `null`。既有 Roadmap item 仍保持 `completed`，因为它记录的是此前已经完成的学习事件。格式、拼写、链接或日期等不改变知识含义的机械修改不进入 Knowledge Revision，也不改变 maturity 或 knowledge cycle。

### Supersede / Archive：替代或归档

- `superseded`：一个此前已经 `published` 的 Knowledge Note 被另一个 Note 明确替代；发生转换时直接目标必须是另一个当前 `published` 的 Note，记录 `superseded_by` 和 `superseded_at`。以后可以继续延长替代链，但整条链必须无环，并终止于一个非 `archived`、非 `superseded` 的 Note；该终点通常是 `published`，也可以在此前已经发布、当前正在 `knowledge_cycle: revision` 时暂时为 `draft` 或 `reviewed`；
- `archived`：自己明确决定停止维护或停止未完成工作；记录 `archived_from`、`archived_at` 和 `archive_reason`。如果从 `draft` 或 `reviewed` 归档，保留原 `knowledge_cycle`，表示将来重新启用时应回到哪条工作流；从 `published` 归档时 cycle 保持 `null`。

两条入口工作流不需要经过完全相同的阶段：Map 驱动的节点不需要先进入 Inbox，简单事实不一定需要 Lab，Investigation 也可能不产生 Knowledge Note。Map、Graph 和 Roadmap 通过 Structural Acceptance 成为当前规划结构，但这不表示其中的描述、关系或 rationale 已被验证；只有提炼进 Knowledge Note、作为当前最佳理解发布的内容才必须经过相同的 Evidence、Review 和 Publish 门槛。

## 5. 系统学习与知识修订工作流

### 5.1 创建、调整、归档或重新激活 Domain

触发条件：准备系统学习、结构性调整、归档或重新激活一个领域。

由 `domain-bootstrap` Skill 执行：

1. 确认 Domain 当前状态，以及本次是创建、调整、归档还是重新激活；创建或调整时，与自己确认长期 purpose、当前基础、包含范围和明确排除项；存在具体学习 goal 时再为 Roadmap 记录；
2. 判断主题应该成为新 Domain、归入现有 Domain，还是只是一个 Knowledge Node；
3. 从模板创建 `domains/<domain>/domain.yaml`、`map.yaml` 和 `graph.yaml`；
4. 通过多轮讨论形成最小可用 Map 和 Graph，把它们视为可持续修订的当前模型；
5. 存在具体学习目标时，在 `roadmaps/` 下创建一条 Roadmap；
6. 在 Domain 初始化阶段不创建任何 Knowledge Note。

新建或结构性修改的 Domain、Map、Graph 和 Roadmap 在提交前都是 **Structure Proposal**。结构性修改包括 Domain 边界变化，Knowledge Node 的新增、删除、稳定 ID、定义或父级变化，Graph 关系的新增、删除或语义变化，以及 Roadmap 目标、阶段、节点成员或顺序变化。Roadmap item 的日常学习状态与时间更新、日期同步、格式化和不改变含义的文字修正不属于 Structure Proposal；稳定 ID migration 仍属于 Structure Proposal。

AI 可以生成和修改提案，但只有自己审阅由 base commit 与 candidate tree 标识的完整 **Proposal Snapshot**，并明确作出 **Structural Acceptance** 后，完全相同的 snapshot 才具备提交资格，并在原子提交到 Git 后成为当前正式结构。Structural Acceptance 是提交的必要条件，不等于要求 AI 执行提交；接受后的任何 snapshot 变化都必须重新接受。V1 不为这些结构文件增加第二套审核状态；Formal Baseline 与 Proposal Snapshot 的 Git tree 边界承担这一职责。Structural Acceptance 只确认 Map、Graph、Roadmap 等规划结构适合当前使用；其中的 Node 描述、Graph edge 和 rationale 不是已发布知识，不能替代 Knowledge Note 中 Claim 所需的 Evidence、Review 或作者确认。

Domain 是长期知识边界，因此 `archived` 不是永久终态。归档和重新激活都必须由自己明确决定，并遵守：

- 归档前，该 Domain 的全部 Roadmap 必须已经是 `completed` 或 `archived`，并且不存在 `in_progress` item；所有非 archived Knowledge Note 都不能处于 `draft` 或 `reviewed`，未完成 Note 必须先完成或由自己明确归档；
- 归档前，来源为该 Domain Knowledge Note 的 active Investigation 必须先 `closed` 或 `abandoned`；其他来源但通过 `domains`、`related_nodes` 或 Lab 涉及该 Domain 的 active Investigation，必须确认它只把该 Domain 当作只读上下文，否则先完成、放弃或落实目标动作；
- 归档前，与该 Domain 节点关联、被其 Note 链接，或属于上述 Investigation 的 Lab 不能是 `planned` 或 `running`，必须先变为 `completed`、`invalid` 或 `abandoned`；满足门槛后设置 Domain `status: archived`、`archived_at` 和非空 `archive_reason`；
- 归档后保留 Domain ID、Scope、Map、Graph、Roadmap、Knowledge Note 及已有引用，不自动改变其中工件的状态；跨 Domain 的只读引用仍然有效；
- 归档期间不新增 Knowledge Node，不修改该 Domain 的 Map 或 Graph，不创建 Roadmap，不开始或修订 Knowledge Note，也不能把其中节点作为 Investigation 的 `promotion_target`；只允许不改变知识或结构含义的机械修复；
- 重新激活时保留原 Domain ID，恢复 `status: active`，并把 `archived_at` 和 `archive_reason` 清空为 `null`；随后重新评估 purpose、Scope、Map 和 Graph，任何结构变化仍是 Structure Proposal；
- 只有重新开始系统学习时才创建一条新的 active Roadmap；仅为修订 Note、完成 Investigation promotion 或其他维护动作而重新激活时不强制创建 Roadmap。既有 `completed` 或 `archived` Roadmap 始终是终态，不得恢复。

### 5.2 学习或再次学习一个节点

触发条件：从 Roadmap 中选定一个 Knowledge Node，或者继续一个由 Investigation promotion 创建、或从归档状态明确恢复的 `initial_learning` Knowledge Note。

由 `study-knowledge-node` Skill 执行：

1. 确认所属 Domain 是 `active`，节点存在于 `map.yaml`，并判断本次初次学习是否由 Roadmap 支持；Roadmap-backed 学习还必须确认 Roadmap 是 `active` 且引用该节点；standalone 初次学习只允许继续已经由 Investigation promotion 创建、或由自己明确恢复的 `draft`/`reviewed`、`knowledge_cycle: initial_learning` Note，不能借此绕过结构或捕获工作流随意新建 Note；
2. 检查 `prerequisite`，明确先学习、已掌握或暂时跳过；跨 Domain 前置节点仍由其自己的 Domain 管理，存在 Roadmap 时也不加入当前 Roadmap；
3. Roadmap-backed item 为 `planned` 时，只把它改为 `in_progress`；已经是 `in_progress` 时保持原状并继续，不能隐式恢复 `completed` 或 `skipped` item；standalone 初次学习不制造 Roadmap item；
4. Roadmap-backed 学习中，如果当前节点没有 Knowledge Note，只为当前节点创建 `knowledge/<node-slug>.md`，初始为 `draft`、`knowledge_cycle: initial_learning`；standalone 初次学习必须已经存在 Note。Note 已存在时按下述“已有 Note”规则处理，不能覆盖或重复创建；
5. 记录本次学习目标、自己的初始或当前理解和核心问题；Roadmap-backed 模式使用当前 item 的目标，standalone 模式只记录 Note 的初次学习目标，不制造 Roadmap 语义；
6. 与 AI 讨论，查阅资料，必要时创建 Lab；
7. 用自己的话重新解释核心概念、关系和边界；
8. 由 AI 检查事实错误、证据不足、遗漏、边界和与已有知识的冲突；
9. 对新建 Note 或发生实质修订的 Note，审查完成后改为 `reviewed`；已有 `published` Note 经检查无需实质修改时保持 `published` 及原有审核、发布时间元数据；
10. 新建或修订的 Note 只有自己明确确认后才改为 `published` 并把 `knowledge_cycle` 清空为 `null`；Roadmap-backed 学习无论 Note 是否需要修改，当前 item 都只有在自己明确确认达到本次学习目标后，才改为 `completed` 并记录 `completed_at`；standalone 初次学习只完成 Note 的发布门槛，不创建或补写 Roadmap 历史；
11. 学习发现新节点或关系时，同步更新 Map/Graph。

已有 Note 时按其状态和历史处理：

- `published`：保留当前发布元数据，先用它作为本次学习起点并重新检查内容、Evidence 和适用边界；如果无需实质修改，不重置 maturity，在自己确认达到本次 Roadmap 目标后即可完成本次 item；
- `published` 但本次学习发现需要实质修改：Knowledge Note 内容进入 `revise-knowledge-note`，当前 Roadmap item 保持 `in_progress`；只有修订后的 Note 重新发布，并且自己确认本次学习目标已经达到后，才完成该 item；
- `draft` 或 `reviewed`：根据必填的 `knowledge_cycle` 继续 `initial_learning` 或 `revision` 工作流，不重置或误路由另一个周期；
- `superseded`：默认沿 `superseded_by` 使用替代节点；如果 Roadmap 仍引用旧节点，对成员调整形成 Structure Proposal，不能静默改写；
- `archived`：不能自动恢复，必须先由自己明确决定重新启用该 Note。

同一个 Node 出现在多条 Roadmap 时，每个 item 都是独立的学习历史。已有 `published` Note 只提供当前知识起点，不能代替自己对本次 Roadmap 目标的理解确认；Note 没有实质变化时也不需要为了完成新的 item 人为重新发布。

普通概念问题、通过权威资料即可回答的问题，以及只用于理解概念的演示型 Lab，都留在 Knowledge Note 学习流程中。如果出现具体异常、多个需要排除的竞争假设、文档与实际观察冲突，或者结论提炼后仍有值得保留的诊断与证据链，则直接创建 Investigation，并将当前 Knowledge Note 记录为 `origin`。此时问题已经完成分诊，不再绕行 Inbox。

### 5.3 修订已有 Knowledge Note

触发条件：通常是已经 `published` 的 Knowledge Note，因新证据、版本变化或理解改进，需要实质改变其事实、解释、结论或适用边界。已经进入 Knowledge Revision 的 `draft` 或 `reviewed` Note 也继续使用本流程；尚未完成初次学习的 Note 仍由原学习流程负责。

由 `revise-knowledge-note` Skill 执行实质修订，以及 Note 的归档、恢复和替代：

1. 确认所属 Domain 是 `active`，并确认修改属于 Knowledge Revision，而不是格式、拼写、链接、日期等机械编辑；归档 Domain 必须先重新激活；
2. 不要求存在活跃 Roadmap，也不回退或修改任何 `completed` Roadmap item；
3. 对实质修订，将 Note 改为 `draft`、设置 `knowledge_cycle: revision`，并重置当前版本的 `ai_reviewed`、`author_confirmed`、`reviewed_at` 和 `published_at`；
4. 记录修订触发原因，重新研究受影响的重要结论，必要时创建 Lab；
5. 推理或证据链值得独立保存时，以当前 Note 为来源创建 Investigation；
6. 如果需要新增节点、改变节点边界或 Graph 关系，形成 Structure Proposal，获得 Structural Acceptance 后才具备提交资格；
7. 修订后的 Note 重新经过 Review 和 Publish 门槛；
8. 整个过程不改变此前 Roadmap `completed` 所保存的历史事实。

只有自己明确决定后，才能归档、恢复或替代 Note。归档或替代前，不能留下引用该节点的 `in_progress` Roadmap item：必须由自己明确完成或跳过，或者通过已接受的 Structure Proposal 把 Roadmap 成员改为替代节点。作为现有替代链当前终点的 Note 不能直接归档；应把它替代为另一个合格的 published Note 来延长替代链，或者保持为可维护终点。终点从 `published` 进入自己的 Revision 是合法的：它可以暂时成为 `draft` 或 `reviewed`，但必须保持 `knowledge_cycle: revision`，且不能在 revision 中被归档。归档时保存 `archived_from`、`archived_at` 和 `archive_reason`；恢复时按 `archived_from` 恢复为 `draft`、`reviewed` 或 `published`，清空三个 archive 字段，并保留未完成 Note 的原 `knowledge_cycle`；恢复的 `initial_learning` Note 可以在没有 Roadmap 时由 `study-knowledge-node` 继续，但不补造 Roadmap 历史；如果恢复已发布 Note 后需要实质修改，再正常进入 `revision`。只有此前 `published` 的 Note 才能进入 `superseded`，发生转换时目标必须是另一个当前 `published` 的 Note，并且替代链无环；`superseded` 是终态，后续默认沿 `superseded_by` 修订替代它的 Note。

## 6. 问题驱动工作流

触发条件：希望记录一个尚未分诊的具体问题、故障、异常或观察，或者 Active Knowledge Note 中出现了推理和证据链值得独立保存的问题。Active Knowledge Note 必须同时满足所属 Domain 为 `active`，且 maturity 为 `draft`、`reviewed` 或 `published`；这是派生的工作流条件，不是新的 frontmatter 状态。

由 `investigate-problem` Skill 执行：

1. 对不属于 Active Knowledge Note 工作流、尚未分诊的问题，在 `inbox/` 创建 Inbox Item，记录观察事实、上下文、初始猜测和问题；
2. 分诊是否已有重复内容、关联哪些 Domain/节点，以及推理和证据链是否值得独立保存；不值得创建 Investigation 时直接关闭 Inbox；
3. 从 Inbox 进入调查时，创建 `investigations/<slug>.md`，将 `origin.type` 设为 `inbox`、`origin.reference` 指向 Inbox 路径，并将 Inbox 状态改为 `promoted`；
4. 从 Active Knowledge Note 进入调查时，不创建 Inbox；将 `origin.type` 设为 `knowledge_note`、`origin.reference` 设为节点 ID，并立即在 Note 中建立 Investigation 回链；归档或替代后已有的 `origin` 引用仍然有效，但 `archived`/`superseded` Note 不能发起新 Investigation；
5. 在 Investigation 中持续记录假设、证据、被排除的解释、不确定性和开放问题；
6. 只有实验能提供有效证据时，才创建 `labs/<slug>/README.md`；
7. 调查结束时必须选择一种结果：
   - `update_existing_node`：可复用结论已经提炼进一个已有 Knowledge Note；`knowledge_cycle: initial_learning` 时继续初次学习，否则进入或继续 Knowledge Revision；
   - `create_new_node`：一个原子 Proposal Snapshot 同时包含新节点、其 `knowledge_cycle: initial_learning` 的 draft Knowledge Note、回链和 promotion outcome；新结构部分已获得 Structural Acceptance，且 candidate tree 不会让 Note 引用其中不存在的节点；
   - `no_promotion`：保留 Investigation，但不改变正式知识；
8. `update_existing_node` 和 `create_new_node` 必须设置唯一且属于 active Domain 的 `promotion_target`；`pending` 和 `no_promotion` 必须保持 `promotion_target: null`；归档 Domain 的节点可以作为只读上下文，但不能成为提升目标；执行提升动作时目标 Note 不能是 `archived` 或 `superseded`，但历史提升完成后目标 Note 的后续生命周期变化不使旧 Investigation 失效；
9. Investigation、Lab 和目标 Knowledge Note 之间建立双向链接；
10. 发现新节点或关系时更新 Map/Graph；
11. Investigation 改为 `closed`，但目标 Knowledge Note 仍然必须经过独立的 Review 和 Publish 门槛。

`origin` 表示调查从哪里来，`related_nodes` 只列出目标以外的上下文节点，`promotion_target` 表示结论实际落实到哪个主要节点。不要把 `promotion_target` 重复写入 `related_nodes`；当 `origin.type: knowledge_note` 时，如果调查结论正是更新来源 Note，`promotion_target` 可以等于 `origin.reference`。`domains` 是调查涉及 Domain 的完整清单，至少覆盖 Knowledge Note origin、`related_nodes`、`promotion_target` 和关联 Lab 的 `related_nodes` 所隐含的 Domain，并随这些引用更新；也可以保留只在调查正文中实质参与的额外 Domain。Knowledge Promotion 是已经执行的知识动作，不只是建议；尚未落实时保持 `active` 和 `outcome: pending`。

Investigation 进入 `closed` 或 `abandoned` 前，所有关联 Lab 必须已经是 `completed`、`invalid` 或 `abandoned`；如果实验仍需继续，Investigation 就仍是 `active`。`closed` 和 `abandoned` 都是终态，后续因新现象或证据重新开展的工作创建新的 Investigation，并把旧 Investigation 作为上下文链接，而不是改回 `active`。Inbox 的 `promoted` 和 `closed` 同样是终态；以后出现的新问题使用新的 Inbox Item 或直接进入已经分诊的工作流。

Investigation 保存“如何得到结论”，Knowledge Note 保存“可复用的当前结论”。不要把完整调查过程复制到 Knowledge Note。V1 每项 Investigation 只有一个主要 `promotion_target`；目标 Note 尚未完成初次学习时，提升结果回到其初次学习流程，而不是错误开启 Knowledge Revision；如果结论还需要实质修改其他已经完成初次学习的 Note，分别进入那些 Note 的 Knowledge Revision。

### 6.1 引用与回链矩阵

以下字段语义是确定性的；正文中的普通 Markdown 上下文链接不自动产生 frontmatter 回链义务：

| 来源字段 | 目标字段 | 约束 |
| --- | --- | --- |
| promoted Inbox 的 `investigation` | Investigation 的 `origin` | 必须一一对应；Investigation 的 `origin.type` 为 `inbox`，且 `reference` 精确指回该 Inbox 路径。 |
| Investigation 的 Knowledge Note `origin` | Note 的 `investigations` | origin 节点必须已有 Note；Note 必须包含该 Investigation 路径。 |
| Investigation 的 `promotion_target` | Note 的 `investigations` | promotion outcome 必须已有目标 Note，且 Note 必须包含该 Investigation 路径。origin 与 target 相同时只保存一次路径。 |
| Investigation 的 `related_nodes` | 无强制 Note 回链 | 它只表示上下文 Node；Node 必须存在于某个 Map，但可以尚无 Note，也不要求已有 Note 把 Investigation 加入 frontmatter。 |
| Investigation 的 `labs` | Lab 的 `investigation` | 必须一一回指同一个 Investigation。一个 Lab 最多由一个 Investigation 拥有；`investigation: null` 表示它是 Note 学习/修订中的独立 Lab。 |
| Note 的 `labs` | Lab 的 `related_nodes` | 必须双向对应：Note 列出的每个 Lab 都包含该 Note 的 node ID；Lab `related_nodes` 中已有 Note 的每个节点也必须在该 Note 的 `labs` 中列出该 Lab。没有 Note 的 Node 只需存在于 Map。 |
| Note 的 `investigations` | Investigation 的 origin/target | 该数组只记录以此 Note 为 `origin` 或实际提升到此 Note 的 Investigation；纯上下文关系使用 Investigation 的 `related_nodes`，不写 Note 回链。 |

Lab 的生命周期由其唯一 owner 决定：若 `investigation` 非 `null`，对应 Investigation 在 Lab 终结前不能终结；若为 `null`，则由列出该 Lab 的 Active Knowledge Note 学习或修订流程管理。一个 Lab 可以通过 `related_nodes` 支撑多个已有 Note，但不能同时属于多个 Investigation。

## 7. Knowledge Note 发布门槛

只有同时满足以下条件，Knowledge Note 才能进入 `published`：

- 问题和知识边界清楚；
- 自己能够用自己的话解释核心内容；
- 重要 Claim 具有相邻、可追溯且类型清楚的 Evidence；
- 事实、观察、推论和个人理解已被区分；
- 适用边界、风险和不确定性已记录；
- 相关 Investigation 和 Lab 已链接；
- 已检查是否存在重复节点；
- 必要的节点关系已经记录；
- AI 已完成 Review；
- 自己明确确认发布。
- `knowledge_cycle` 与本次初次学习或 Revision 一致，并在进入 `published` 时清空为 `null`。

`published` 表示截至当前的最佳理解，而不是永远正确。新证据出现后可以重新进入 `draft`，或者改为 `superseded`/`archived`。

## 8. 状态模型

### Roadmap Item

```text
planned → in_progress → completed
  │          │
  └──────────┴────→ skipped
```

- `planned`：尚未开始，是结构化 TODO；
- `in_progress`：正在学习，必须存在 Knowledge Note；
- `completed`：该 Roadmap item 在 Knowledge Note 已 `published` 且自己确认达到本次 Roadmap 学习目标时完成，并记录 `completed_at`；再次学习已有 published Note 时，如果内容无需实质修改，不要求人为重新发布；它是独立的终态历史记录，不要求 Note 此后一直保持 `published`；
- `skipped`：可以从 `planned` 或 `in_progress` 在作者明确决定后进入，表示当前 Roadmap 主动跳过；它也是该 Roadmap 内的终态历史记录，Knowledge Node 本身仍然存在。以后决定学习该节点时使用另一条 Roadmap，不恢复旧 item。

### Knowledge Note

```text
draft ⇄ reviewed → published
published → draft（Knowledge Revision）
published → superseded
draft | reviewed | published → archived
archived → archived_from 所记录的原状态
```

- `draft`：正在学习、验证或修改，`knowledge_cycle` 必须为 `initial_learning` 或 `revision`；
- `reviewed`：当前内容快照的 AI 审查已完成，等待自己确认，`knowledge_cycle` 保持不变；任何实质修改都会回到 `draft` 并使本次 Review 失效；
- `published`：自己确认的当前最佳理解，`knowledge_cycle: null`；
- `superseded`：此前发布的内容已被另一个 Note 替代；记录非自身的 `superseded_by` 和 `superseded_at`，替代链必须无环，当前终点必须是 `published`，或是一个此前已发布且当前正在 `revision` 的 `draft`/`reviewed` Note；这是终态；
- `archived`：自己明确停止维护或中止未完成工作；记录 `archived_from`、`archived_at` 和 `archive_reason`。可由自己明确决定恢复到 `archived_from`，但不能绕过对应初次学习、Revision 或 Publish 门槛。

### Inbox Item

```text
captured → promoted
        └→ closed
```

- `captured`：问题刚被记录，尚未完成分诊；
- `promoted`：确认需要深入研究，已经创建并关联 Investigation。它是 Inbox Item 的终态，后续进度由 Investigation 管理；
- `closed`：完成分诊后决定不创建 Investigation，例如问题无需深入、已有重复内容、价值不足或不属于本仓库范围。必须记录 `closed_at` 和 `close_reason`。`promoted` 和 `closed` 都是终态，后续新问题创建新的 Inbox Item。

### Investigation

```text
active → closed
      └→ abandoned
```

- `active`：调查正在进行，可以继续增加假设、证据和 Lab；outcome 固定为 `pending`，`promotion_target` 为 `null`；
- `closed`：调查已经形成当前结论，必须记录 `ended_at`，并将 outcome 设置为 `update_existing_node`、`create_new_node` 或 `no_promotion`；前两者必须有一个 `promotion_target`，后者必须为 `null`；
- `abandoned`：尚未形成足够结论，但决定停止调查。必须记录 `ended_at` 和 `abandon_reason`，outcome 固定为 `no_promotion`，`promotion_target` 为 `null`。

进入 `closed` 或 `abandoned` 前，所有关联 Lab 都必须已经终结。两个状态都是终态，后续工作创建新的 Investigation。

### Domain

```text
active ⇄ archived
```

- `active`：Domain 仍在学习和维护；`archived_at` 和 `archive_reason` 都必须为 `null`；
- `archived`：Domain 被保留但只读；`archived_at` 和 `archive_reason` 都必须有值。归档不会自动归档其中的 Knowledge Note，也不使已有引用失效；
- `active → archived`：必须由自己明确决定，而且全部 Roadmap 已终结、没有 `in_progress` item；
- `archived → active`：必须由自己明确决定，保留稳定 ID、清空归档字段并重新评估 purpose 和结构；只有恢复系统学习时创建新 Roadmap，维护型重新激活不要求 Roadmap；终态 Roadmap 不恢复。

### Roadmap

```text
active → completed
      └→ archived
```

- `active`：Roadmap 仍在执行；非归档 Roadmap 只要存在 `planned` 或 `in_progress` item 就必须保持 `active`。所有 item 都成为 `completed` 或 `skipped` 后也不自动结束，而是等待自己决定完成或归档；
- `completed`：不存在 `planned` 或 `in_progress` item、至少有一个 `completed` item，并且自己明确确认 Roadmap 目标已经达到。必须记录 `ended_at`，`archive_reason` 为 `null`；
- `archived`：自己主动停止执行该 Roadmap。归档前必须把每个 `in_progress` item 明确处理为 `completed` 或 `skipped`；归档时记录 `ended_at` 和 `archive_reason`，并保留处理后的 item 状态，不自动改变 Knowledge Node 或 Knowledge Note；
- `completed` 和 `archived` 都是终态。以后重新开始相同目标时创建新 Roadmap，不恢复旧 Roadmap。Knowledge Note 的后续修订不影响已完成 Roadmap。

### Lab

```text
planned → running → completed
  │          ├────→ invalid
  └──────────┴────→ abandoned
```

- `planned`：实验目的、假设和步骤已经定义，但尚未执行；
- `running`：正在执行或收集结果；
- `completed`：实验按计划完成，观察结果和限制已记录，并设置 `ended_at`；
- `invalid`：实验已执行但结果不能用于支持或反驳假设，例如环境、步骤或测量存在问题；设置 `ended_at` 和 `end_reason`，并在正文中解释原因；
- `abandoned`：实验在形成有效结果前被明确停止；设置 `ended_at` 和 `end_reason`，不能把它当成支持或反驳 Claim 的 Evidence。`completed`、`invalid` 和 `abandoned` 都是终态。

## 9. YAML 规范

机器可读格式由 [schemas](schemas/) 定义，可复制的起始内容位于 [templates](templates/)。V1 使用四种 Domain YAML：

1. `domain.yaml`：Domain 身份、范围和生命周期；
2. `map.yaml`：节点清单和分类；
3. `graph.yaml`：有类型的关系；
4. `roadmaps/*.yaml`：目标相关的学习顺序。

### 通用规则

- 使用两个空格缩进；
- 键名使用 `snake_case`；
- 使用 UTF-8；
- 日期使用带引号的 ISO 字符串 `"YYYY-MM-DD"`；
- 空值使用 `null`，不使用空字符串；
- 引用使用稳定 ID，不使用显示标题；
- 禁止 YAML anchor、alias 和自定义 tag；
- 每个文件包含整数 `schema_version`；它按工件类型独立演进，不是整个知识系统的 V1 标签；
- 已提交 Schema 的任何机器验证语义变化都必须递增对应工件的 `schema_version`，同步模板，并在启用新 Schema 前显式迁移该类型的全部现有实例；`title`、`description`、示例等不参与验证的说明性元数据可以保持版本不变。V1 采用这条可机械判断的严格规则，不要求验证器猜测一次约束变化是否向后兼容；
- Schema 未声明的字段默认不允许出现；
- 不得静默修改已经存在的稳定 ID。
- 新建或结构性修改的 Domain、Map、Graph 和 Roadmap 必须先获得 Structural Acceptance，才能提交为正式结构。

### 日期更新规则

带 `updated_at` 的工件在正文或除 `updated_at` 自身以外的 frontmatter/YAML 字段发生任何修改时，包括机械链接修复、Schema migration 和回链同步，都必须把 `updated_at` 设置为该次修改发生地时区的当前日历日期。同一天内的后续修改不需要重复变化。只读取、验证或改变文件外的 Git 状态不更新日期。`created_at` 保留首次创建日期；一个新工件可以跨日形成，因此不强制 `created_at == updated_at`。状态专用日期仍按各自转换规则记录。维护检查验证日期不倒退、基线后的内容变化同步改变日期，并在当前 view 的文件内容与 working-tree 文件完全相同时，使用该文件的修改日检查明显 stale 的 `updated_at`；Git tree 本身不保存修改时间，没有可用时间证据时只报告未验证范围而不猜测。

### 稳定 ID migration

稳定 ID rename 是例外性的仓库级 migration，不是普通编辑：

1. 必须由作者明确给出准确的 old → new 映射；Domain、Node 或 Roadmap rename 同时构成 Structure Proposal，并遵守 Proposal Snapshot 与 Structural Acceptance；
2. 在一个原子 snapshot 中更新工件路径、自身 ID、Domain/Node 前缀、所有 YAML/frontmatter 引用和 Markdown 链接；不得提交 old/new 混合状态；
3. 只为保持引用一致而修改 archived Domain 或 terminal Inbox/Investigation/Lab/Roadmap 是 migration repair，不恢复其生命周期；不得借 migration 改写结论、状态、日期含义或其他历史事实；
4. migration 后通过一个或多个 `--migration old=new` 参数把作者指定的完整映射交给验证器，使其能把新路径和 Formal Baseline 中的旧工件关联起来，并正确检查 `updated_at`、终态 Roadmap item 及其他历史约束；随后执行全仓库验证，确认旧 ID 不再作为有效引用出现、新路径与 ID 对应、Graph 和替代链仍合法；
5. V1 不建立 alias 或 redirect 工件；Git 历史保存迁移前标识。无法原子更新全部引用时，不执行 rename，而是保留原 ID。

### `domain.yaml`

记录 Domain 的 ID、名称、稳定 purpose（`description`）、包含范围、排除范围、状态、`archived_at`、`archive_reason` 和日期；具体学习 goal 只记录在 Roadmap。active Domain 的两个归档字段都为 `null`；archived Domain 的两个字段都必须有值。格式见 [domain.yaml 模板](templates/domain.yaml) 和 [Schema](schemas/domain.schema.json)。

### `map.yaml`

只记录节点 ID、标题、简要定义和父节点。Map 不记录 Roadmap 进度，也不记录 Knowledge Note 成熟度。必须满足：

- `map.yaml.domain`、所在目录名和 `domain.yaml.id` 一致；
- 每个 Node ID 的 `<domain>.` 前缀与所属 Domain 一致，并且在整个仓库只属于一个 Map；
- Node ID 在 Map 内唯一；
- `parent` 为 `null` 或引用同一 Map 中的节点；禁止自引用和 parent 循环；
- Map 可以包含多个 `parent: null` 的根节点，因此其层级是一片 forest，而不强制为单根树。

格式见 [map.yaml 模板](templates/map.yaml) 和 [Schema](schemas/map.schema.json)。

### `graph.yaml`

V1 只允许：

- `prerequisite`：有方向，`from` 应先于 `to` 理解；
- `related`：逻辑上双向，但只保存一次。

每条边都必须包含 `rationale`。禁止同时保存一条关系及其反向同义关系。每个 Knowledge Node 只由其所在 Domain 的 Map 和 Knowledge 目录管理。Domain Graph 的关系所有权规则是：

- 同一 Domain 内的关系保存在该 Domain 的 `graph.yaml`；
- 跨 Domain `prerequisite` 保存在 `to` 节点所属 Domain 的 `graph.yaml`，`from` 可以引用其他 Domain Map 中已经存在的节点；
- V1 不允许跨 Domain `related`，避免对称关系产生不明确的所有权。

所有端点都必须引用仓库中已有的 Knowledge Node。Graph 禁止自引用和重复边；把所有 Domain Graph 合并后，`prerequisite` 仍必须全局无环。`related` 是无方向关系，为得到唯一存储形式，必须把字典序较小的 Node ID 写入 `from`，较大的写入 `to`。

格式见 [graph.yaml 模板](templates/graph.yaml) 和 [Schema](schemas/graph.schema.json)。

### `roadmap.yaml`

Roadmap 记录 ID、Domain、学习目标、当前起点、阶段、节点和学习状态。Roadmap ID 的 `<domain>.` 前缀、`domain` 字段和所在 Domain 目录必须一致。phase ID 在同一 Roadmap 内唯一，同一 Node 在一条 Roadmap 中只能出现一次。Roadmap item 只能引用该 Roadmap 所属 Domain Map 中的 Knowledge Node；跨 Domain 前置知识只通过 Graph 表达。如果决定正式学习外部前置节点，应进入它所属 Domain 的 Roadmap。`phases` 数组和各 phase 的 `items` 数组顺序就是正式学习顺序；item 的 `completed_at` 记录该次学习完成日期，Roadmap 的 `ended_at` 记录整条路径结束日期，`archive_reason` 只用于说明主动停止原因。格式见 [roadmap.yaml 模板](templates/roadmap.yaml) 和 [Schema](schemas/roadmap.schema.json)。

### Markdown Frontmatter

Knowledge Note、Inbox、Investigation 和 Lab 的元数据分别受以下 Schema 约束：

- [Knowledge Note](schemas/knowledge-note-frontmatter.schema.json)
- [Inbox](schemas/inbox-frontmatter.schema.json)
- [Investigation](schemas/investigation-frontmatter.schema.json)
- [Lab](schemas/lab-frontmatter.schema.json)

Knowledge Note 的 `knowledge_cycle` 只标识当前未完成工作属于 `initial_learning` 还是 `revision`，不是版本号：`draft`/`reviewed` 必须设置，`published`/`superseded` 必须为 `null`，未完成 Note 被归档时保留原 cycle。Note 的 archive/supersede 日期、原因和来源状态由 frontmatter 记录；替代目标存在性、转换时发布状态、自引用、替代链循环和当前终点资格由跨文件维护检查负责。

当前 Domain、Map、Graph、Roadmap、Inbox 和 Investigation 使用 `schema_version: 1`；Knowledge Note 和 Lab 使用 `schema_version: 2`。本次升级发生时仓库尚无这些类型的实例，因此只需同步 Schema 和模板，不存在需要迁移的知识工件。以后旧版本实例必须先显式迁移，当前 Schema 不静默重新解释旧版本。

对应正文结构见 `templates/`。

Markdown 工件的稳定 ID 与路径必须相互对应：

- `<domain>.<slug>` 存放在 `domains/<domain>/knowledge/<slug>.md`，且 Note 的 `domain` 与所在 Domain 一致；
- `inbox.<date>.<slug>` 存放在 `inbox/<date>-<slug>.md`；
- `investigation.<slug>` 存放在 `investigations/<slug>.md`；
- `lab.<slug>` 存放在 `labs/<slug>/README.md`。

## 10. AI Skills

V1 定义五个项目级 Skill：

| Skill | 触发条件 | 职责 |
| --- | --- | --- |
| `domain-bootstrap` | 系统学习、结构调整或 Domain 生命周期转换 | Scope、Domain、Map、Graph、Roadmap |
| `study-knowledge-node` | 开始或继续 Roadmap 节点，或继续合法的 standalone initial-learning Note | 学习、依据、审查、发布；standalone 模式不制造 Roadmap 历史 |
| `revise-knowledge-note` | 实质修订或转换已有 Knowledge Note 生命周期 | 重新验证、审查、发布、归档、恢复或替代当前知识 |
| `investigate-problem` | 记录和调查具体问题 | Inbox、Investigation、可选 Lab、知识提升 |
| `knowledge-maintenance` | 检查、机械修复知识体系，或按明确请求准备 Governance Proposal / ID migration | Schema、ID、链接、状态、关系、治理快照和全量回归；未经对应 Acceptance 不提交提案 |

Navigator、Teacher、Researcher、Reviewer 和 Editor 是这些工作流内部的行为，不创建独立 Skill。Skill 的路由条件和全局不变量定义在 [AGENTS.md](AGENTS.md)。

## 11. 维护检查

`knowledge-maintenance` 至少检查：

其中字段和当前跨文件关系可以直接由仓库状态验证；Governance Acceptance、Structural Acceptance、“自己明确决定”和“重新评估”属于变更或状态转换发生时的工作流门槛，只在当前会话或可用变更历史能够提供依据时审查，不能因为仓库没有单独保存审批记录就推断为违规。

- Formal Baseline、Git index 与 working tree 被混为同一状态；Proposal Snapshot 未记录 base commit/candidate tree、接受后又发生变化、只提交 accepted snapshot 的一部分，或者可用上下文显示知识系统规范、Schema、模板、项目级 Skill 或配套验证资源的语义修改未经该 exact snapshot 的 Governance Acceptance 就被提交；
- 重复 ID；
- Domain 目录、`domain.yaml.id` 和各文件 `domain` 字段不一致；
- Node 或 Roadmap ID 前缀与所属 Domain 不一致，或者一个 Node 出现在多个 Map；
- Map parent 不存在、不在同一 Map、自引用或形成循环；
- 不存在的节点或文件引用；
- Schema 字段错误；
- active Domain 错误设置 `archived_at`/`archive_reason`，或 archived Domain 缺少这些字段；
- Domain 在仍有 active Roadmap、`in_progress` item、未归档的 draft/reviewed Note、来源为该 Domain Note 的 active Investigation，或与该 Domain 关联的 planned/running Lab 时被归档；其他 active Investigation 仍准备修改该 Domain 却未处理；或者可用上下文显示归档/重新激活没有经过自己明确决定；
- 变更历史显示 archived Domain 出现新增 Node、Map/Graph 变化、新 Roadmap、Knowledge Note 初次学习或实质修订，或者当前成为 Investigation `promotion_target`；
- Domain 重新激活时改变稳定 ID、未清空归档字段、可用上下文显示未重新评估 purpose/Scope/Map/Graph、恢复终态 Roadmap，或恢复系统学习却没有创建新 Roadmap；
- Graph 自引用或重复关系、非规范顺序的 `related`，或合并全部 Graph 后形成循环 `prerequisite`；
- Graph 关系不符合所有权规则，或存在跨 Domain `related`；
- Roadmap phase ID 重复、Node item 重复，或引用所属 Domain 之外的节点；
- completed Roadmap 仍有 `planned`/`in_progress` item、没有任何 completed item，或缺少 `ended_at`；
- archived Roadmap 缺少 `ended_at`/`archive_reason`、仍含 `in_progress` item，或者 `completed`/`skipped` item、completed/archived Roadmap 被恢复；
- active Roadmap 错误设置 `ended_at`/`archive_reason`；
- Knowledge Note、Inbox、Investigation 或 Lab 的 ID 与路径不对应；
- `in_progress` 但没有 Knowledge Note 的 Roadmap 节点；
- `in_progress` Roadmap item 指向 `archived` 或 `superseded` Note；
- `completed` 但没有 Knowledge Note 或 `completed_at` 的节点；
- 缺少 AI Review 或自己确认元数据的 Published Note；
- `draft`/`reviewed` Note 缺少有效 `knowledge_cycle`，`published`/`superseded` Note 的 cycle 非 `null`，或 archived Note 没有按 `archived_from` 保留/清空 cycle；
- Published Note 的重要 Claim 缺少相邻 Evidence、Evidence 类型或适用边界，或者错误引用 `invalid`/`abandoned` Lab；
- archived Note 缺少 `archived_from`、`archived_at` 或 `archive_reason`，恢复时没有清空 archive 字段，或者可用上下文显示归档/恢复未经自己明确决定；
- `reviewed` Note 在 Review 后发生实质修改却没有返回 `draft` 并重置当前审核元数据；
- `superseded` Note 并非从 published 转换、缺少 `superseded_at`、替代自身、目标 Note 不存在、替代链形成循环，或者当前终点既不是 published，也不是此前已发布且当前处于 `knowledge_cycle: revision` 的 draft/reviewed Note；
- 没有 Investigation 的 promoted Inbox；
- Investigation 缺少有效 `origin`，或 Inbox/Knowledge Note 来源没有对应回链；
- Investigation 的 `domains` 没有覆盖其 Knowledge Note origin、`related_nodes`、`promotion_target` 或关联 Lab 所隐含的 Domain；
- 缺少关闭时间或关闭原因的 closed Inbox；
- outcome 仍为 `pending` 的 closed Investigation；
- promotion outcome 缺少唯一有效的 `promotion_target`，或 `pending`/`no_promotion` 错误设置了 target；
- `promotion_target` 被重复写入 `related_nodes`、目标动作尚未落实、目标 Note 缺少 Investigation 回链，或可用转换历史显示 `update_existing_node` 在执行时指向不存在/archived/superseded Note、`create_new_node` 在执行时目标已经有 Note；来源为 Knowledge Note 且该 Note 正是被更新目标时，origin 与 target 相同是合法的；
- 缺少结束时间或放弃原因的 abandoned Investigation；
- closed/abandoned Investigation 仍关联 `planned`/`running` Lab，或者 promoted/closed Inbox、closed/abandoned Investigation 被恢复为非终态；
- completed Lab 缺少 `ended_at`，invalid/abandoned Lab 缺少 `ended_at`/`end_reason`，终态 Lab 被恢复，或者 invalid/abandoned Lab 被用于支持或反驳 Claim；
- 不符合第 6.1 节字段级引用矩阵的回链，包括把 contextual `related_nodes` 错误当成强制 Note 回链、一个 Lab 被多个 Investigation 拥有，或 Note/Lab 关系不对称；
- 失效的 Markdown 链接和不一致的更新时间。

请求 Governance/Structural Acceptance 或结束 maintenance 工作前，运行固定入口 `ruby .agents/skills/knowledge-maintenance/scripts/validate_repository.rb`；验证 stable-ID migration 时追加作者明确给出的全部 `--migration old=new` 映射。验证器必须启用 JSON Schema 日期格式检查，并额外检查 JSON Schema 无法表达的 YAML anchor/alias/custom tag、必需模板和 Domain 结构、重复 ID、ID/path、跨文件引用、状态、Graph、standalone Lab owner 以及 Markdown 文件目标和 heading anchor；验证器不可用、当前 view 没有可靠修改时间，或未覆盖某项人工门槛时，报告未验证范围，不能把“未检查”表述为“通过”。

## 12. V1 边界

V1 暂不引入项目执行日志、职业记录、Claim/Evidence 稳定 ID、独立 Evidence 工件、Evidence Schema、Neo4j、Embedding、自动知识站点等内容模型或检索基础设施。当前优先建立稳定 ID、有类型的关系、轻量证据契约和可重复工作流。以后即使增加其他内容类型、搜索或图库，也应先明确独立职责，并由权威 Markdown/YAML 内容单向生成派生索引，不改变提交到 Git 的 Markdown、YAML 和 JSON 在各自职责范围内共同记录系统当前状态的原则。
