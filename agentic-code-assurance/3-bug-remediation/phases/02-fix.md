# Phase 02: 实施修复

> **前置条件**：Phase 01 已产出验证结果，至少存在「已确认」任务；从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树 Q2 为「否」进入。  
> **目标**：对「已确认」任务实施修复，产出源码变更与可选补丁/测试。

---

## 进入条件

- 从 [Workflow.md](3-bug-remediation/Workflow.md) 决策树判断 Q2 为「否」（尚未对已确认任务完成修复）
- Phase 01 已产出验证结果，且至少有一条「已确认」

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 02: 实施修复](3-bug-remediation/skills/skill-02-fix.md)

**按需查阅**：补丁与测试落位时阅读 [remediation_output_structure](3-bug-remediation/definitions/remediation_output_structure.md)

---

## 阶段验收标准

在 Skill 02 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **所有「已确认」任务均已实施修复**：源码已变更
- [ ] 可检查：关键文件已修改，或（若无可确认任务）已注明「本轮回溯无可修复任务」

### 可选

- [ ] 补丁已归档至 `docs/remediation/patches/`
- [ ] 新增或补充的测试用例已落入工程测试目录（遵循 build_and_tests）

```bash
# 若有补丁目录：至少存在一个 patch（当有已确认任务时）
[ -d docs/remediation/patches/ ] && ls docs/remediation/patches/*.patch 2>/dev/null || true
```

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 源码变更 | 仓库源码 | 直接修改 |
| 补丁（可选） | `docs/remediation/patches/` | 按约定命名 |
| 测试用例（可选） | 工程测试目录 | 遵循 build_and_tests |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 回到 [Workflow.md](3-bug-remediation/Workflow.md) 决策树：若 Q3 为「否」则进入 [Phase 03: 回归与产出](03-regression.md)；若 Q3 为「是」则阶段三完成 |
| 未通过 | 返回 Skill 02 补全修复后重新验收 |

---

## 反馈

修复过程中若发现**工程理解文档**与代码有误，应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新 `docs/codearch/` 并可选记录；若发现**模块边界划分不合理**，须参见 [1-code-cognition 分解审视约定](1-code-cognition/definitions/decomposition_review.md)，必要时回阶段一。

---

**执行**：立即加载 [Skill 02](3-bug-remediation/skills/skill-02-fix.md) 开始执行
