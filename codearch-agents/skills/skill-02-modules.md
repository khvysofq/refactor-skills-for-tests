# Skill 02: 模块与依赖分析（含复杂度）

> **触发条件**：Phase 02 指示（入口决策 Q2 为「否」）  
> **目标**：识别模块、梳理依赖、为每个模块撰写独立报告并给出复杂度评级

---

## 输入

- 通过 Phase 01 的工程（已有总体报告概览）
- 代码目录与构建配置

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 模块报告（每模块一份） | `docs/codearch/modules/<module_name>.md` | ✓ |
| 总体报告中的模块列表与链接 | `docs/codearch/overall_report.md` | ✓ |
| 模块地图（可选） | `docs/codearch/module_map.md` | 可选 |

撰写时遵循 [产出结构约定](../definitions/output_structure.md)。进行复杂度评级时查阅 [复杂度等级定义](../definitions/complexity_levels.md)。

---

## 核心任务

**执行顺序**：首轮执行 Task 1 → 2 → 3 → 4 → 5；修正轮由分解审视驱动，可只执行 Task 2–4 中受影响的模块、Task 4（更新总报告）与 Task 5。

### 任务 1: 识别模块

**目标**：列出所有主要模块

**步骤**：

1. 分析目录结构（常见：一目录一模块）
2. 分析构建 target（`add_library` / `add_executable`、`cc_library` / `cc_binary`、Makefile target）
3. 为每个模块确定唯一标识（用于文件名，如 `core_utils`、`io_file`）
4. 记录模块路径与类型（库/服务/驱动/工具）

**分析命令参考**：

```bash
find . -type d -maxdepth 3 | grep -v '\./\.' | sort
grep -r "add_library\|add_executable" . --include="CMakeLists.txt"
grep -r "cc_library\|cc_binary" . --include="BUILD*"
```

模块边界与依赖分析时可按需查阅 [C/C++ 注意点](../definitions/cpp_cpp_notes.md)。

### 任务 2: 为每个模块撰写报告

**目标**：按 [模块报告模板](../templates/module-report.md) 填写职责、边界、依赖

**步骤**：

1. 为每个模块创建 `docs/codearch/modules/<module_name>.md`
2. 填写职责描述、输入/输出边界、内部依赖表、外部依赖表
3. 填写**关键设计要点**（建议 3–5 条：主要入口函数/类、核心数据结构、线程/并发假设、错误处理策略、扩展点等）
4. 填写「与其它模块的关系」
5. **复杂度评级**：按 [complexity_levels](../definitions/complexity_levels.md) 判定等级（低/中/高/极高）并写入报告，可选写一句依据

### 任务 3: 解析依赖方向

**目标**：建立模块间依赖关系，避免循环依赖遗漏

**步骤**：

1. 分析 include 与链接依赖（`#include`、`target_link_libraries` 等）
2. 在模块报告中写清「依赖谁 / 被谁依赖」
3. 可选：在 `module_map.md` 或总体报告中画 Mermaid 依赖图

**分析命令参考**：

```bash
grep -r "#include" src/ | sed 's/.*#include [<"]\(.*\)[>"]/\1/' | sort | uniq -c | sort -rn
grep -r "target_link_libraries" . --include="CMakeLists.txt"
```

### 任务 4: 更新总体报告中的模块列表

**目标**：在 `docs/codearch/overall_report.md` 中增加「模块列表」节，每行含模块名、**路径/范围**（该模块对应目录或 glob）、复杂度、指向 `modules/<module_name>.md` 的链接

**步骤**：

1. 打开或创建总体报告
2. 插入或更新模块列表表/列表，确保每项含路径/范围，链接为相对路径 `modules/<module_name>.md`

### 任务 5: 分解质量自检（分解审视）

**目标**：按 [分解审视约定](../definitions/decomposition_review.md) 检查当前模块划分是否稳定、合理

**步骤**：

1. 阅读并执行 [decomposition_review](../definitions/decomposition_review.md) 中的审视维度（checklist）：单一职责、边界清晰、粒度一致、循环依赖、与 Phase 01 概览一致
2. **若自检通过或变更列表为空**：返回 [Phase 02](../phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04
3. **若自检不通过**：写出本轮变更列表（拆/合/重命名），更新总体报告中的模块列表与链接；根据回退规则选择：
   - 仅模块边界/数量调整 → 只重做 Task 2–4（受影响的模块）及 Task 5
   - 主流程或顶层分解需修正 → 返回 [Phase 01](../phases/01-overview.md)，更新概览后重新执行 Phase 02

---

## 验收标准

### 必须满足

- [ ] 主要模块（建议 ≥80% 的已识别模块）均有对应 `docs/codearch/modules/<module_name>.md`
- [ ] 每份模块报告含：职责、边界（输入/输出）、依赖（内部/外部）、**复杂度评级**、**关键设计要点**（建议 3–5 条）
- [ ] 总体报告中存在「模块列表」且每条含路径/范围、到该模块报告的链接
- [ ] 链接指向的文件存在
- [ ] **分解审视已执行**且结论为「通过」或已达成收敛（Task 5）

### 验收检查

```bash
# 模块报告目录存在且非空
[ -d docs/codearch/modules ] && [ "$(ls -A docs/codearch/modules 2>/dev/null)" ] && echo "PASS" || echo "FAIL"
# 总体报告存在且含模块链接
[ -f docs/codearch/overall_report.md ] && grep -q "modules/.*\.md" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 使用 [complexity_levels](../definitions/complexity_levels.md) 统一评级
- 依赖关系结合构建配置与 include 验证
- 不确定处标注「待确认」

## 不应该做

- 不凭猜测填写职责与依赖
- 不在模块报告中写可测试性状态（S1–S4）或测试策略

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 审视通过或已收敛 | 返回 [Phase 02](../phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04 |
| 审视不通过 | 按变更列表修正后重做 Task 2–4（受影响模块）及 Task 5，或返回 [Phase 01](../phases/01-overview.md) 后重做 Phase 02 |
| 未通过 - 模块遗漏 | 继续任务 1、2 |
| 未通过 - 链接缺失 | 继续任务 4 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型（<10 模块） | 1–2 小时 |
| 中型（10–50 模块） | 2–4 小时 |
| 大型（>50 模块） | 4–8 小时 |

---

**完成后**：返回 [Phase 02](../phases/02-modules.md) 进行阶段验收
