# 任务列表产出路径与结构约定

> **阅读时机**：Phase 03 或撰写/检查任务列表时；阶段三（3-bug-remediation）工作流按需引用时参阅「下游使用约定」。

---

## 产出路径

所有阶段二产出均位于**仓库根目录**下的 `docs/risk_tasks/`。

| 产出 | 路径 | 说明 |
|------|------|------|
| 任务列表（主文件） | `docs/risk_tasks/task_list.md` | 疑似 BUG 任务条目汇总，结构见下 |
| 分析范围（可选） | `docs/risk_tasks/scope.md` | Phase 01 产出的选定模块与风险维度；也可写在 task_list.md 头部 |

---

## 任务条目必填字段

每条疑似 BUG 任务必须包含以下字段（与 [risk_types](risk_types.md) 对齐）：

| 字段 | 说明 |
|------|------|
| **位置** | 文件路径与行号或范围（如 `src/foo.cpp:42` 或 `src/bar.cpp:10-25`），供阶段三定位代码 |
| **简要描述** | 一句话描述疑似问题（如「缓冲区可能未校验长度」） |
| **风险类型** | 取值见 [risk_types](2-risk-assessment/definitions/risk_types.md)：内存管理、并发竞态、I/O 与外部输入、错误处理等 |
| **关联模块** | 对应 `docs/codearch/modules/` 的模块名（与 overall_report 模块列表一致），便于按需加载模块报告 |

---

## 任务条目可选字段

| 字段 | 说明 |
|------|------|
| 置信度 | 如 高/中/低，表示疑似程度 |
| 建议验证方式 | 如何写测试或复现（如「单元测试传入超长输入」） |
| 复现思路 | 简要步骤或前置条件 |

---

## 下游使用约定（供 3-bug-remediation 引用）

阶段三（BUG 确认与修复）在使用本任务列表时：

- **定位代码**：根据「位置」字段打开对应文件与行范围。
- **理解上下文**：根据「关联模块」加载 `docs/codearch/modules/<module_name>.md`，结合「简要描述」与「风险类型」确定审查重点。
- **构建测试**：可参考「建议验证方式」与「复现思路」编写或运行测试以确认 BUG 存在性。
- **实施修复**：确认后按常规修复流程修改代码，并做回归验证。

---

## 验收检查

Phase 03 或 Skill 03 完成后，可执行以下检查（相对仓库根）：

**任务列表文件存在且含必填结构：**

```bash
# 文件存在
[ -f docs/risk_tasks/task_list.md ] && echo "PASS" || echo "FAIL"

# 包含任务条目（表格或列表标题/分隔符）
grep -q "位置\|描述\|风险类型\|关联模块" docs/risk_tasks/task_list.md && echo "PASS" || echo "FAIL"
```

**可选：检查至少有一条任务（若阶段二有意产出空列表则可不检）：**

```bash
# 存在疑似 BUG 条目（可根据实际格式调整）
grep -c "\.cpp:\|\.c:\|\.h:" docs/risk_tasks/task_list.md
```

---

**下一步**：返回 [Skill 03](2-risk-assessment/skills/skill-03-summary.md) 或 [Phase 03](2-risk-assessment/phases/03-summary.md)，按此结构生成或检查任务列表；或由 [3-bug-remediation](3-bug-remediation/Workflow.md) 按下游使用约定消费本产出。
