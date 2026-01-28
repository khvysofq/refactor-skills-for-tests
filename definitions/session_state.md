# 会话状态持久化定义

> **阅读时机**：任务开始时、任务中断后恢复时、每个阶段/Skill完成时

---

## 概述

本文档定义了工作流的状态持久化机制，确保任务在任何时刻中断后都能快速恢复到之前的执行状态。

**核心原则**：
- 每次状态变更后立即持久化
- 状态文件应包含足够信息以支持完全恢复
- 状态文件使用人类可读的Markdown格式

---

## 会话状态文件

### 主状态文件

**路径**：`docs/testing/.session_state.md`

**用途**：记录当前工作流的整体执行状态，是恢复任务的首要入口。

**模板**：

```markdown
# 重构工作流会话状态

> 创建时间: YYYY-MM-DD HH:MM
> 最后更新: YYYY-MM-DD HH:MM
> 工作流版本: v2.0

---

## 当前状态

| 属性 | 值 |
|------|-----|
| **当前阶段** | [Phase 01 / Phase 02 / Phase 03 / Phase 04] |
| **当前Skill** | [Skill XX / 无] |
| **当前模块** | [模块名称 / 无] |
| **门禁状态** | [G0 / G1 / G2 / G3 / 未运行] |
| **阻塞状态** | [无 / 等待人工输入 / 等待外部依赖] |

---

## 阶段完成状态

| 阶段 | 状态 | 完成时间 | 备注 |
|------|------|----------|------|
| Phase 01: 基线准备 | [未开始 / 进行中 / 已完成] | YYYY-MM-DD | |
| Phase 02: 工程分析 | [未开始 / 进行中 / 已完成] | YYYY-MM-DD | |
| Phase 03: 优先级排序 | [未开始 / 进行中 / 已完成] | YYYY-MM-DD | |
| Phase 04: 迭代循环 | [未开始 / 进行中 / 已完成] | YYYY-MM-DD | |

---

## 当前任务上下文

### 正在处理的模块（如有）

| 属性 | 值 |
|------|-----|
| 模块名称 | <module_name> |
| 模块路径 | <module_path> |
| 评估状态 | [S1 / S2 / S3 / S4 / 待评估] |
| 当前Skill | <skill_name> |
| Skill进度 | <当前任务描述> |

### 待处理事项

1. [ ] <具体待办项1>
2. [ ] <具体待办项2>

### 阻塞问题（如有）

| 问题 | 类型 | 等待 | 预计解除 |
|------|------|------|----------|
| <问题描述> | [人工输入 / 外部依赖 / 技术问题] | <等待什么> | <预计时间> |

---

## 关键文档索引

| 文档 | 路径 | 状态 |
|------|------|------|
| 模块地图 | docs/architecture/module_map.md | [不存在 / 进行中 / 已完成] |
| 构建入口 | docs/build/build_entrypoints.md | [不存在 / 进行中 / 已完成] |
| 测试待办 | docs/testing/backlog.md | [不存在 / 进行中 / 已完成] |
| 静态分析报告 | docs/analysis/static_analysis_report.md | [不存在 / 进行中 / 已完成] |

---

## 最近操作日志

| 时间 | 操作 | 结果 | 备注 |
|------|------|------|------|
| YYYY-MM-DD HH:MM | <操作描述> | [成功 / 失败 / 中断] | <备注> |
| YYYY-MM-DD HH:MM | <操作描述> | [成功 / 失败 / 中断] | <备注> |

---

## 恢复指引

### 如何从此状态恢复

1. 阅读"当前状态"确定所处阶段和Skill
2. 阅读"当前任务上下文"了解具体进度
3. 检查"阻塞问题"是否已解除
4. 根据"待处理事项"继续执行
5. 如有疑问，参考"最近操作日志"了解上下文

### 快速恢复命令

```bash
# 检查门禁状态
./tools/test.sh && echo "G0: 绿灯" || echo "非G0: 需要检查"

# 查看当前模块状态
cat docs/testing/modules/<current_module>.md

# 查看Backlog进度
grep -E "Doing|Blocked" docs/testing/backlog.md
```
```

---

## 状态更新时机

### 必须更新状态的时机

| 时机 | 更新内容 |
|------|----------|
| 阶段开始 | 当前阶段、开始时间 |
| 阶段完成 | 阶段状态、完成时间 |
| Skill开始 | 当前Skill、当前模块 |
| Skill完成 | Skill进度、待处理事项 |
| 门禁运行后 | 门禁状态、操作日志 |
| 遇到阻塞 | 阻塞状态、阻塞问题 |
| 阻塞解除 | 阻塞状态、操作日志 |
| 任务中断前 | 所有相关状态、恢复指引 |

### 状态更新命令

```bash
#!/bin/bash
# tools/update_session_state.sh

STATE_FILE="docs/testing/.session_state.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# 更新最后更新时间
sed -i "s/> 最后更新:.*/> 最后更新: $TIMESTAMP/" "$STATE_FILE"

echo "Session state updated at $TIMESTAMP"
```

---

## 检查点机制

### 自动检查点

在以下时刻自动创建检查点：

1. **阶段完成时**：创建 `docs/testing/checkpoints/phase_XX_complete.md`
2. **模块完成时**：更新模块卡片并记录到Backlog
3. **门禁通过时**：记录到操作日志

### 检查点目录结构

```
docs/testing/
├── .session_state.md          # 主状态文件
├── checkpoints/                # 检查点目录
│   ├── phase_01_complete.md
│   ├── phase_02_complete.md
│   ├── phase_03_complete.md
│   └── iteration_snapshots/    # 迭代快照
│       ├── module_001_done.md
│       ├── module_002_done.md
│       └── ...
├── backlog.md                  # 待办队列
└── modules/                    # 模块卡片
    ├── module_a.md
    ├── module_b.md
    └── ...
```

---

## 恢复场景处理

### 场景1：阶段中途中断

**恢复步骤**：
1. 读取 `.session_state.md` 确定当前阶段
2. 读取对应阶段文档确定验收标准
3. 检查已完成的验收项
4. 从未完成的验收项继续

### 场景2：Skill执行中中断

**恢复步骤**：
1. 读取 `.session_state.md` 确定当前Skill和模块
2. 读取模块卡片了解评估状态
3. 读取对应Skill文档确定任务列表
4. 根据"Skill进度"从中断点继续

### 场景3：门禁失败后中断

**恢复步骤**：
1. 读取 `.session_state.md` 确定门禁状态
2. 运行门禁确认当前状态
3. 根据门禁状态进入对应决策流程
4. 按决策流程继续处理

### 场景4：等待人工输入时中断

**恢复步骤**：
1. 读取 `.session_state.md` 确定阻塞问题
2. 检查 `docs/decisions/<module>_clarifications.md` 是否有答案
3. 如有答案，根据答案继续
4. 如无答案，重新发起问询

---

**下一步**：返回调用此文档的位置继续执行
