# Skill 01: 验证存在性

> **触发条件**：Phase 01 指示（入口决策 Q1 为「否」）  
> **目标**：对任务列表中每条任务构建或选择测试场景、运行测试，记录验证结果（已确认/未复现/暂缓）。

---

## 输入

- `docs/risk_tasks/task_list.md`
- `docs/codearch/build_and_tests.md`
- 按需的 `docs/codearch/modules/<module_name>.md`（由任务「关联模块」确定）
- 仓库源码

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 验证结果记录 | `docs/remediation/remediation_log.md` | ✓ |

每条任务须有验证结果：已确认 / 未复现 / 暂缓；须将验证结果写入 `docs/remediation/remediation_log.md`（可随任务逐条追加），与 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 约定一致。

---

## 核心任务

### 任务 1: 按任务逐条或分批处理

1. 读取 `docs/risk_tasks/task_list.md`，按 [2-risk-assessment 下游使用约定](2-risk-assessment/definitions/task_output_structure.md) 理解每条任务：位置、简要描述、风险类型、关联模块、建议验证方式、复现思路。
2. **每条任务**（最小上下文：单次仅加载当前任务相关模块报告）：
   - 根据「位置」打开对应文件与行范围；
   - 根据「关联模块」按需加载 `docs/codearch/modules/<module_name>.md`；
   - 结合「建议验证方式」「复现思路」与 `docs/codearch/build_and_tests.md` 构建或选择测试场景（可新写测试或利用现有测试）；
   - 运行测试；
   - 记录结果：**已确认**（BUG 可复现）、**未复现**（当前无法复现）、**暂缓**（暂不处理）。
3. 将验证结果写入 `docs/remediation/remediation_log.md`，格式符合 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md)。

### 任务 2: 验收自检

- 确认任务列表中每条任务均有验证结果；
- 执行 Phase 01 中的验收检查（如 grep 验证结果关键词）。

---

## 验收

与 [Phase 01](3-bug-remediation/phases/01-verify.md) 阶段验收标准一致：每条任务有验证结果、记录存在且可检查。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 01](3-bug-remediation/phases/01-verify.md) 完成阶段验收，然后根据入口决策进入 Phase 02 或继续 Q2 |
| 未通过 | 补全验证与记录后重新验收 |

---

## 反馈

验证过程中若发现 **build_and_tests** 或**模块报告**与代码/构建不符，应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选在 `docs/codearch/knowledge_base_changelog.md` 记录；若发现**模块边界划分不合理**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时暂停并先回阶段一执行审视或重跑后再继续本 Skill。

---

**完成后**：返回 [Phase 01](3-bug-remediation/phases/01-verify.md) 进行阶段验收
