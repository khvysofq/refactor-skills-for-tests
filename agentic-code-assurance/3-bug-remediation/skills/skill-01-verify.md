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

每条任务须有验证结果：已确认 / 未复现 / 暂缓；须将验证结果写入 `docs/remediation/remediation_log.md`（可随任务逐条追加），与 [remediation_output_structure](../definitions/remediation_output_structure.md) 约定一致。

---

## 核心任务

### 任务 1: 按任务逐条编写验证测试并执行

1. 读取 `docs/risk_tasks/task_list.md`，按 [2-risk-assessment 下游使用约定](../../2-risk-assessment/definitions/task_output_structure.md) 理解每条任务的完整信息：位置、简要描述、风险类型、关联模块、**推理依据**、**已排除的保护机制**、**需验证的前提假设**、建议验证方式、复现思路。
2. 读取 `docs/codearch/build_and_tests.md`，了解工程的测试框架、测试目录结构、命名约定和运行方式。
3. **每条任务**（最小上下文：单次仅加载当前任务相关模块报告）：
   - 根据「位置」打开对应文件与行范围；
   - 根据「关联模块」按需加载 `docs/codearch/modules/<module_name>.md`；
   - 阅读「推理依据」理解阶段二的分析路径，阅读「已排除的保护机制」**避免重复检查已排除的内容**；
   - **编写验证测试**（必须）：
     - 基于「需验证的前提假设」「建议验证方式」「复现思路」设计一个最小测试用例
     - 测试目标：尝试触发疑似 BUG（如：传入超长输入触发缓冲区溢出、并发执行触发竞态条件）
     - 测试须遵循工程现有测试框架约定（如 Google Test 的 `TEST()` 宏）
     - 将测试文件放入 `test/verification/` 目录（或工程约定的测试目录），文件名含任务编号（如 `verify_M5_test.cpp`）
   - **运行验证测试**：
     - 编译并运行测试
     - 根据测试结果判定：
       - 测试触发了 BUG（崩溃、错误输出、内存错误等）→ **已确认**
       - 测试运行正常，BUG 未被触发 → **未复现**
       - 测试因结构性原因无法编写或运行（如需要特定硬件、网络环境等）→ **暂缓**（附说明）
   - **记录结果**：将验证结果、测试文件路径、测试名称写入 `docs/remediation/remediation_log.md`，格式符合 [remediation_output_structure](../definitions/remediation_output_structure.md)。

### 任务 2: 验收自检

- 确认任务列表中每条任务均有验证结果；
- 确认每条任务均有对应的验证测试文件（或「暂缓」原因说明）；
- 确认所有验证测试已实际运行（非仅编写）；
- 执行 Phase 01 中的验收检查（如 grep 验证结果关键词）。

---

## 验收

与 [Phase 01](../phases/01-verify.md) 阶段验收标准一致：每条任务有验证结果、记录存在且可检查。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 01](../phases/01-verify.md) 完成阶段验收，然后根据入口决策进入 Phase 02 或继续 Q2 |
| 未通过 | 补全验证与记录后重新验收 |

---

## 反馈

执行过程中若发现知识库与代码不一致，按 [反馈操作约定](../../definitions/feedback_protocol.md) 更新。

---

**完成后**：返回 [Phase 01](../phases/01-verify.md) 进行阶段验收
