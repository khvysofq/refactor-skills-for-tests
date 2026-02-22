# Skill 04: 报告产出与引用

> **触发条件**：Phase 04 指示（Phase 01–03 均已验收通过，或入口决策全部「是」后做收尾）  
> **目标**：汇总总体报告、确认模块报告引用正确，便于后续 Agent 按需加载

---

## 输入

- Phase 01–03 的产出：概览内容、模块报告目录、构建与测试文档
- [产出路径与报告结构约定](1-code-cognition/definitions/output_structure.md)

---

## 输出

| 产出               | 路径                              | 必须 |
| ------------------ | --------------------------------- | ---- |
| 总体报告（完整版） | `docs/codearch/overall_report.md` | ✓    |

总体报告须包含：工程概览（目标、输入、输出、主流程）、模块列表（每项含路径/范围、指向 `modules/<module_name>.md` 的链接）、构建与测试摘要或链接；且所有链接指向的文件存在。

---

## 核心任务

### 任务 1: 汇总总体报告

**目标**：生成或更新 `docs/codearch/overall_report.md`，使其符合 [output_structure](1-code-cognition/definitions/output_structure.md) 中「总体报告必须包含的章节」

**步骤**：

1. 若 Phase 01 已写概览，保留并补全；否则从 README/代码归纳补写「工程目标、输入、输出、主流程」
2. 从 Phase 02 产出整理「模块列表」：表格或列表，每行包含模块名、**路径/范围**（该模块对应目录或 glob）、复杂度、链接到 `docs/codearch/modules/<module_name>.md`（在总体报告中用相对路径 `modules/<module_name>.md`）
3. 增加「构建与测试摘要」：简要说明或链接到 `build_and_tests.md`
4. 可选：增加「后续分析建议」

使用 [总体报告模板](1-code-cognition/templates/overall-report.md) 作为结构参考。

### 任务 2: 校验引用与路径

**目标**：确保总体报告中的每个模块链接对应文件存在

**步骤**：

1. 从总体报告中提取所有 `modules/*.md` 链接
2. 检查 `docs/codearch/modules/` 下是否存在对应文件
3. 若链接与文件名不一致（如模块名含 `/` 被写成 `_`），修正链接或重命名文件使之一致

**验收检查**：

```bash
# 从总体报告中列出应存在的模块文件，逐项检查
for f in docs/codearch/modules/*.md; do
  [ -f "$f" ] && echo "OK $f" || echo "MISSING $f"
done
grep -oE 'modules/[^)]+\.md' docs/codearch/overall_report.md | sort -u | while read p; do
  [ -f "docs/codearch/$p" ] && echo "LINK OK $p" || echo "BROKEN $p"
done
```

### 任务 3: 可选 - 模块报告完整性抽查

**目标**：抽查若干模块报告是否包含必须章节（职责、边界、依赖、复杂度评级、关键设计要点）

**步骤**：

1. 随机或按优先级选 2–5 份模块报告
2. 确认每份含：职责描述、边界（输入/输出）、依赖、复杂度评级、关键设计要点
3. 缺项则退回 Phase 02 / Skill 02 补充
4. **可选**：检查总体报告中主流程、输入输出与当前模块列表是否一致；若明显不一致，建议回到 [Phase 01](1-code-cognition/phases/01-overview.md) 做小幅更新并注明

---

## 验收标准

### 必须满足

- [ ] `docs/codearch/overall_report.md` 存在且为完整总体报告
- [ ] 包含「工程概览」相关章节（目标、输入、输出、主流程）
- [ ] 包含「模块列表」且每项含路径/范围、到 `modules/<module_name>.md` 的链接
- [ ] 包含「构建与测试」摘要或到 `build_and_tests.md` 的链接
- [ ] 总体报告中出现的所有模块链接在 `docs/codearch/modules/` 下均有对应文件

### 验收检查

```bash
[ -f docs/codearch/overall_report.md ] && echo "PASS" || echo "FAIL"
grep -q "modules/.*\.md" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
[ -f docs/codearch/build_and_tests.md ] && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 严格按 [output_structure](1-code-cognition/definitions/output_structure.md) 检查章节与路径
- 链接使用相对路径，便于不同环境打开

## 不应该做

- 不在总体报告中内嵌模块报告全文（仅保留链接以支持按需加载）
- 不删除或移动已由 Phase 02 产出的模块报告路径，除非同步更新链接

---

## 状态跳转

| 验收结果          | 下一步                                                 |
| ----------------- | ------------------------------------------------------ |
| 通过              | 代码架构分析工作流完成；后续可进行深度代码审查或写测试 |
| 未通过 - 链接断裂 | 修正链接或补建缺失的模块报告后重新验收                 |
| 未通过 - 章节缺失 | 补写总体报告章节后重新验收                             |

---

## 时间预估

| 情况                 | 预估时间   |
| -------------------- | ---------- |
| 仅汇总与校验         | 15–30 分钟 |
| 需补写概览或大量链接 | 30–60 分钟 |

---

**完成后**：代码架构分析工作流结束；产出可供后续工作流或 Agent 按需加载使用
