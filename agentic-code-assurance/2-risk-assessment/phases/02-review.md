# Phase 02: 深度审查

> **前置条件**：Phase 01 已产出分析范围；从 [Workflow.md](2-risk-assessment/Workflow.md) 决策树 Q2 为「否」进入。  
> **目标**：对选定模块/风险维度进行深度代码审查，记录疑似 BUG 并写入任务列表（或临时清单）。

---

## 进入条件

- 从 [Workflow.md](2-risk-assessment/Workflow.md) 决策树判断 Q2 为「否」（当前范围内深度审查未完成）
- 已存在分析范围（`docs/risk_tasks/scope.md` 或 task_list 头部范围说明）

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 02: 深度审查](2-risk-assessment/skills/skill-02-review.md)

**按需查阅**：

- 确定风险类型时阅读 [风险类型定义](2-risk-assessment/definitions/risk_types.md)
- 撰写任务条目时阅读 [任务列表产出结构约定](2-risk-assessment/definitions/task_output_structure.md)

---

## 阶段验收标准

在 Skill 02 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **分析范围内所有选定模块/维度已完成审查**
- [ ] **疑似 BUG 已记录**：每条至少包含位置、简要描述、风险类型、关联模块（可先落临时文件，由 Phase 03 汇总）
- [ ] **每条条目符合** [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) 必填字段要求

```bash
# 若已直接写入 task_list.md：检查必填字段存在
grep -q "位置\|描述\|风险类型\|关联模块" docs/risk_tasks/task_list.md 2>/dev/null && echo "PASS" || echo "CHECK"
```

### 可选

- [ ] 审查过程中对工程理解文档的反馈已写入 `docs/codearch/` 或 knowledge_base_changelog

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 任务列表（或临时清单） | `docs/risk_tasks/task_list.md` 或临时文件 | 疑似 BUG 条目，Phase 03 可合并/去重后定稿 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 回到 [Workflow.md](2-risk-assessment/Workflow.md) 决策树：若 Q3 为「否」则进入 [Phase 03: 汇总与产出](03-summary.md)；若 Q3 为「是」则阶段二完成 |
| 未通过 | 返回 Skill 02 补全审查与条目后重新验收 |

---

## 反馈

审查过程中若发现某模块报告（职责、边界、代码特征、依赖）与代码不符，应**立即**按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/modules/<module_name>.md` 对应章节，并可选在 `docs/codearch/knowledge_base_changelog.md` 记一条。若发现**模块边界划分不合理**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时暂停本阶段并先回阶段一执行审视或重跑 Phase 01/02，再继续风险评估。

---

**执行**：立即加载 [Skill 02](2-risk-assessment/skills/skill-02-review.md) 开始执行
