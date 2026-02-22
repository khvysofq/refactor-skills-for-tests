# Phase 03: 汇总与产出

> **前置条件**：Phase 02 已产出审查结果（任务列表或临时清单）；从 [Workflow.md](2-risk-assessment/Workflow.md) 决策树 Q3 为「否」进入。  
> **目标**：合并/去重任务条目，补全必填与可选字段，产出符合约定的 `task_list.md`。

---

## 进入条件

- 从 [Workflow.md](2-risk-assessment/Workflow.md) 决策树判断 Q3 为「否」（任务列表未生成或未满足约定结构）
- Phase 02 已产出疑似 BUG 条目（可能分散在临时文件或 task_list 初稿）

---

## 执行指令

**加载 Skill**：阅读并执行 → [Skill 03: 汇总与产出](2-risk-assessment/skills/skill-03-summary.md)

**按需查阅**：撰写或检查任务列表时阅读 [任务列表产出结构约定](2-risk-assessment/definitions/task_output_structure.md)、[任务列表模板](2-risk-assessment/templates/task_list.md)

---

## 阶段验收标准

在 Skill 03 完成后，验证以下条件全部满足：

### 必须满足

- [ ] **任务列表文件存在**：`docs/risk_tasks/task_list.md` 存在
- [ ] **每条任务含** [task_output_structure](2-risk-assessment/definitions/task_output_structure.md) **规定的必填字段**：位置、简要描述、风险类型、关联模块
- [ ] **执行 definitions 中的验收检查命令通过**（见 task_output_structure.md）

```bash
[ -f docs/risk_tasks/task_list.md ] && echo "PASS" || echo "FAIL"
grep -q "位置\|描述\|风险类型\|关联模块" docs/risk_tasks/task_list.md && echo "PASS" || echo "FAIL"
```

### 可选

- [ ] 格式与 [模板](2-risk-assessment/templates/task_list.md) 一致，便于阶段三解析

---

## 阶段产出物

| 产出 | 路径 | 说明 |
|------|------|------|
| 任务列表 | `docs/risk_tasks/task_list.md` | 符合约定的疑似 BUG 任务列表，供阶段三使用 |

---

## 完成后跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 阶段二完成；可进入 [3-bug-remediation](3-bug-remediation/Workflow.md) 进行 BUG 确认与修复 |
| 未通过 | 返回 Skill 03 补全字段与结构后重新验收 |

---

## 反馈

本阶段若发现此前审查所依赖的工程理解文档有误，仍按 [根目录 Workflow 四、反馈机制](../../Workflow.md) 补充或修正 `docs/codearch/` 下相应报告，并可选在 `docs/codearch/knowledge_base_changelog.md` 记录。

---

**执行**：立即加载 [Skill 03](2-risk-assessment/skills/skill-03-summary.md) 开始执行
