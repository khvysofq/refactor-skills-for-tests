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

### 任务 1: 运行全量回归测试

1. 按 `docs/codearch/build_and_tests.md` 运行全量测试套件（最终回归）。
2. 记录结果：通过 / 失败。全量回归应当通过（Phase 02 已确保修复不引入新失败）。
3. 若出现新的失败，返回 Phase 02 修复。

### 任务 1.5: 测试代码归档与清理

**目标**：管理验证测试的生命周期——确认有效的测试集成到正式测试套件，无用的测试删除。

1. **已确认（已修复）的任务**：
   - 将对应的验证测试从 `test/verification/` 移入工程的正式测试目录
   - 按工程现有的测试命名约定重命名（参考 `docs/codearch/build_and_tests.md` 中的命名规则）
   - 确保移入后的测试能通过正常的测试运行命令执行
   - 这些测试将作为**永久回归守护**，防止 BUG 再次出现

2. **未复现的任务**：
   - **删除**对应的验证测试文件
   - 这些测试已完成验证使命，无需保留

3. **暂缓的任务**：
   - 将对应的验证测试移入 `test/deferred/` 目录（或在验证测试目录中标注 `DEFERRED`）
   - 在测试文件头部添加注释说明暂缓原因
   - 后续可在条件满足时重新运行

4. **更新 remediation_log**：
   - 为每条任务记录「测试归档状态」：已集成 / 已删除 / 保留(暂缓)
   - 对已集成的测试，记录最终在正式测试套件中的路径与测试名

5. **运行最终全量测试**：
   - 归档完成后，再次运行全量测试套件，确认集成后的测试正常工作
   - 确认 `test/verification/` 目录已清空（所有测试已归档或删除）

### 任务 2: 汇总并定稿 remediation_log

1. 汇总每条任务的完整信息：验证结果、修复摘要、验证测试路径、修复前后测试结果、测试归档状态、修复涉及的文件列表。
2. 按 [remediation_log 模板](3-bug-remediation/templates/remediation_log.md) 与 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 定稿 `docs/remediation/remediation_log.md`。
3. 在 log 头部注明：本轮回溯范围、完成日期、最终回归测试结果、已修复/未复现/暂缓的数量汇总。

### 任务 3: 验收检查

1. 执行 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 中的验收检查命令。
2. 确认 `test/verification/` 目录已清空。
3. 确认已集成的测试在正式测试套件中可正常运行。
4. 确认通过后返回 Phase 03 做阶段验收。

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
