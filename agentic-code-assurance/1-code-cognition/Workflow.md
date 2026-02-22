---
name: codearch-agents-workflow
description: Code architecture analysis workflow for complex C/C++ projects. Use when asked to understand what a project does, analyze modules and dependencies, document build and test systems, or produce structured reports for follow-up code review and test writing. Outputs an overall report and per-module reports (with usage examples and validation for high-complexity modules) with on-demand loading support.
compatibility: Designed for Agent/Claude. Requires access to C/C++ source tree; build tools (gcc, g++, cmake, make, etc.) helpful for module validation phases.
---

# 代码架构分析工作流 - Agent 入口

> **读取指令**：这是 Agent 执行代码架构分析的总入口。根据当前工程状态，选择对应路径执行。产出供后续深度代码审查与写测试按需引用。

---

## 快速决策树

按以下顺序回答问题，根据第一个「否」的回答选择对应阶段：

| 步骤 | 问题                                                               | 否                                                                                                                                       | 是                                                                     |
| ---- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Q1   | 是否存在满足约定结构的总体介绍报告（含信息来源汇总）？             | 执行 [Phase 01: 工程概览与主流程](1-code-cognition/phases/01-overview.md)                                                                | 继续 Q2                                                                |
| Q2   | 是否已为主要模块生成独立模块报告（含使用示例）且总体报告中已引用？ | 执行 [Phase 02: 模块与依赖分析](1-code-cognition/phases/02-modules.md)                                                                   | 继续 Q2b                                                               |
| Q2b  | 当前模块划分是否已稳定、合理（无需再拆分/合并或重划）？            | 执行「分解审视」；根据其结果回到 [Phase 01](1-code-cognition/phases/01-overview.md) 或 [Phase 02](1-code-cognition/phases/02-modules.md) | 继续 Q2c                                                               |
| Q2c  | 是否已对高复杂度模块完成验证？                                     | 检查 Q3 后执行验证（见下方说明）                                                                                                         | 继续 Q3                                                                |
| Q3   | 构建与测试是否已文档化且可执行？                                   | 执行 [Phase 03: 编译与测试体系](1-code-cognition/phases/03-build-and-tests.md)                                                           | 进入 [Phase 04: 报告产出与引用](1-code-cognition/phases/04-reports.md) |

**决策规则**：从 Q1 开始，遇到第一个「否」即进入对应阶段；全部为「是」则进入 Phase 04 做报告汇总与引用检查，或视为分析已完成。Phase 02 完成后须先做分解审视，通过或已收敛才进入 Q2c 验证判断。

**Q2c 验证流程说明**：

- 若 Q2c 为「否」（需要验证），先检查 Q3
- 若 Q3 也为「否」（构建未就绪），先执行 [Phase 03](1-code-cognition/phases/03-build-and-tests.md)，完成后返回执行验证
- 若 Q3 为「是」（构建已就绪），直接执行 [Skill 02 Task 2.5](1-code-cognition/skills/skill-02-modules.md) 进行模块验证
- 验证完成后继续 Q3

---

## 判断依据

### Q1: 如何判断「总体介绍报告已存在且满足约定结构」？

检查以下条件是否全部满足：

- [ ] `docs/codearch/overall_report.md` 存在
- [ ] 文档包含「工程目标」（或等价标题）且非空
- [ ] 文档包含「输入」「输出」「主流程」且各有实质内容
- [ ] 文档包含「信息来源汇总」且至少列出一个信息源

**全部满足** → 总体报告已就绪  
**任一不满足** → 需执行 Phase 01

### Q2: 如何判断「模块报告完整且已被总体报告引用」？

检查以下条件：

- [ ] `docs/codearch/modules/` 目录存在且包含主要模块的报告文件
- [ ] 主要模块（建议 ≥80%）均有对应 `docs/codearch/modules/<module_name>.md`
- [ ] 每份模块报告包含「信息来源」章节
- [ ] 每份模块报告包含「使用示例」章节（至少一个基本用法，标注来源）
- [ ] `docs/codearch/overall_report.md` 中有「模块列表」节，且每项含指向 `modules/<module_name>.md` 的链接，链接指向的文件存在

**全部满足** → 模块报告已就绪  
**任一不满足** → 需执行 Phase 02

### Q2b: 如何判断「模块划分已稳定」？

依据 [分解审视约定](1-code-cognition/definitions/decomposition_review.md) 中的审视结论：

- [ ] 已执行分解审视（Phase 02 完成后或 Skill 02 Task 5）
- [ ] 审视结论为「通过」，或「本轮变更列表」为空，或已达成收敛条件（如迭代轮数达到建议上限 2–3）

**全部满足** → 模块划分已稳定，可进入 Q2c  
**任一不满足** → 需执行分解审视；若不通过则按回退规则回到 Phase 01 或 Phase 02，执行变更后再次审视

### Q2c: 如何判断「高复杂度模块验证已完成」？

检查以下条件：

- [ ] 识别复杂度为「高」或「极高」的模块列表
- [ ] 这些模块的报告中包含「验证状态」章节
- [ ] 验证状态显示已执行 L2（运行测试）或 L3（探索性测试）验证
- [ ] 验证发现已反映在模块报告的相关章节中

**全部满足** → 验证已完成，可进入 Q3  
**任一不满足** → 需执行验证：

1. 先检查 Q3（构建与测试是否已文档化）
2. 若 Q3 为「否」，先执行 [Phase 03](1-code-cognition/phases/03-build-and-tests.md)
3. 构建就绪后，执行 [Skill 02 Task 2.5](1-code-cognition/skills/skill-02-modules.md) 进行模块验证
4. 验证完成后返回继续 Q3

