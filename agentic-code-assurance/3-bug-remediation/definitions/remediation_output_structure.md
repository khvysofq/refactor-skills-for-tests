# 修复阶段产出路径与结构约定

> **阅读时机**：Phase 02/03 或撰写修复与记录时；与阶段二衔接时参阅「上游任务列表约定」。

---

## 上游任务列表约定（阶段二）

阶段三消费的任务列表来自 [2-risk-assessment](2-risk-assessment/Workflow.md)，结构见 [task_output_structure 下游使用约定](2-risk-assessment/definitions/task_output_structure.md)：

- **定位代码**：根据「位置」字段打开对应文件与行范围。
- **理解上下文**：根据「关联模块」加载 `docs/codearch/modules/<module_name>.md`。
- **构建测试**：可参考「建议验证方式」与「复现思路」确认 BUG 存在性。
- **实施修复**：确认后修改代码并做回归验证。

任务条目与阶段二产出通过**位置**或**任务序号**关联；每条任务在 remediation_log 中对应一条记录。

---

## 产出路径（相对仓库根）

| 产出 | 路径 | 说明 |
|------|------|------|
| 测试用例 | 工程现有测试目录 | 位置与运行方式遵循 `docs/codearch/build_and_tests.md`；不新增固定路径 |
| 修复 | 源码直接修改 | 可选将补丁归档至 `docs/remediation/patches/`（如 `task_1.patch` 或按位置命名） |
| 修复摘要 | `docs/remediation/remediation_log.md` | 阶段三主产出，结构见下 |

---

## remediation_log 必填内容

每条任务对应一条记录，须含至少：

| 字段 | 说明 |
|------|------|
| **任务标识** | 位置（如 `src/foo.cpp:42`）或任务序号，与 task_list 对应 |
| **验证结果** | 已确认 / 未复现 / 暂缓 |
| **修复摘要**（若已修复） | 简要说明修复内容；可选：测试路径、补丁路径 |

可选字段：时间、关联模块、建议验证方式引用。

---

## 验收检查

Phase 03 或 Skill 03 完成后，可执行以下检查（相对仓库根）：

```bash
# 修复摘要文件存在
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"

# 含验证结果与修复相关标题或关键词
grep -q "验证结果\|已确认\|未复现\|暂缓\|修复" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

---

**下一步**：返回 [Skill 03](3-bug-remediation/skills/skill-03-regression.md) 或 [Phase 03](3-bug-remediation/phases/03-regression.md)，按此结构生成或检查 remediation_log；或由 Phase 01/02 参考本约定落位测试与补丁。
