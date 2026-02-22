# Skill 03: 汇总与产出

> **触发条件**：Phase 03 指示（入口决策 Q3 为「否」）  
> **目标**：合并/去重任务条目，补全必填与可选字段，产出符合约定的 `docs/risk_tasks/task_list.md`。

---

## 输入

- Phase 02 产出的任务条目（可能分布在 `docs/risk_tasks/task_list.md` 初稿或临时文件）
- [任务列表产出结构约定](2-risk-assessment/definitions/task_output_structure.md)
- [任务列表模板](2-risk-assessment/templates/task_list.md)

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 任务列表（定稿） | `docs/risk_tasks/task_list.md` | ✓ |

须符合 task_output_structure 的必填字段与路径约定，便于阶段三（3-bug-remediation）消费。

---

## 核心任务

### 任务 1: 合并与去重

1. 收集 Phase 02 产出的所有任务条目（来自 task_list 初稿或临时文件）。
2. 合并为单一列表，去重（相同位置或相同描述可合并为一条，保留最完整字段）。
3. 按模块或按位置排序（可选），便于阅读与阶段三按序处理。

### 任务 2: 补全字段

1. 检查每条条目是否含**必填字段**：位置、简要描述、风险类型、关联模块。
2. 缺失则补全；可选字段（置信度、建议验证方式、复现思路）可酌情补充。
3. 风险类型取值须与 [risk_types](2-risk-assessment/definitions/risk_types.md) 一致。

### 任务 3: 按模板写出

1. 使用 [任务列表模板](2-risk-assessment/templates/task_list.md) 作为结构参考。
2. 将最终列表写入 `docs/risk_tasks/task_list.md`（相对仓库根）。
3. 可选：在头部保留或补充「分析范围」摘要（与 scope.md 或 Phase 01 产出一致）。

### 任务 4: 验收检查

1. 执行 [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) 中的验收检查命令（文件存在、必填标题/字段存在）。
2. 确认通过后返回 Phase 03 做阶段验收。

---

## 验收

与 [Phase 03](2-risk-assessment/phases/03-summary.md) 阶段验收标准一致：task_list.md 存在、每条含必填字段、definitions 中的验收命令通过。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 03](2-risk-assessment/phases/03-summary.md) 完成阶段验收；阶段二完成，可进入 [3-bug-remediation](3-bug-remediation/Workflow.md) |
| 未通过 | 补全字段与结构后重新验收 |

---

## 反馈

若在汇总时发现此前审查所依赖的工程理解文档（overall_report 或某模块报告）有误，仍按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 下相应内容，并可选在 `docs/codearch/knowledge_base_changelog.md` 记录。

---

**完成后**：返回 [Phase 03](2-risk-assessment/phases/03-summary.md) 进行阶段验收
