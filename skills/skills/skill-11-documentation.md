# Skill 11: 文档与模块卡片增量更新

> **触发条件**：模块处理完成，门禁通过（G0）  
> **目标**：保证后续任务"可接续"，工程认知随重构同步演进

---

## 输入

- 本次模块处理的所有变更
- 引入的 Seam 和测试

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 更新的模块卡片 | `docs/testing/modules/<module>.md` | ✓ |
| 更新的 Backlog | `docs/testing/backlog.md` | ✓ |
| 经验记录 | 模块卡片内或单独文档 | 推荐 |

---

## 核心任务

### 任务 1: 更新模块卡片

**更新内容清单**：

```markdown
□ 评估状态更新（从预估到实际）
□ 测试覆盖情况
  - 单元测试数量和覆盖率
  - 表征测试数量
□ 引入的 Seam
  - 接口定义位置
  - 测试替身位置
□ 依赖变化
  - 新增的接口依赖
  - 移除的直接依赖
□ 运行命令
  - 如何单独运行该模块的测试
□ 已知问题/遗留项
```

**更新示例**：

```markdown
# 模块卡片: core/parser

> 评估日期: 2024-01-15
> 最后更新: 2024-01-20
> 状态: ✅ 已完成

## 测试覆盖

### 单元测试
- 文件: `tests/unit/parser_test.cpp`
- 用例数: 25
- 行覆盖率: 85%
- 分支覆盖率: 72%

### 表征测试
- 文件: `tests/characterization/parser_golden_test.cpp`
- Golden 数据: `tests/characterization/golden/parser/`
- 场景数: 15

## 引入的 Seam

| 接口 | 位置 | 测试替身 |
|------|------|----------|
| IFileReader | include/interfaces/file_reader.h | tests/fakes/fake_file_reader.h |
| IClock | include/interfaces/clock.h | tests/fakes/fake_clock.h |

## 运行测试

```bash
# 单独运行 parser 模块测试
./run_tests --gtest_filter="*Parser*"

# 运行 parser 的表征测试
./run_tests --gtest_filter="*ParserGolden*"
```

## 经验记录

### 遇到的问题
1. 时间依赖导致表征测试不稳定，通过注入 FakeClock 解决
2. 配置文件路径硬编码，引入 IFileReader 接口解耦

### 可复用模式
- FakeClock 可被其他模块复用
- 配置加载的解耦模式可参考

### 遗留问题
- [ ] 错误处理路径覆盖不足（约 60%）
- [ ] 性能测试未覆盖
```

### 任务 2: 更新 Backlog 状态

**状态更新**：

```markdown
# 更新前
| 模块 | 预估状态 | 策略 | 评分 | 状态 | 备注 |
|------|----------|------|------|------|------|
| core/parser | S2 | L1+L2 | 20 | Doing | |

# 更新后
| 模块 | 预估状态 | 策略 | 评分 | 状态 | 备注 |
|------|----------|------|------|------|------|
| core/parser | S2→S1 | L1+L2 | 20 | Done | 覆盖率85%，引入2个Seam |
```

**状态值**：

| 状态 | 含义 |
|------|------|
| Todo | 待处理 |
| Doing | 处理中 |
| Done | 完成 |
| Blocked | 阻塞（需外部） |
| Skipped | 跳过（有理由） |

### 任务 3: 记录经验

**经验记录要点**：

| 类别 | 记录内容 |
|------|----------|
| 遇到的问题 | 问题描述、解决方法、耗时 |
| 可复用模式 | Seam 设计、测试技巧、脚本工具 |
| 遗留问题 | 未完成项、已知限制、后续建议 |
| 时间统计 | 评估耗时、测试编写耗时、重构耗时 |

### 任务 4: 检查文档一致性

**一致性检查清单**：

- [ ] 模块卡片的测试文件路径正确
- [ ] 运行命令可执行
- [ ] Backlog 状态准确
- [ ] 模块地图如有变化已更新
- [ ] 没有过时的信息

---

## 验收标准

### 必须满足

- [ ] 模块卡片已更新
- [ ] Backlog 状态已更新
- [ ] 文档与代码一致

### 验收检查

```bash
# 检查模块卡片存在
[ -f "docs/testing/modules/<module>.md" ] && echo "PASS" || echo "FAIL"

# 检查 Backlog 状态
grep "<module>.*Done" docs/testing/backlog.md && echo "PASS" || echo "FAIL"

# 检查测试可运行
./run_tests --gtest_filter="*<Module>*" && echo "PASS" || echo "FAIL"
```

---

## 应该做

- ✓ 立即更新（趁记忆清晰）
- ✓ 记录具体数据（覆盖率、用例数）
- ✓ 记录问题和解决方法
- ✓ 标注可复用的模式

## 不应该做

- ✗ 拖延更新
- ✗ 只更新状态不记录细节
- ✗ 遗漏重要的经验
- ✗ 文档与代码不一致

---

## 文档更新模板

### 快速更新脚本

```bash
#!/bin/bash
# tools/update_module_docs.sh

MODULE=$1
COVERAGE=$(./tools/get_coverage.sh $MODULE)
TEST_COUNT=$(./run_tests --gtest_filter="*${MODULE}*" --gtest_list_tests | wc -l)

echo "## 更新摘要 - ${MODULE}"
echo "- 测试用例数: ${TEST_COUNT}"
echo "- 覆盖率: ${COVERAGE}%"
echo "- 更新日期: $(date +%Y-%m-%d)"
```

---

## 状态跳转

文档更新完成后，返回 [Phase 04: 迭代循环](../phases/04-iteration.md)：

| 队列状态 | 下一步 |
|----------|--------|
| 队列不为空 | 选择下一个模块 |
| 队列为空 | 生成最终报告，结束 |

---

## 时间预估

| 内容 | 预估时间 |
|------|----------|
| 更新模块卡片 | 15 - 30 分钟 |
| 更新 Backlog | 5 分钟 |
| 记录经验 | 10 - 20 分钟 |

---

**完成后**：返回 [Phase 04: 迭代循环](../phases/04-iteration.md) 继续处理下一个模块
