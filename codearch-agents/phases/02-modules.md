# Phase 02: 模块与依赖分析（含复杂度）

> **前置条件**：Phase 01 已完成（总体报告已有概览），或从 [Workflow.md](../Workflow.md) 决策树 Q2 为「否」进入  
> **目标**：识别模块、梳理依赖、为每个模块撰写独立报告并给出复杂度评级；完成后先执行「分解审视」，通过或已收敛再进入下一阶段

---

## 进入条件

- 从 [Workflow.md](../Workflow.md) 入口决策树判断 Q2 为「否」（模块报告未完整或总体报告中未引用）
- 或 Phase 01 已完成，需执行模块分析

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 02: 模块与依赖分析](../skills/skill-02-modules.md)  
**按需查阅**：进行复杂度评级时阅读 [复杂度等级定义](../definitions/complexity_levels.md)；进行模块边界与依赖分析时可按需阅读 [C/C++ 注意点](../definitions/cpp_cpp_notes.md)

---

## 阶段验收标准

在 Skill 02 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **模块报告目录存在且非空**
  ```bash
  [ -d docs/codearch/modules ] && [ "$(ls -A docs/codearch/modules 2>/dev/null)" ] && echo "PASS" || echo "FAIL"
  ```

- [ ] **主要模块覆盖率**：至少 80% 的已识别主要模块有对应报告
  - 列出的模块数 / 实际主要模块总数 ≥ 80%

- [ ] **每份模块报告包含**：
  - [ ] 职责描述
  - [ ] 边界（输入/输出）
  - [ ] 依赖（内部/外部）
  - [ ] 复杂度评级（低/中/高/极高）
  - [ ] 关键设计要点（建议 3–5 条）

- [ ] **总体报告中存在模块列表**，且每项含路径/范围、到 `modules/<module_name>.md` 的链接，链接指向的文件存在

- [ ] **分解审视已执行且结论为「通过」或已达成收敛**（见 [分解审视约定](../definitions/decomposition_review.md)）

### 质量检查

- [ ] 依赖方向合理（无未标注的循环依赖）
- [ ] 复杂度依据与 [complexity_levels](../definitions/complexity_levels.md) 一致

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 模块报告（每模块一份） | `docs/codearch/modules/<module_name>.md` | 职责、边界、依赖、复杂度、关键设计要点 |
| 总体报告中的模块列表 | `docs/codearch/overall_report.md` | 含路径/范围、到各模块报告的链接 |
| 分解审视结论与变更列表（若有不通过） | 可选：`docs/codearch/decomposition_changelog.md` | 见 [分解审视约定](../definitions/decomposition_review.md) |
| 模块地图（可选） | `docs/codearch/module_map.md` | 模块列表与依赖图汇总 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 审视通过或已收敛 | 回到 [Workflow.md](../Workflow.md) 决策树：若 Q3 为「否」则进入 [Phase 03: 编译与测试体系](03-build-and-tests.md)；若 Q3 为「是」则进入 [Phase 04: 报告产出与引用](04-reports.md) |
| 审视不通过且未收敛 | 按 [分解审视约定](../definitions/decomposition_review.md) 回退规则进入 [Phase 01](01-overview.md) 或本 Phase 02；下一轮 Phase 02 结束时再次执行审视 |
| 未通过（报告或链接缺失等） | 返回 Skill 02 补充分析后重新验收 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型（<10 模块） | 1–2 小时 |
| 中型（10–50 模块） | 2–4 小时 |
| 大型（>50 模块） | 4–8 小时 |

---

**执行**：立即加载 [Skill 02](../skills/skill-02-modules.md) 开始执行
