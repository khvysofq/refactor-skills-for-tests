# Phase 00: 工程元数据采集

> **阶段代号**: P0  
> **入口条件**: 首次执行工作流，或需要更新元数据  
> **预计耗时**: 10–20 分钟

---

## 目标

机械性采集客观工程元数据。本阶段不需要模型判断，所有产出均来自确定性命令的直接输出。

---

## 执行

加载并执行 [Skill 00 — 元数据采集](../skills/skill-00-metadata.md)。

---

## 验收标准

- [ ] `docs/codearch/engineering_metadata.md` 文件已生成
- [ ] 包含以下内容：
  - [ ] 目录树（directory tree）
  - [ ] 构建目标（build targets）
  - [ ] 按目录统计的代码行数（per-directory line counts）
  - [ ] 命名空间列表（namespace list）
  - [ ] 文档清单（doc inventory）
  - [ ] 测试目录结构（test directory structure）
- [ ] 所有数据均来自机械性命令输出（无模型解读）

---

## 输出

| 产出物 | 路径 |
|---|---|
| 工程元数据报告 | `docs/codearch/engineering_metadata.md` |

---

## 跳转

| 结果 | 下一步 |
|---|---|
| P0 验收通过 | → P1 模块识别与初步划分 |

---

## 备注

> [可并行] P0 的各项采集命令可并行执行。
