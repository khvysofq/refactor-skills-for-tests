# Phase 02: 深度审查

> **前置条件**：Phase 01 已产出分析范围；从 [Workflow.md](../Workflow.md) 决策树 Q2 为「否」进入。  
> **目标**：对选定模块/风险维度进行深度代码审查，记录疑似 BUG 并写入任务列表（或临时清单）。

---

## 进入条件

- 从 [Workflow.md](../Workflow.md) 决策树判断 Q2 为「否」（当前范围内深度审查未完成）
- 已存在分析范围（`docs/risk_tasks/scope.md` 或 task_list 头部范围说明）

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 02: 深度审查](../skills/skill-02-review.md)

**按需查阅**：

- 确定风险类型时阅读 [风险类型定义](../definitions/risk_types.md)
- 执行路径追踪审查时阅读 [审查模式定义](../definitions/review_patterns.md)
- 撰写任务条目时阅读 [任务列表产出结构约定](../definitions/task_output_structure.md)

---

## 阶段验收标准

在 Skill 02 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **分析范围内所有选定模块/维度已完成审查**
- [ ] **高复杂度模块（高/极高）使用了 L2/L3 路径追踪审查**，而非仅模式匹配
- [ ] **跨模块交互审查已覆盖关键的模块边界**（至少覆盖高复杂度模块之间的调用关系）
- [ ] **疑似 BUG 已记录**：每条至少包含位置、简要描述、风险类型、关联模块、推理依据、已排除的保护机制、需验证的前提假设
- [ ] **每条条目标注了对应的审查模式编号**（如 M-1、C-2）
- [ ] **每条条目符合** [task_output_structure](../definitions/task_output_structure.md) 必填字段要求

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
| 通过 | 回到 [Workflow.md](../Workflow.md) 决策树：若 Q3 为「否」则进入 [Phase 03: 汇总与产出](03-summary.md)；若 Q3 为「是」则阶段二完成 |
| 未通过 | 返回 Skill 02 补全审查与条目后重新验收 |

---

## 反馈

执行过程中若发现知识库与代码不一致，按 [反馈操作约定](../../definitions/feedback_protocol.md) 更新。

---

**执行**：立即加载 [Skill 02](../skills/skill-02-review.md) 开始执行