**注意**：若无「高」或「极高」复杂度模块，则 Q2c 直接为「是」，跳过验证步骤。

验证等级详见 [验证等级定义](1-code-cognition/definitions/validation_levels.md)。

### Q3: 如何判断「构建与测试已文档化且可执行」？

检查以下条件：

- [ ] `docs/codearch/build_and_tests.md` 存在
- [ ] 文档包含编译系统说明及至少一条构建命令
- [ ] 文档包含单元测试说明及运行测试的方式（无测试则写明「当前无单元测试体系」）
- [ ] 文档中所列构建/测试命令在工程中可执行（或已说明不可用原因）

**全部满足** → 构建与测试已文档化  
**任一不满足** → 需执行 Phase 03

---

## 核心文档索引

### 定义文档（按需查阅）

| 文档                                                                   | 用途                                                           | 何时阅读                                           |
| ---------------------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------------- |
| [复杂度等级](1-code-cognition/definitions/complexity_levels.md)        | 模块复杂度评级（低/中/高/极高）及判定维度                      | 进行模块复杂度评级时                               |
| [验证等级](1-code-cognition/definitions/validation_levels.md)          | 模块验证等级（L0–L3）及触发条件、执行步骤                      | 对高复杂度模块进行验证时（Q2c、Skill 02 Task 2.5） |
| [产出路径与报告结构](1-code-cognition/definitions/output_structure.md) | 产出路径、总体/模块报告必须章节、引用格式、下游 Agent 使用约定 | Phase 04 或撰写/检查报告时；后续工作流按需引用时   |
| [分解审视约定](1-code-cognition/definitions/decomposition_review.md)   | 审视维度、结论、回退规则、收敛条件                             | Phase 02 完成后、Skill 02 Task 5 执行时            |

### 阶段文档（按序或按决策树进入）

| 阶段     | 文档                                                            | 说明                                                                                                                                                              |
| -------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Phase 01 | [工程概览与主流程](1-code-cognition/phases/01-overview.md)      | Q1 为「否」时执行                                                                                                                                                 |
| Phase 02 | [模块与依赖分析](1-code-cognition/phases/02-modules.md)         | Q2 为「否」时执行；完成后须执行「分解审视」，依据 [decomposition_review](1-code-cognition/definitions/decomposition_review.md)；若未通过则回 Phase 01 或 Phase 02 |
| Phase 03 | [编译与测试体系](1-code-cognition/phases/03-build-and-tests.md) | Q3 为「否」时执行                                                                                                                                                 |
| Phase 04 | [报告产出与引用](1-code-cognition/phases/04-reports.md)         | Q1–Q2b–Q3 全「是」或 01–03 完成后执行                                                                                                                             |

### 技能文档（按需加载）

> **注意**：不要预先阅读所有 Skill 文档，仅在阶段文档指示时加载对应 Skill。

| Skill                                                       | 名称                                       | 触发条件                                |
| ----------------------------------------------------------- | ------------------------------------------ | --------------------------------------- |
| [Skill 01](1-code-cognition/skills/skill-01-overview.md)    | 工程概览与主流程（含文档收集）             | Phase 01 指示                           |
| [Skill 02](1-code-cognition/skills/skill-02-modules.md)     | 模块与依赖分析（含复杂度、使用示例、验证） | Phase 02 指示，或 Q2c 验证触发          |
| [Skill 03](1-code-cognition/skills/skill-03-build-tests.md) | 构建与测试体系                             | Phase 03 指示，或验证前置需要时提前执行 |
| [Skill 04](1-code-cognition/skills/skill-04-reports.md)     | 报告产出与引用                             | Phase 04 指示                           |

### 模板文档

| 模板                                                         | 用途                                |
| ------------------------------------------------------------ | ----------------------------------- |
| [总体报告模板](1-code-cognition/templates/overall-report.md) | 生成或更新 overall_report.md        |
| [模块报告模板](1-code-cognition/templates/module-report.md)  | 生成或更新 modules/<module_name>.md |

---

## 执行原则

1. **最小上下文原则**：仅加载当前步骤需要的文档；总体报告仅列模块链接，不内嵌模块全文，便于按需加载单份模块报告。
2. **验收驱动**：每个 Phase 与 Skill 执行完必须验证验收标准。
3. **状态持久化**：产出统一放在 `docs/codearch/`，路径与结构见 [output_structure](1-code-cognition/definitions/output_structure.md)，便于中断后恢复。
4. **按决策树进入**：从 Q1 开始，首个「否」进入对应 Phase，避免跳过或重复执行。
5. **迭代与收敛**：Phase 02 完成后先做分解审视，通过才进入 Q2c 验证；不通过则按 [分解审视约定](1-code-cognition/definitions/decomposition_review.md) 回退规则重做并记录本轮变更，直至通过或达成收敛条件。
6. **文档优先**：优先利用项目已有文档（README、测试、示例）作为信息来源，文档内容优先于代码推断。
7. **深度验证**：对高复杂度模块（「高」或「极高」）通过运行测试进行验证，确保理解正确；验证需要构建环境时可提前执行 Phase 03。
8. **来源标注**：使用示例需标注来源（文件路径或「Agent 编写」），便于追溯和验证。

---

## 立即开始

请根据上方决策树判断当前工程状态，然后进入对应阶段文档开始执行。分析完成后，后续 Agent 可通过总体报告中的链接按需加载各模块报告。
