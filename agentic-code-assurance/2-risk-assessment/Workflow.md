# 风险评估工作流 - Agent 入口

> **读取指令**：本阶段为「风险评估」，在工程知识库与源码基础上识别潜在 BUG，输出疑似 BUG 任务列表。执行前请先阅读根目录 [README.md](../README.md)，确认阶段一（代码认知）已完成。

---

## 输入

| 输入 | 路径/说明 |
|------|------------|
| 工程知识库 | `docs/codearch/`：`overall_report.md`、`modules/<module_name>.md`、`build_and_tests.md` |
| 源代码 | 仓库根目录下的 C/C++ 源码与构建配置 |

---

## 输出

| 产出 | 路径 | 说明 |
|------|------|------|
| 疑似 BUG 任务列表 | `docs/risk_tasks/` | 至少一个任务列表文件（如 `task_list.md` 或 `risk_tasks.json`）。具体文件名与字段格式后续在本工作流中定义。 |

---

## 建议执行顺序

1. 阅读根目录 [README.md](../README.md)，确认阶段一已完成（`docs/codearch/overall_report.md` 存在且满足 1-code-cognition 的 Q1～Q3）。
2. 阅读 `docs/codearch/overall_report.md`，建立全局认知；根据模块列表与「技术特征概览」选择重点模块。
3. 按需加载 `docs/codearch/modules/<module_name>.md`，结合「代码特征」等章节定位可能的风险代码区域。
4. 结合模块报告与源代码进行深度审查，识别潜在 BUG 或风险点。
5. 将疑似 BUG 逐条写入 `docs/risk_tasks/` 下的任务列表文件。

---

## 说明

本目录下的 Phases、Skills、Definitions 等将后续补充；当前仅做入口与输入输出约定，便于与根 README 及阶段三衔接。
