---
name: bug-remediation-workflow
description: Bug verification and remediation workflow for C/C++ projects. Consumes the risk task list (docs/risk_tasks/) and code cognition knowledge base to verify bugs, apply fixes, and produce remediation log (docs/remediation/).
compatibility: Designed for Agent/Claude. Requires stage two (2-risk-assessment) output, docs/codearch/build_and_tests.md, and C/C++ source tree.
---

# BUG 确认与修复工作流 - Agent 入口

> **读取指令**：本阶段为「BUG 确认与修复」，根据任务列表验证 BUG 存在性、实施修复并进行回归验证。执行前请先阅读根目录 [Workflow.md](../Workflow.md)，确认三阶段编排与反馈机制；并完成前置检查 Q0（任务列表是否就绪）。

---

## 前置检查 Q0：任务列表与编译环境是否就绪？

在进入本阶段决策树前，须确认**阶段二（风险评估）**已产出任务列表，且**编译/测试环境已就绪**：

- [ ] `docs/risk_tasks/task_list.md` 存在
- [ ] 任务列表含 [2-risk-assessment task_output_structure](../2-risk-assessment/definitions/task_output_structure.md) 规定的必填字段（位置、简要描述、风险类型、关联模块、推理依据、已排除的保护机制、需验证的前提假设）
- [ ] `docs/codearch/build_and_tests.md` 存在，且「环境验证状态」显示 build_success=true、tests_runnable=true

**全部满足** → 可继续下方决策树  
**任一不满足** → 先执行对应的前置阶段（[1-code-cognition](../1-code-cognition/Workflow.md) 或 [2-risk-assessment](../2-risk-assessment/Workflow.md)），入口见 [Workflow.md](../Workflow.md)，完成后再进入本工作流

---

## 快速决策树

按以下顺序回答问题，根据第一个「否」的回答选择对应阶段：

| 步骤 | 问题 | 否 | 是 |
|------|------|-----|-----|
| Q1 | 是否已对任务列表中每条任务完成「验证存在性」（构建/运行测试，记录已确认/未复现/暂缓）？ | 执行 [Phase 01: 验证存在性](phases/01-verify.md) | 继续 Q2 |
| Q2 | 是否已对「已确认」任务完成修复（代码变更已应用）？ | 执行 [Phase 02: 实施修复](phases/02-fix.md) | 继续 Q3 |
| Q3 | 是否已完成回归验证并产出 remediation 摘要（remediation_log.md）？ | 执行 [Phase 03: 回归与产出](phases/03-regression.md) | 阶段三完成 |

**决策规则**：从 Q1 开始，遇到第一个「否」即进入对应 Phase；全部为「是」则阶段三完成。

---

## 判断依据

### Q1: 如何判断「每条任务已完成验证存在性」？

检查以下条件是否全部满足：

- [ ] 存在 `docs/remediation/remediation_log.md`，且其中每条任务均有对应验证结果（已确认 / 未复现 / 暂缓）
- [ ] 每条任务均有对应的验证测试（测试路径已记录在 remediation_log 中）
- [ ] 所有验证测试已实际编译并运行
- [ ] 可执行检查：

```bash
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"
grep -q "已确认\|未复现\|暂缓" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
grep -q "验证测试路径\|test/verification" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

**全部满足** → 验证已就绪  
**任一不满足** → 需执行 Phase 01

### Q2: 如何判断「已确认任务已完成修复」？

检查以下条件：

- [ ] 所有标记为「已确认」的任务均已实施修复（源码已变更）；若本轮回溯无已确认任务，则视为满足
- [ ] 每条已修复任务的验证测试在修复后通过（PASS）
- [ ] 全量回归测试无新增失败

**全部满足** → 修复已就绪  
**任一不满足** → 需执行 Phase 02

### Q3: 如何判断「回归验证已完成且已产出 remediation 摘要」？

检查以下条件：

- [ ] `docs/remediation/remediation_log.md` 存在
- [ ] 文档含每条任务的验证结果与（若已修复）修复摘要；符合 [remediation_output_structure](definitions/remediation_output_structure.md)
- [ ] 已按 build_and_tests 运行全量回归测试，或已在 log 中说明未运行原因
- [ ] 执行 remediation_output_structure 中的验收检查命令通过

```bash
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"
grep -q "验证结果\|已确认\|未复现\|暂缓\|修复" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

