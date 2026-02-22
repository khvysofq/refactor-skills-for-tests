# Phase 01: 验证存在性

> **前置条件**：从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树 Q1 为「否」进入；任务列表与（建议）build_and_tests 已就绪。  
> **目标**：对任务列表中每条任务构建/运行测试，记录验证结果（已确认/未复现/暂缓）。

---

## 进入条件

- 从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树判断 Q1 为「否」（尚未对每条任务完成验证存在性）
- 或需重新验证部分任务

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 01: 验证存在性](3-bug-remediation/skills/skill-01-verify.md)

**按需查阅**：

- 使用任务列表时参阅 [2-risk-assessment task_output_structure 下游使用约定](2-risk-assessment/definitions/task_output_structure.md)
- 记录验证结果时参阅 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md)

---

## 阶段验收标准

在 Skill 01 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **任务列表中每条任务均有验证结果**：已确认 / 未复现 / 暂缓
- [ ] 验证结果已写入 `docs/remediation/remediation_log.md`（可随任务逐条追加），供 Phase 02/03 使用
- [ ] 可执行检查：存在 `docs/remediation/remediation_log.md` 且含验证结果关键词

```bash
[ -f docs/remediation/remediation_log.md ] && echo "PASS" || echo "FAIL"
grep -q "已确认\|未复现\|暂缓" docs/remediation/remediation_log.md && echo "PASS" || echo "FAIL"
```

### 可选

- [ ] 每条任务对应测试场景已构建或已选定（可写在 log 或中间文件）

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 验证结果记录 | `docs/remediation/remediation_log.md` | 每条任务的验证结果（已确认/未复现/暂缓），可随任务逐条追加 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 回到 [Workflow.md](3-bug-remediation/Workflow.md) 决策树：若 Q2 为「否」则进入 [Phase 02: 实施修复](02-fix.md)；若 Q2 为「是」则继续 Q3 |
| 未通过 | 返回 Skill 01 补全验证后重新验收 |

---

## 反馈

验证过程中若发现**模块报告**或 **build_and_tests** 与代码/构建不符，应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选在 `docs/codearch/knowledge_base_changelog.md` 记录；若发现**模块边界划分不合理**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时暂停并先回阶段一执行审视或重跑后再继续本阶段。

---

**执行**：立即加载 [Skill 01](3-bug-remediation/skills/skill-01-verify.md) 开始执行
