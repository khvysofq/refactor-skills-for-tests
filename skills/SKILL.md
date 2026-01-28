---
name: testability-refactoring-workflow
description: Systematically refactor complex C/C++ projects to improve testability. Use when asked to refactor legacy code, establish test baselines, analyze project structure, improve code testability, add unit tests to existing codebase, or when working with complex C/C++ projects that lack proper test coverage. This workflow guides through baseline setup, project analysis, prioritization, and iterative refactoring phases.
compatibility: Designed for Claude Code. Requires C/C++ development environment with build tools (gcc, g++, cmake, make), testing frameworks (Google Test), and static analysis tools (clang-tidy, cppcheck).
---

# 可测试性重构工作流 - Agent 入口

> **读取指令**：这是 Agent 执行可测试性重构的总入口。根据当前工程状态，选择对应路径执行。

---

## 快速决策树

按以下顺序回答问题，根据第一个"否"的回答选择对应阶段：

| 步骤 | 问题 | 否 | 是 |
|------|------|-----|-----|
| Q1 | 工程是否已建立门禁基线？ | 执行 [Phase 01: 基线准备](phases/01-setup.md) | 继续 Q2 |
| Q2 | 是否已完成工程分析？ | 执行 [Phase 02: 工程分析](phases/02-analysis.md) | 继续 Q3 |
| Q3 | 是否已建立模块优先级队列？ | 执行 [Phase 03: 优先级排序](phases/03-prioritization.md) | 进入 [Phase 04: 迭代循环](phases/04-iteration.md) |

**决策规则**：从 Q1 开始，遇到第一个"否"即进入对应阶段；全部为"是"则进入 Phase 04。

---

## 判断依据

### Q1: 如何判断"门禁基线已建立"？

检查以下条件是否全部满足：

- [ ] 存在可执行的构建命令，且能稳定编译核心 target
- [ ] 存在 `tests/` 目录结构
- [ ] 存在一键测试脚本（如 `./tools/test.sh`）
- [ ] 测试运行器能执行并返回 0

**全部满足** → 基线已建立  
**任一不满足** → 需执行 Phase 01

### Q2: 如何判断"工程分析已完成"？

检查以下文档是否存在且内容完整：

- [ ] `docs/architecture/module_map.md` 存在且覆盖主要模块
- [ ] 每个模块有职责、边界、依赖类型描述
- [ ] 编译体系已文档化

**全部满足** → 分析已完成  
**任一不满足** → 需执行 Phase 02

### Q3: 如何判断"优先级队列已建立"？

检查以下条件：

- [ ] `docs/testing/backlog.md` 存在
- [ ] 包含至少 10 个可执行切片
- [ ] 每个条目有 S1-S4 评估和 L1-L3 策略

**全部满足** → 队列已建立  
**任一不满足** → 需执行 Phase 03

---

## 核心文档索引

### 定义文档（按需查阅）

| 文档 | 用途 | 何时阅读 |
|------|------|----------|
| [全局约束](definitions/constraints.md) | 不可违背的硬性规则 | 执行任何改动前 |
| [状态定义](definitions/states.md) | S1-S4/G0-G3 状态说明 | 进行评估或处理门禁时 |
| [测试分层](definitions/test_levels.md) | L1/L2/L3 定义 | 选择测试策略时 |

### 阶段文档（按序执行）

| 阶段 | 文档 | 前置条件 |
|------|------|----------|
| Phase 01 | [基线准备](phases/01-setup.md) | 无 |
| Phase 02 | [工程分析](phases/02-analysis.md) | Phase 01 完成 |
| Phase 03 | [优先级排序](phases/03-prioritization.md) | Phase 02 完成 |
| Phase 04 | [迭代循环](phases/04-iteration.md) | Phase 03 完成 |

### 技能文档（按需加载）

> **注意**：不要预先阅读所有 Skill 文档，仅在阶段文档指示时加载对应 Skill。

| Skill | 名称 | 触发条件 |
|-------|------|----------|
| [Skill 01](skills/skill-01-baseline.md) | 工程基线与门禁准备 | Phase 01 指示 |
| [Skill 02](skills/skill-02-analysis.md) | 工程深度分析 | Phase 02 指示 |
| [Skill 03](skills/skill-03-prioritization.md) | 模块分级与优先级 | Phase 03 指示 |
| [Skill 04](skills/skill-04-assessment.md) | 模块可测试性评估 | Phase 04 循环入口 |
| [Skill 05](skills/skill-05-characterization.md) | 表征测试 | 评估结果为 S2 |
| [Skill 06](skills/skill-06-unit-tests.md) | 直接单测覆盖 | 评估结果为 S1 |
| [Skill 07](skills/skill-07-seams.md) | 设计 Seam 与解耦 | 评估结果为 S3 或 S2 后续 |
| [Skill 08](skills/skill-08-refactor.md) | 小步重构 | Skill 06/07 完成后 |
| [Skill 09](skills/skill-09-behavior-drift.md) | 行为差异判定 | 门禁 G2 |
| [Skill 10](skills/skill-10-human-input.md) | 人工介入问询 | 评估结果为 S4 或无法判定 |
| [Skill 11](skills/skill-11-documentation.md) | 文档更新 | 模块处理完成 |
| [Skill 12](skills/skill-12-stability.md) | 稳定性治理 | 门禁 G3 |
| [Skill 13](skills/skill-13-bugfix.md) | 缺陷修复 | 确认为 Bug |

### 模板文档

| 模板 | 用途 |
|------|------|
| [模块卡片模板](templates/module-card.md) | 创建/更新模块评估文档 |
| [Backlog 条目模板](templates/backlog-entry.md) | 创建待办条目 |
| [人工问询模板](templates/question-set.md) | 结构化提问 |

### 决策文档

| 决策树 | 用途 |
|--------|------|
| [可测试性决策](decisions/testability-decision.md) | Skill 04 评估后路径选择 |
| [门禁失败决策](decisions/gate-failure-decision.md) | 门禁失败后路径选择 |

---

## 执行原则

1. **最小上下文原则**：仅加载当前步骤需要的文档
2. **验收驱动**：每个 Skill 执行完必须验证验收标准
3. **状态持久化**：完成阶段/Skill 后更新相关状态文档
4. **失败快速回滚**：门禁失败时立即进入对应处理流程

---

## 立即开始

请根据上方决策树判断当前工程状态，然后进入对应阶段文档开始执行。
