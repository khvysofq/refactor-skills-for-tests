# Phase 03: 回归与产出

> **前置条件**：Phase 02 已完成修复（或本轮回溯无可修复任务）；从 [Workflow.md](../Workflow.md) 决策树 Q3 为「否」进入。  
> **目标**：运行全量回归测试，产出符合约定的 remediation_log.md。

---

## 进入条件

- 从 [Workflow.md](../Workflow.md) 决策树判断 Q3 为「否」（尚未完成回归验证并产出 remediation 摘要）
- Phase 02 已完成（或无可修复任务）

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 03: 回归与产出](../skills/skill-03-regression.md)

**按需查阅**：撰写或检查 remediation_log 时阅读 [remediation_output_structure](../definitions/remediation_output_structure.md)、[remediation_log 模板](../templates/remediation_log.md)

---

## 阶段验收标准

在 Skill 03 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **已按 build_and_tests 运行全量回归测试**，结果通过（或已在 log 中说明预已存在的失败）
- [ ] **`docs/remediation/remediation_log.md` 存在**，且每条任务有完整记录（验证结果、验证测试路径、测试归档状态等）
- [ ] **已确认 BUG 的验证测试已集成到正式测试套件**
- [ ] **未复现任务的验证测试已保留**在 `test/verification/` 中，供审查
- [ ] **暂缓任务的验证测试已隔离标注**
- [ ] **所有验证测试均已妥善归档**（已集成到正式套件或保留在 `test/verification/` 中）
- [ ] 执行 [remediation_output_structure](../definitions/remediation_output_structure.md) 中的验收检查命令通过

```bash
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"
grep -q "验证结果\|已确认\|未复现\|暂缓\|修复" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
grep -q "测试归档状态" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

---

## 阶段产出物

| 产出     | 路径                                  | 说明                                                     |
| -------- | ------------------------------------- | -------------------------------------------------------- |
| 修复摘要 | `docs/remediation/remediation_log.md` | 每条任务的完整记录（验证结果、修复摘要、测试归档状态等） |
| 回归结果 | log 内                                | 最终全量回归测试结果                                     |
| 集成测试 | 工程正式测试目录                      | 已确认 BUG 的验证测试已集成为永久回归守护                |

---

## 完成后跳转

| 验收结果 | 下一步                                  |
| -------- | --------------------------------------- |
| 通过     | 阶段三完成                              |
| 未通过   | 返回 Skill 03 补全 log 与回归后重新验收 |

---

## 反馈

执行过程中若发现知识库与代码不一致，按 [反馈操作约定](../../definitions/feedback_protocol.md) 更新。

---

**执行**：立即加载 [Skill 03](../skills/skill-03-regression.md) 开始执行
