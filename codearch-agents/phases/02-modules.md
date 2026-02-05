# Phase 02: 模块与依赖分析（含复杂度与验证）

> **前置条件**：Phase 01 已完成（总体报告已有概览和信息来源汇总），或从 [Workflow.md](../Workflow.md) 决策树 Q2 为「否」进入  
> **目标**：识别模块、梳理依赖、为每个模块撰写独立报告（含使用示例）、给出复杂度评级、对高复杂度模块进行验证；完成后先执行「分解审视」，通过或已收敛再进入下一阶段

---

## 进入条件

- 从 [Workflow.md](../Workflow.md) 入口决策树判断 Q2 为「否」（模块报告未完整或总体报告中未引用）
- 或 Phase 01 已完成，需执行模块分析

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 02: 模块与依赖分析](../skills/skill-02-modules.md)  
**按需查阅**：
- 进行复杂度评级时阅读 [复杂度等级定义](../definitions/complexity_levels.md)
- 进行模块验证时阅读 [验证等级定义](../definitions/validation_levels.md)
- 进行模块边界与依赖分析时可按需阅读 [C/C++ 注意点](../definitions/cpp_cpp_notes.md)

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
  - [ ] 代码特征（内存管理、并发模型、I/O 操作、外部数据处理、错误处理）
  - [ ] 关键代码位置索引（主要入口点）
  - [ ] 信息来源（记录分析依据）
  - [ ] 使用示例（至少一个基本用法，标注来源）

- [ ] **高复杂度模块验证**：复杂度为「高」或「极高」的模块报告包含「验证状态」章节
  ```bash
  # 检查高复杂度模块是否包含验证状态
  for f in docs/codearch/modules/*.md; do
    if grep -q "等级.*高\|等级.*极高" "$f" 2>/dev/null; then
      grep -q "验证状态\|验证等级" "$f" && echo "$f: PASS" || echo "$f: FAIL"
    fi
  done
  ```

- [ ] **总体报告中存在模块列表**，且每项含路径/范围、到 `modules/<module_name>.md` 的链接，链接指向的文件存在

- [ ] **总体报告中「技术特征概览」的「技术特征统计」已更新**
  ```bash
  grep -q "技术特征统计" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
  ```

- [ ] **分解审视已执行且结论为「通过」或已达成收敛**（见 [分解审视约定](../definitions/decomposition_review.md)）

### 质量检查

- [ ] 依赖方向合理（无未标注的循环依赖）
- [ ] 复杂度依据与 [complexity_levels](../definitions/complexity_levels.md) 一致
- [ ] 代码特征只记录客观事实，不含风险判断
- [ ] 使用示例代码完整且标注来源（文件路径或「Agent 编写」）
- [ ] 高复杂度模块的验证发现已反映在报告相关章节中
  ```bash
  # 检查模块报告是否含代码特征
  grep -l "代码特征" docs/codearch/modules/*.md 2>/dev/null | wc -l
  # 检查模块报告是否含关键代码位置索引
  grep -l "关键代码位置索引\|主要入口点" docs/codearch/modules/*.md 2>/dev/null | wc -l
  ```

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 模块报告（每模块一份） | `docs/codearch/modules/<module_name>.md` | 职责、边界、依赖、复杂度、关键设计要点、代码特征、关键代码位置索引、信息来源、使用示例、验证状态（高复杂度） |
| 总体报告中的模块列表与技术特征统计 | `docs/codearch/overall_report.md` | 含路径/范围、到各模块报告的链接、技术特征统计 |
| 分解审视结论与变更列表（若有不通过） | 可选：`docs/codearch/decomposition_changelog.md` | 见 [分解审视约定](../definitions/decomposition_review.md) |
| 模块地图（可选） | `docs/codearch/module_map.md` | 模块列表与依赖图汇总 |
| 探索性测试代码（可选） | 可选：`test/explore/` | L3 验证时编写的测试代码（若选择保留） |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 审视通过或已收敛，验证完成 | 回到 [Workflow.md](../Workflow.md) 决策树：若 Q3 为「否」则进入 [Phase 03: 编译与测试体系](03-build-and-tests.md)；若 Q3 为「是」则进入 [Phase 04: 报告产出与引用](04-reports.md) |
| 审视不通过且未收敛 | 按 [分解审视约定](../definitions/decomposition_review.md) 回退规则进入 [Phase 01](01-overview.md) 或本 Phase 02；下一轮 Phase 02 结束时再次执行审视 |
| 未通过（报告或链接缺失等） | 返回 Skill 02 补充分析后重新验收 |
| 未通过（代码特征或位置索引缺失） | 返回 Skill 02 任务 2.1 和任务 2，补充代码特征和位置索引后重新验收 |
| 未通过（使用示例缺失） | 返回 Skill 02 任务 1.5 和任务 2，补充使用示例后重新验收 |
| 未通过（高复杂度模块验证缺失） | 检查 Phase 03 是否完成；若否则先执行 Phase 03，再返回执行 Skill 02 任务 2.5 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型（<10 模块） | 1–2 小时 |
| 中型（10–50 模块） | 2–4 小时 |
| 大型（>50 模块） | 4–8 小时 |

---

**执行**：立即加载 [Skill 02](../skills/skill-02-modules.md) 开始执行