**全部满足** → 阶段三完成  
**任一不满足** → 需执行 Phase 03

---

## 反馈机制

执行任意 Phase 时，若发现知识库与代码不一致，按 [反馈操作约定](../definitions/feedback_protocol.md) 更新。阶段三在验证与修复过程中尤易发现此类问题，需及时反馈。

---

## 核心文档索引

### 定义文档（按需查阅）

| 文档 | 用途 | 何时阅读 |
|------|------|----------|
| [修复阶段产出结构](definitions/remediation_output_structure.md) | 产出路径、remediation_log 结构、验收、与阶段二任务对应 | Phase 02/03 或撰写修复/记录时；与阶段二衔接时 |
| [阶段二任务列表约定](../2-risk-assessment/definitions/task_output_structure.md) | 任务列表字段与下游使用约定 | Phase 01 消费任务列表时 |

### 阶段文档（按决策树进入）

| 阶段 | 文档 | 说明 |
|------|------|------|
| Phase 01 | [验证存在性](phases/01-verify.md) | Q1 为「否」时执行 |
| Phase 02 | [实施修复](phases/02-fix.md) | Q2 为「否」时执行 |
| Phase 03 | [回归与产出](phases/03-regression.md) | Q3 为「否」时执行 |

### 技能文档（按需加载）

> **注意**：不要预先阅读所有 Skill 文档，仅在阶段文档指示时加载对应 Skill。

| Skill | 名称 | 触发条件 |
|-------|------|----------|
| [Skill 01](skills/skill-01-verify.md) | 验证存在性 | Phase 01 指示 |
| [Skill 02](skills/skill-02-fix.md) | 实施修复 | Phase 02 指示 |
| [Skill 03](skills/skill-03-regression.md) | 回归与产出 | Phase 03 指示 |

### 模板文档

| 模板 | 用途 |
|------|------|
| [remediation_log 模板](templates/remediation_log.md) | 生成或更新 docs/remediation/remediation_log.md |

---

## 输入与输出（契约）

| 输入 | 说明 |
|------|------|
| 任务列表 | `docs/risk_tasks/task_list.md`（来自阶段二），使用方式见 [task_output_structure 下游使用约定](../2-risk-assessment/definitions/task_output_structure.md) |
| 源代码 | 仓库根目录下的 C/C++ 源码 |
| 知识库 | `docs/codearch/build_and_tests.md` 必读；`overall_report.md`、`modules/<module_name>.md` 按需 |

| 产出 | 路径 | 说明 |
|------|------|------|
| 验证测试 | `test/verification/`（临时）→ 工程正式测试目录（归档后） | 每条任务的验证测试，已确认的集成到正式套件 |
| 源码修复 | 仓库源码（直接修改，当前分支） | 已确认 BUG 的修复代码，人类可通过 git diff 审查 |
| 修复摘要 | `docs/remediation/remediation_log.md` | 每条任务完整记录（验证结果、测试路径、修复摘要、测试归档状态等），结构见 [remediation_output_structure](definitions/remediation_output_structure.md) |

---

## 执行原则

通用原则见 [通用执行原则](../definitions/execution_principles.md)。本阶段无额外补充。

---

## 立即开始

请先确认 Q0（任务列表就绪），再根据上方决策树判断当前状态，进入对应 Phase 文档开始执行。阶段三完成后，整条「代码认知 → 风险评估 → BUG 修复」流水线即告一段落；后续可基于 remediation_log 与知识库迭代或开启新一轮分析。
