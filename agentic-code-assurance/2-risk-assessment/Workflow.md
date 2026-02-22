---
name: risk-assessment-workflow
description: Risk assessment workflow for C/C++ projects. Consumes the code cognition knowledge base (docs/codearch/) and source code to identify potential bugs and produce a structured task list (docs/risk_tasks/) for the bug remediation stage.
compatibility: Designed for Agent/Claude. Requires stage one (1-code-cognition) output and C/C++ source tree.
---

# 风险评估工作流 - Agent 入口

> **读取指令**：本阶段为「风险评估」，在工程知识库与源码基础上识别潜在 BUG，输出疑似 BUG 任务列表。执行前请先阅读根目录 [Workflow.md](../Workflow.md)，确认三阶段编排与反馈机制；并完成前置检查 Q0（知识库是否就绪）。

---

## 前置检查 Q0：知识库是否就绪？

在进入本阶段决策树前，须确认**阶段一（代码认知）**已完成：

- [ ] `docs/codearch/overall_report.md` 存在
- [ ] 满足 [1-code-cognition/Workflow.md](1-code-cognition/Workflow.md) 中 Q1～Q3 的「是」条件（总体报告、模块报告、构建与测试已就绪）

**全部满足** → 可继续下方决策树  
**任一不满足** → 先执行阶段一，入口见 [Workflow.md](../Workflow.md)，完成后再进入本工作流

---

## 快速决策树

按以下顺序回答问题，根据第一个「否」的回答选择对应阶段：

| 步骤 | 问题 | 否 | 是 |
|------|------|-----|-----|
| Q1 | 分析范围与策略是否已确定（选定模块、风险维度/优先级）？ | 执行 [Phase 01: 范围与策略](2-risk-assessment/phases/01-scope.md) | 继续 Q2 |
| Q2 | 当前范围内深度审查是否已完成？ | 执行 [Phase 02: 深度审查](2-risk-assessment/phases/02-review.md) | 继续 Q3 |
| Q3 | 任务列表是否已生成且满足约定结构？ | 执行 [Phase 03: 汇总与产出](2-risk-assessment/phases/03-summary.md) | 阶段二完成，可进入 [3-bug-remediation](3-bug-remediation/Workflow.md) |

**决策规则**：从 Q1 开始，遇到第一个「否」即进入对应 Phase；全部为「是」则阶段二完成。

---

## 判断依据

### Q1: 如何判断「分析范围与策略已确定」？

检查以下条件是否全部满足：

- [ ] `docs/risk_tasks/scope.md` 存在，或 `docs/risk_tasks/task_list.md` 头部有「分析范围」/「选定模块」/「风险维度」等说明
- [ ] 至少包含：本轮回析的模块列表（与 overall_report 模块列表一致）、风险维度或优先级（与 [risk_types](2-risk-assessment/definitions/risk_types.md) 对齐）

**全部满足** → 分析范围已就绪  
**任一不满足** → 需执行 Phase 01

### Q2: 如何判断「当前范围内深度审查已完成」？

检查以下条件：

- [ ] 根据 scope 或 task_list 头部的选定模块，已对每个模块（或约定子集）完成审查
- [ ] 疑似 BUG 已记录：存在 `docs/risk_tasks/task_list.md` 或临时清单，且每条至少含位置、简要描述、风险类型、关联模块

**全部满足** → 深度审查已就绪  
**任一不满足** → 需执行 Phase 02

### Q3: 如何判断「任务列表已生成且满足约定结构」？

检查以下条件：

- [ ] `docs/risk_tasks/task_list.md` 存在
- [ ] 文档包含任务条目，且每条含 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) 规定的必填字段（位置、简要描述、风险类型、关联模块）
- [ ] 执行 task_output_structure 中的验收检查命令通过

```bash
[ -f docs/risk_tasks/task_list.md ] && echo "PASS" || echo "FAIL"
grep -q "位置\|描述\|风险类型\|关联模块" docs/risk_tasks/task_list.md && echo "PASS" || echo "FAIL"
```

**全部满足** → 任务列表已就绪，阶段二完成  
**任一不满足** → 需执行 Phase 03

---

## 反馈机制

