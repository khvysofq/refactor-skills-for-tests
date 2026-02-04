# 总体报告模板

> **用途**：生成代码架构分析的总体报告，供后续 Agent 或人工按需引用模块报告  
> **位置**：`docs/codearch/overall_report.md`

---

## 使用说明

1. Phase 01 可先填充「工程概览」部分；Phase 02/04 补充「模块列表」；Phase 03 后补充「构建与测试摘要」。
2. 最终由 Phase 04 汇总为一份完整总体报告，确保所有链接指向 `docs/codearch/modules/<module_name>.md`。
3. 模块列表仅保留链接，不内嵌模块全文，便于按需加载。

---

## 模板

```markdown
# <工程名称> - 代码架构分析总体报告

> 分析日期: YYYY-MM-DD
> 工作流: codearch-agents
> 分析范围/版本（可选）: 仓库 commit/tag: <commit_or_tag>；分析范围: <全库或子路径，如 src/>

---

## 工程概览

### 工程目标

<一段话描述工程主要做什么>

### 输入

- <输入类型1>: <描述>
- <输入类型2>: <描述>

### 输出

- <输出类型1>: <描述>
- <输出类型2>: <描述>

### 主流程

<步骤列表或 Mermaid 流程图>

1. <步骤1>
2. <步骤2>
3. <步骤3>

---

## 模块列表

| 模块 | 路径/范围 | 复杂度 | 报告链接 |
|------|------------|--------|----------|
| <module_a> | src/core/ | 低/中/高/极高 | [链接](modules/<module_a>.md) |
| <module_b> | src/parser/*.cpp | 低/中/高/极高 | [链接](modules/<module_b>.md) |

或列表形式（须含路径/范围）：

- [<module_a>](modules/<module_a>.md) — 路径/范围: `src/core/` — 复杂度：低
- [<module_b>](modules/<module_b>.md) — 路径/范围: `src/parser/` — 复杂度：中

---

## 构建与测试摘要

<简要说明或链接到 build_and_tests.md>

参见 [构建与测试说明](build_and_tests.md)。

---

## 后续分析建议（可选）

<对深度代码审查、写测试等的建议>
```

---

## 与 output_structure 的对应

- 路径、章节要求见 [产出路径与报告结构约定](../definitions/output_structure.md)。
- **可选**：可在文档头部使用 YAML frontmatter，字段如 `summary`、`scope_commit`、`module_count`，供 Agent 做轻量解析或 embedding。
