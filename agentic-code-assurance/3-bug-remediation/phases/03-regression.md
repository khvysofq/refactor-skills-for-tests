# Phase 03: 回归与产出

> **前置条件**：Phase 02 已完成修复（或本轮回溯无可修复任务）；从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树 Q3 为「否」进入。  
> **目标**：运行全量回归测试，产出符合约定的 remediation_log.md。

---

## 进入条件

- 从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树判断 Q3 为「否」（尚未完成回归验证并产出 remediation 摘要）
- Phase 02 已完成（或无可修复任务）

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 03: 回归与产出](3-bug-remediation/skills/skill-03-regression.md)

**按需查阅**：撰写或检查 remediation_log 时阅读 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md)、[remediation_log 模板](3-bug-remediation/templates/remediation_log.md)

---

## 阶段验收标准

在 Skill 03 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **已按 build_and_tests 运行全量回归测试**，或已在 log 中说明未运行原因
- [ ] **`docs/remediation/remediation_log.md` 存在**，且每条任务有验证结果与（若已修复）修复摘要
- [ ] 执行 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md) 中的验收检查命令通过

```bash
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"
grep -q "验证结果\|已确认\|未复现\|暂缓\|修复" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

### 可选

- [ ] 回归测试结果（通过/失败）已写在 log 或单独说明

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 修复摘要 | `docs/remediation/remediation_log.md` | 每条任务验证结果与修复摘要 |
| 回归结果（可选） | log 内或单独说明 | 全量测试通过/失败 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 阶段三完成 |
| 未通过 | 返回 Skill 03 补全 log 与回归后重新验收 |

---

## 反馈

本阶段若发现此前依赖的**工程理解文档**有误，仍按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选在 `docs/codearch/knowledge_base_changelog.md` 记录。

---

**执行**：立即加载 [Skill 03](3-bug-remediation/skills/skill-03-regression.md) 开始执行