执行任意 Phase 时，若发现**工程理解文档与代码不一致或遗漏**，应触发反馈，以保持知识库与代码一致：

1. **按 [根目录 Workflow 四、反馈机制](../Workflow.md) 操作**：
   - 模块职责/边界描述不准确 → 直接更新 `docs/codearch/modules/<module_name>.md` 对应章节
   - 遗漏外部依赖或代码特征 → 补充该模块报告的「依赖」「代码特征」等章节
   - 模块边界划分不合理 → 在 1-code-cognition 中触发「分解审视」，并视结果重跑 Phase 01 或 Phase 02
2. **可选**：在 `docs/codearch/knowledge_base_changelog.md` 记录反馈类型与修改摘要，便于审计
3. **模块边界不合理**时，详见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)

各 Phase 与 Skill 文档中均包含反馈说明，执行时按需执行更新并可选记录。

---

## 核心文档索引

### 定义文档（按需查阅）

| 文档 | 用途 | 何时阅读 |
|------|------|----------|
| [任务列表产出结构](2-risk-assessment/definitions/task_output_structure.md) | 产出路径、任务条目必填/可选字段、验收、下游使用约定 | Phase 03 或撰写/检查任务列表时；阶段三按需引用 |
| [风险类型定义](2-risk-assessment/definitions/risk_types.md) | 风险类型枚举及与阶段一代码特征的对应 | Phase 01 定策略、Phase 02 做审查、撰写任务条目时 |

### 阶段文档（按决策树进入）

| 阶段 | 文档 | 说明 |
|------|------|------|
| Phase 01 | [范围与策略](2-risk-assessment/phases/01-scope.md) | Q1 为「否」时执行 |
| Phase 02 | [深度审查](2-risk-assessment/phases/02-review.md) | Q2 为「否」时执行 |
| Phase 03 | [汇总与产出](2-risk-assessment/phases/03-summary.md) | Q3 为「否」时执行 |

### 技能文档（按需加载）

> **注意**：不要预先阅读所有 Skill 文档，仅在阶段文档指示时加载对应 Skill。

| Skill | 名称 | 触发条件 |
|-------|------|----------|
| [Skill 01](2-risk-assessment/skills/skill-01-scope.md) | 范围与策略 | Phase 01 指示 |
| [Skill 02](2-risk-assessment/skills/skill-02-review.md) | 深度审查 | Phase 02 指示 |
| [Skill 03](2-risk-assessment/skills/skill-03-summary.md) | 汇总与产出 | Phase 03 指示 |

### 模板文档

| 模板 | 用途 |
|------|------|
| [任务列表模板](2-risk-assessment/templates/task_list.md) | 生成或更新 docs/risk_tasks/task_list.md |

---

## 输入与输出（契约）

| 输入 | 说明 |
|------|------|
| 工程知识库 | `docs/codearch/`：overall_report.md、modules/<module_name>.md、build_and_tests.md |
| 源代码 | 仓库根目录下的 C/C++ 源码与构建配置 |

| 产出 | 路径 | 说明 |
|------|------|------|
| 分析范围 | `docs/risk_tasks/scope.md` | Phase 01 产出；可选写入 task_list 头部 |
| 疑似 BUG 任务列表 | `docs/risk_tasks/task_list.md` | 主产出，结构见 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) |

---

## 执行原则

1. **最小上下文原则**：仅加载当前步骤需要的文档；Phase 02 按模块或风险维度分批，每批只加载对应模块报告，不一次性加载全部。
2. **验收驱动**：每个 Phase 与 Skill 执行完必须验证验收标准。
3. **产出路径固定**：产出统一在 `docs/risk_tasks/`，路径与结构见 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md)。
4. **按决策树进入**：从 Q1 开始，首个「否」进入对应 Phase。
5. **反馈及时**：审查中一旦发现工程理解文档与代码不符，按根目录 Workflow 反馈机制更新并可选记录。

---

## 立即开始

请先确认 Q0（知识库就绪），再根据上方决策树判断当前状态，进入对应 Phase 文档开始执行。阶段二完成后，可进入 [3-bug-remediation](3-bug-remediation/Workflow.md) 进行 BUG 确认与修复。
