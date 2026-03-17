# Skill 01: 模块识别与 L1 报告生成

> **触发**: Phase 01 指示  
> **目标**: 识别模块边界，为每个模块生成 L1 轻量报告  
> **预计耗时**: 小型项目 <30 分钟 · 中型 30–60 分钟 · 大型 1–2 小时

---

## 输入

| 输入 | 来源 | 说明 |
|---|---|---|
| `docs/codearch/engineering_metadata.md` | P0 产出 | 工程元数据（目录结构、构建 Target、代码行数等） |
| 目标范围 | 工作流上下文 | 首次执行：整个项目；迭代重入：P3 指定的模块 |
| P3 再入列表（若重入） | P3 产出 | 需要拆分的具体模块清单 |

## 输出

| 产出物 | 路径 | 必须 |
|---|---|---|
| 各模块 L1 报告 | `docs/codearch/modules/<module_name>.md` | ✅ |
| 更新后的模块索引 | 总体报告中的模块索引部分 | ✅ |

---

## 核心任务

### 任务 1: 结构化候选识别（客观）

基于 engineering_metadata 数据，执行以下识别步骤：

1. 列出所有构建目标（build target）作为候选模块
2. 将目录结构映射为候选模块（一个顶层目录 = 一个候选）
3. 与命名空间列表交叉验证
4. 记录每个候选的：名称、路径、近似代码行数（取自元数据）

```bash
# 从构建目标提取候选模块名
grep -r "add_library\|add_executable" . --include="CMakeLists.txt" | \
  sed 's/.*add_library(\|.*add_executable(//' | sed 's/ .*//' | sort -u
```

### 任务 2: 语义验证（主观）

对任务 1 产生的每个候选模块，模型评估以下问题：

- 该边界是否对应一个**语义上独立**的职责？
- 边界内代码的**内聚度**如何（高 / 中 / 低）？
- 是否有候选应当**合并**（两个构建目标实际属于同一逻辑模块）？
- 是否有候选应当**拆分**（一个构建目标包含明显不同的职责）？

对每个合并/拆分决策，记录具体理由。

### 任务 3: 候选方案对比（可选，提高一致性）

若任务 2 中产生了调整（合并或拆分），执行以下对比步骤：

1. 输出**原始结构化分解**（任务 1 结果）
2. 输出**调整后分解**（任务 2 调整后）
3. 对比差异，记录每项调整的原因

此步骤有助于提升不同模型运行之间的一致性。

### 任务 4: 生成 L1 报告 [可并行]

对每个最终确认的模块：

1. 在 `docs/codearch/modules/` 下创建 `<module_name>.md`，使用 [L1 模板](../templates/module-report-L1.md)
2. 填写：模块名称、路径、代码指标（取自 engineering_metadata）、一句话职责描述
3. 填写依赖概览：扫描 `#include` 模式，识别内部/外部依赖
4. **留空**复杂度评级（由 P2 填写）
5. **留空**拆分说明（由 P2 填写）

```bash
# 快速依赖扫描（对每个模块执行）
MODULE_PATH="src/<module>"
grep -r "#include" $MODULE_PATH --include="*.cpp" --include="*.h" | \
  grep -v "third_party" | sed 's/.*#include [<"]\(.*\)[>"]/\1/' | sort -u
```

> **[可并行]** 多个模块的 L1 报告可并行生成。

### 任务 5: 更新模块索引

更新 `docs/codearch/overall_report.md` 中的模块索引：

- 将新识别的模块添加到模块表格
- 若为迭代重入：在父模块下以 ↳ 缩进添加子模块
- 将已拆分的父模块状态标记为「已拆分」

### 任务 6: 拆分状态确认（仅迭代重入时）

**仅当 P1 因 P3 再入列表指示「待拆」模块而重入时**，在生成子模块报告后执行本任务。

P1 是**唯一有权将模块拆分状态从「待拆」更新为「已拆」的阶段**（P2 禁止写「已拆」，详见 [complexity_levels — 拆分结论格式](../definitions/complexity_levels.md)）。

步骤：

1. 对每个本轮拆分的父模块，验证所有声称的子模块报告文件已实际存在：

```bash
# 验证子模块报告文件存在性（对每个拆分的父模块执行）
PARENT_MODULE="<parent_module_name>"
SUB_MODULES="<sub1> <sub2> <sub3>"
ALL_OK=1
for sub in $SUB_MODULES; do
  if [ -f "docs/codearch/modules/${sub}.md" ] || [ -f "docs/codearch/modules/${PARENT_MODULE}-${sub}.md" ]; then
    echo "OK: $sub"
  else
    echo "FAIL: $sub — report file not found"
    ALL_OK=0
  fi
done
[ $ALL_OK -eq 1 ] && echo "All sub-module reports verified" || echo "ERROR: Some reports missing, cannot mark as 已拆"
```

2. **仅当所有子模块报告文件验证通过后**，将父模块报告中的拆分说明从「待拆」更新为「已拆（子模块：xxx_a, xxx_b, ...）」
3. 若任何子模块报告缺失，**不得更新状态**，须先补全缺失报告

---

## 验收标准

- [ ] 每个模块的 L1 报告已存放于 `docs/codearch/modules/`
- [ ] 总体报告的模块索引已更新
- [ ] 每份 L1 报告包含：模块名称、路径、代码指标、职责描述、依赖概览
- [ ] （迭代重入时）所有拆分模块的子报告文件存在性已通过脚本验证，父模块状态已更新为「已拆」

---

## 注意事项

| 类别 | 说明 |
|---|---|
| **DO** | 使用 engineering_metadata 数据；对模块边界进行语义验证；记录合并/拆分理由；迭代重入时用脚本验证子模块报告文件存在后再标记「已拆」 |
| **DON'T** | 不要执行深度分析（那是 P4 的职责）；不要分配复杂度评级（那是 P2 的职责）；不要在缺乏证据的情况下虚构职责描述 |
| **P1 专属权限** | P1 是唯一有权设置拆分状态为「已拆」的阶段——必须在子模块报告文件通过验证后才能设置 |

---

## 跳转

| 结果 | 下一步 |
|---|---|
| 验收通过 | → Phase 01 验收 |
