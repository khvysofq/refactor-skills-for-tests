# Phase 01: 范围与策略

> **前置条件**：从 [Workflow.md](2-risk-assessment/Workflow.md) 决策树 Q1 为「否」进入。  
> **目标**：确定本轮回析的模块范围与风险维度/优先级，产出分析范围文档。

---

## 进入条件

- 从 [Workflow.md](2-risk-assessment/Workflow.md) 入口决策树判断 Q1 为「否」（分析范围与策略尚未确定）
- 或需重新划定分析范围

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 01: 范围与策略](2-risk-assessment/skills/skill-01-scope.md)

**按需查阅**：确定风险维度时阅读 [风险类型定义](2-risk-assessment/definitions/risk_types.md)

---

## 阶段验收标准

在 Skill 01 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **分析范围产出存在**：`docs/risk_tasks/scope.md` 存在，或在后续 task_list.md 头部有明确范围说明
- [ ] **包含选定模块列表**：至少列出本轮回析涉及的模块（与 overall_report 模块列表一致）
- [ ] **包含风险维度/优先级**：至少说明重点审查的风险类型（与 [risk_types](2-risk-assessment/definitions/risk_types.md) 对齐）

```bash
# 检查 scope 文件存在
[ -f docs/risk_tasks/scope.md ] && echo "PASS" || echo "FAIL"

# 或检查 task_list 头部含范围说明（若约定写在该处）
grep -q "分析范围\|选定模块\|风险" docs/risk_tasks/task_list.md 2>/dev/null && echo "PASS" || true
```

### 可选

- [ ] 标注分析日期或仓库版本，便于后续对照

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 分析范围 | `docs/risk_tasks/scope.md` | 选定模块、风险维度、优先级；或写入 task_list.md 头部 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 回到 [Workflow.md](2-risk-assessment/Workflow.md) 决策树：若 Q2 为「否」则进入 [Phase 02: 深度审查](02-review.md)；若 Q2 为「是」则继续 Q3 |
| 未通过 | 返回 Skill 01 补全内容后重新验收 |

---

## 反馈

若在本阶段发现 `docs/codearch/overall_report.md` 或模块列表与代码严重不符（如缺失模块、描述错误），应按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 更新知识库或记录；必要时先回阶段一（[1-code-cognition](1-code-cognition/Workflow.md)）执行更新或分解审视后再继续。可选：在 `docs/codearch/knowledge_base_changelog.md` 记录本次反馈摘要。

---

**执行**：立即加载 [Skill 01](2-risk-assessment/skills/skill-01-scope.md) 开始执行
