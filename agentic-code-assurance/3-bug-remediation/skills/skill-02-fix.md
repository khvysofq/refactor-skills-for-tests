# Skill 02: 实施修复

> **触发条件**：Phase 02 指示（入口决策 Q2 为「否」）  
> **目标**：对「已确认」任务实施修复，产出源码变更与可选补丁/测试。

---

## 输入

- Phase 01 的验证结果（仅处理「已确认」任务）
- `docs/risk_tasks/task_list.md`
- 按需的 `docs/codearch/modules/<module_name>.md`、`docs/codearch/build_and_tests.md`
- 仓库源码

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 源码修改 | 仓库源码 | ✓（对已确认任务） |
| 补丁（可选） | `docs/remediation/patches/` | 按 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 命名 |
| 测试用例（可选） | 工程测试目录 | 遵循 build_and_tests |

---

## 核心任务

### 任务 1: 对每条已确认任务实施修复

1. 根据 Phase 01 的验证结果，筛选出「已确认」任务。
2. **每条已确认任务**：
   - 根据「位置」「简要描述」「风险类型」定位代码并实施修复；
   - 可选：生成 patch 并归档至 `docs/remediation/patches/`（如 `task_<n>.patch` 或按位置命名）；
   - 可选：补充或运行单测确认修复有效；
   - 遵循 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 的测试与补丁落位约定。
3. 若本轮回溯无「已确认」任务，在 remediation_log 或 Phase 03 中注明「本轮回溯无可修复任务」即可。

### 任务 2: 验收自检

- 确认所有已确认任务均已实施修复（源码已变更）；
- 可选：确认补丁已归档、测试已落入工程目录。

---

## 验收

与 [Phase 02](3-bug-remediation/phases/02-fix.md) 阶段验收标准一致：已确认任务均已修复、可检查通过。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 02](3-bug-remediation/phases/02-fix.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或继续 Q3 |
| 未通过 | 补全修复后重新验收 |

---

## 反馈

修复过程中若发现**工程理解文档**与代码有误，应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选记录；若发现**模块边界划分不合理**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时回阶段一。

---

**完成后**：返回 [Phase 02](3-bug-remediation/phases/02-fix.md) 进行阶段验收
