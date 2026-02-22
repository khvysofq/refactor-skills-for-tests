# Skill 01: 范围与策略

> **触发条件**：Phase 01 指示（入口决策 Q1 为「否」）  
> **目标**：基于 overall_report 确定本轮回析的模块范围与风险维度/优先级，产出分析范围文档。

---

## 输入

- `docs/codearch/overall_report.md`（工程概览、模块列表、技术特征概览）
- 仓库源码根（可选：用于快速核对模块存在性）
- **不加载**具体模块报告（modules/*.md），保持最小上下文

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 分析范围 | `docs/risk_tasks/scope.md` | ✓（或约定写入 task_list.md 头部） |

须包含：选定模块列表、风险维度/优先级；可选：分析日期或仓库版本。

---

## 核心任务

### 任务 1: 建立全局认知

1. 阅读 `docs/codearch/overall_report.md` 的工程概览、主流程、模块列表、技术特征概览。
2. 理解工程整体与各模块的复杂度、技术特征统计（如哪些模块涉及多线程、外部输入等）。

### 任务 2: 选择分析范围

1. 根据模块列表中的**复杂度**与**技术特征**，选择本轮回析的模块（可全量或子集，建议优先高复杂度或高风险特征模块）。
2. 根据 [风险类型定义](2-risk-assessment/definitions/risk_types.md) 确定本轮回析的**风险维度**（如：内存管理、I/O 与外部输入）及优先级。
3. 将选定模块列表与风险维度/优先级写入 `docs/risk_tasks/scope.md`（或按约定写在 task_list.md 头部）。

### 任务 3: 验收自检

- 确认 scope 或 task_list 头部包含：选定模块、风险维度/优先级。
- 执行 Phase 01 中的验收检查命令。

---

## 验收

与 [Phase 01](2-risk-assessment/phases/01-scope.md) 阶段验收标准一致：分析范围产出存在、含选定模块与风险维度、可执行检查通过。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 01](2-risk-assessment/phases/01-scope.md) 完成阶段验收，然后根据入口决策进入 Phase 02 或继续 Q2 |
| 未通过 | 补全分析范围内容后重新验收 |

---

## 反馈

若发现 `docs/codearch/overall_report.md` 与代码严重不符（如模块列表缺失或错误、技术特征概览明显偏差），应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新知识库或记录反馈；若需调整**模块边界**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时先回阶段一执行审视或重跑后再继续本阶段。

---

**完成后**：返回 [Phase 01](2-risk-assessment/phases/01-scope.md) 进行阶段验收
