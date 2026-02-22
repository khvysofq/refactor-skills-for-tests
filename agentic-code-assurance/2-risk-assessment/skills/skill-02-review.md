# Skill 02: 深度审查

> **触发条件**：Phase 02 指示（入口决策 Q2 为「否」）  
> **目标**：对分析范围内的模块按风险维度进行深度代码审查，识别疑似 BUG 并写入任务列表（或临时清单），每条须含必填字段。

---

## 输入

- 分析范围：`docs/risk_tasks/scope.md` 或 task_list 头部（选定模块、风险维度）
- `docs/codearch/overall_report.md`
- **按需加载**的 `docs/codearch/modules/<module_name>.md`（仅加载当前批审查涉及的模块，不要一次性加载全部）
- 仓库源码

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 疑似 BUG 条目 | `docs/risk_tasks/task_list.md` 或临时文件 | ✓（可由 Phase 03 合并/去重后定稿） |

每条须符合 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md)：位置、简要描述、风险类型、关联模块；可选置信度、建议验证方式、复现思路。

---

## 核心任务

### 任务 1: 按批加载与审查

1. **按模块或按风险维度分批**，每批仅加载当前批对应的 `docs/codearch/modules/<module_name>.md`（职责、边界、代码特征、关键代码位置索引）。
2. 结合源码，根据模块报告中的「代码特征」与「关键代码位置索引」定位可能的风险代码区域。
3. 按 [risk_types](2-risk-assessment/definitions/risk_types.md) 对每处疑似问题做判断，并标注风险类型。
4. 每条疑似 BUG 按 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) 记录：**位置**（文件:行或范围）、**简要描述**、**风险类型**、**关联模块**；可选置信度、建议验证方式、复现思路。
5. 将条目写入 `docs/risk_tasks/task_list.md`（可追加）或临时文件，供 Phase 03 汇总。

**最小上下文原则**：不要一次性加载全部模块报告；每批只读当前审查模块的报告与对应源码。

### 任务 2: 验收自检

- 确认分析范围内所有选定模块/维度已完成审查。
- 确认每条条目含必填字段；执行 Phase 02 中的验收检查（若已写 task_list）。

---

## 验收

与 [Phase 02](2-risk-assessment/phases/02-review.md) 阶段验收标准一致：范围覆盖完整、条目含位置/描述/风险类型/关联模块、符合 task_output_structure。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 02](2-risk-assessment/phases/02-review.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或继续 Q3 |
| 未通过 | 补全审查与条目后重新验收 |

---

## 反馈

审查过程中若发现某模块报告（职责、边界、代码特征、依赖、关键代码位置）与代码不符，应**立即**更新 `docs/codearch/modules/<module_name>.md` 对应章节，并按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 操作；可选在 `docs/codearch/knowledge_base_changelog.md` 记录一条摘要。若发现**模块边界划分不合理**，须按根目录 Workflow 与 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md) 处理，必要时暂停并先回阶段一执行审视或重跑 Phase 01/02，再继续本 Skill。

---

**完成后**：返回 [Phase 02](2-risk-assessment/phases/02-review.md) 进行阶段验收
