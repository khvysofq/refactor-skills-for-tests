# Phase 04: 报告产出与引用

> **前置条件**：Phase 01–03 均已验收通过（含 Phase 02 分解审视通过或已收敛），或从 [Workflow.md](../Workflow.md) 入口决策树 Q1–Q2b–Q3 全部「是」后做收尾  
> **目标**：汇总总体报告、确认模块报告引用正确，便于后续 Agent 按需加载

---

## 进入条件

- Phase 01、02、03 均已验收通过
- 或从 [Workflow.md](../Workflow.md) 决策树判断 Q1–Q2b–Q3 全部为「是」，需做一次报告汇总与引用检查

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 04: 报告产出与引用](../skills/skill-04-reports.md)  
**按需查阅**：撰写或检查报告时阅读 [产出路径与报告结构约定](../definitions/output_structure.md)

---

## 阶段验收标准

在 Skill 04 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **总体报告完整存在**
  ```bash
  [ -f docs/codearch/overall_report.md ] && echo "PASS" || echo "FAIL"
  ```

- [ ] **总体报告包含**：
  - [ ] 工程概览（目标、输入、输出、主流程）
  - [ ] 模块列表，且每项含到 `modules/<module_name>.md` 的链接
  - [ ] 构建与测试摘要或到 `build_and_tests.md` 的链接

- [ ] **引用校验**：总体报告中出现的所有 `modules/*.md` 链接，在 `docs/codearch/modules/` 下均有对应文件
  ```bash
  grep -oE 'modules/[^)]+\.md' docs/codearch/overall_report.md | sort -u | while read p; do
    [ -f "docs/codearch/$p" ] && echo "OK $p" || echo "BROKEN $p"
  done
  ```

### 可选

- [ ] 抽查 2–5 份模块报告，确认含职责、边界、依赖、复杂度评级、关键设计要点
- [ ] 检查总体报告中主流程、输入输出与当前模块列表是否一致；若明显不一致，建议回到 [Phase 01](01-overview.md) 做小幅更新并注明

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 总体报告（完整版） | `docs/codearch/overall_report.md` | 概览 + 模块列表（含链接）+ 构建/测试摘要 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | **代码架构分析工作流完成**；产出可供后续深度代码审查、写测试等按需加载使用 |
| 未通过 | 返回 Skill 04 修正链接或补写章节后重新验收 |

---

## 时间预估

| 情况 | 预估时间 |
|------|----------|
| 仅汇总与校验 | 15–30 分钟 |
| 需补写或大量修正 | 30–60 分钟 |

---

**执行**：立即加载 [Skill 04](../skills/skill-04-reports.md) 开始执行
