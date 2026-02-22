# Skill 03: 回归与产出

> **触发条件**：Phase 03 指示（入口决策 Q3 为「否」）  
> **目标**：运行全量回归测试，汇总每条任务的验证结果与修复摘要，产出符合约定的 remediation_log.md。

---

## 输入

- Phase 01 的验证结果、Phase 02 的修复结果（或 remediation_log 初稿）
- [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md)
- [remediation_log 模板](3-bug-remediation/templates/remediation_log.md)
- `docs/codearch/build_and_tests.md`（用于运行回归）

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 修复摘要 | `docs/remediation/remediation_log.md` | ✓ |

须符合 remediation_output_structure 与模板；回归测试已执行或已在 log 中说明未运行原因。

---

## 核心任务

### 任务 1: 运行回归测试

1. 按 `docs/codearch/build_and_tests.md` 运行全量测试套件（回归）。
2. 记录结果：通过 / 失败；若未运行（如无测试体系或环境不可用），在 remediation_log 中说明原因。

### 任务 2: 汇总并写出 remediation_log

1. 汇总每条任务的验证结果（已确认/未复现/暂缓）与修复摘要（若已修复：简要说明、可选测试路径与补丁路径）。
2. 按 [remediation_log 模板](3-bug-remediation/templates/remediation_log.md) 与 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 写出 `docs/remediation/remediation_log.md`。
3. 可选：在 log 头部注明本轮回溯范围、完成日期、回归测试结果。

### 任务 3: 验收检查

1. 执行 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 中的验收检查命令（文件存在、含验证结果/修复关键词）。
2. 确认通过后返回 Phase 03 做阶段验收。

---

## 验收

与 [Phase 03](3-bug-remediation/phases/03-regression.md) 阶段验收标准一致：remediation_log 存在、每条任务有验证结果与（若已修复）修复摘要、验收命令通过。

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 03](3-bug-remediation/phases/03-regression.md) 完成阶段验收；阶段三完成 |
| 未通过 | 补全 log 与回归说明后重新验收 |

---

## 反馈

若在汇总时发现此前依赖的**工程理解文档**有误，仍按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选在 `docs/codearch/knowledge_base_changelog.md` 记录。

---

**完成后**：返回 [Phase 03](3-bug-remediation/phases/03-regression.md) 进行阶段验收
