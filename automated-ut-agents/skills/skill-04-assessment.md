# Skill 04: 模块可测试性评估

> **触发条件**：Phase 04 迭代循环中选择模块后  
> **目标**：对单个模块做执行前判定，确定走哪条路径

---

## 输入

- 从 Backlog 选择的模块名称
- 模块地图中的基本信息

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 模块卡片 | `docs/testing/modules/<module>.md` | ✓ |
| 评估状态 | S1 / S2 / S3 / S4 | ✓ |

---

## 核心任务

### 任务 1: 识别外部依赖

**目标**：完整列出模块的所有外部依赖

**检查清单**：

| 依赖类型 | 检查方法 | 示例 |
|----------|----------|------|
| 文件系统 | 搜索 fopen/fread/open/read | 配置读取、日志写入 |
| 网络 | 搜索 socket/connect/curl | HTTP 请求、TCP 连接 |
| 时间 | 搜索 time/clock/sleep | 超时、定时器 |
| 随机数 | 搜索 rand/random | ID 生成、采样 |
| 线程 | 搜索 thread/mutex/lock | 并发处理 |
| 全局状态 | 搜索 static/extern/singleton | 配置、缓存 |
| 硬件 SDK | 搜索特定 API | 设备驱动 |
| 数据库 | 搜索 sql/query/connection | 持久化 |

**执行命令**：

```bash
MODULE_PATH="<module_path>"

echo "=== 文件系统依赖 ==="
grep -rn "fopen\|fread\|fwrite\|open\|read\|write\|ifstream\|ofstream" $MODULE_PATH

echo "=== 网络依赖 ==="
grep -rn "socket\|connect\|send\|recv\|curl\|http" $MODULE_PATH

echo "=== 时间依赖 ==="
grep -rn "time\|clock\|sleep\|usleep\|chrono" $MODULE_PATH

echo "=== 随机数依赖 ==="
grep -rn "rand\|random\|mt19937\|uniform" $MODULE_PATH

echo "=== 线程依赖 ==="
grep -rn "thread\|mutex\|lock\|atomic\|pthread" $MODULE_PATH

echo "=== 全局状态 ==="
grep -rn "^static \|extern \|::instance\|Singleton" $MODULE_PATH
```

### 任务 2: 识别 Seam 候选点

**目标**：找出可以注入测试替身的位置

**候选类型**：

| 类型 | 特征 | 可测性 |
|------|------|--------|
| 接口/抽象类 | 虚函数、纯虚函数 | ✓ 高 |
| 函数指针 | 回调、策略 | ✓ 高 |
| 模板参数 | 策略模式模板 | ✓ 高 |
| 构造参数 | 依赖注入 | ✓ 高 |
| 工厂函数 | 创建点可替换 | ○ 中 |
| 配置项 | 运行时切换 | ○ 中 |
| 条件编译 | #ifdef TEST | △ 低 |

**检查方法**：

```bash
# 查找接口/抽象类
grep -rn "virtual\|= 0;" $MODULE_PATH

# 查找函数指针/回调
grep -rn "typedef.*(\*\|std::function\|callback" $MODULE_PATH

# 查找构造函数参数
grep -rn "explicit\|::" $MODULE_PATH | grep -E "\(.*&\)"

# 查找工厂
grep -rn "Create\|Make\|Build\|Factory" $MODULE_PATH
```

### 任务 3: 状态判定

**目标**：确定模块评估状态 S1/S2/S3/S4

**判定流程**：

按以下顺序回答问题，确定模块状态：

| 步骤 | 问题 | 否 | 是 |
|------|------|-----|-----|
| Q1 | 模块是否有外部依赖？ | **S1**（可直接单测） | 继续 Q2 |
| Q2 | 依赖是否已有 Seam？ | 继续 Q3 | **S1**（可直接单测，使用 mock/fake） |
| Q3 | 能否在模块边界做表征测试？ | 继续 Q5 | 继续 Q4 |
| Q4 | 行为是否确定性？ | **S3**（需先解耦/确定化） | **S2**（可表征） |
| Q5 | 业务语义是否清晰？ | **S4**（需人工判定） | **S3**（需先解耦） |

**判定总结**：
- 无依赖或已有 Seam → S1
- 有依赖、可表征、行为确定 → S2
- 有依赖、无法表征或行为不确定、业务清晰 → S3
- 业务语义不清晰 → S4

**状态定义速查**：

| 状态 | 特征 | 后续路径 |
|------|------|----------|
| S1 | 可直接写 L1 单测 | → Skill 06 |
| S2 | 可做表征测试锁行为 | → Skill 05 → Skill 07 |
| S3 | 需先引入 Seam 解耦 | → Skill 07 |
| S4 | 需人工判定业务语义 | → Skill 10 |

### 任务 4: 生成模块卡片

**目标**：记录评估结果

使用 [模块卡片模板](../templates/module-card.md)。

---

## 输出格式

### 模块卡片示例

```markdown
# 模块卡片: core/parser

> 评估日期: YYYY-MM-DD
> 评估状态: S2
> 测试策略: L1 + L2

## 基本信息

- **路径**: src/core/parser/
- **职责**: 解析配置文件和协议数据
- **边界**:
  - 输入: 原始字节流、配置文件路径
  - 输出: 解析后的数据结构

## 外部依赖

| 依赖 | 位置 | 用途 | 风险 |
|------|------|------|------|
| 文件系统 | config_loader.cpp:45 | 读取配置文件 | 中 |
| 时间 | timeout.cpp:23 | 超时检测 | 低 |

## Seam 候选点

| 位置 | 类型 | 说明 |
|------|------|------|
| Parser::Parser(IReader*) | 构造注入 | 已存在，可直接用 |
| get_current_time() | 全局函数 | 需要包装 |

## 评估结论

### 状态: S2（可表征）

**理由**:
1. 有明确的输入输出边界
2. 核心解析逻辑是确定性的
3. 文件系统依赖可通过表征测试覆盖

### 建议路径

1. Skill 05: 表征测试覆盖文件加载场景
2. Skill 07: 为时间依赖引入 Clock 接口
3. Skill 06: 单测覆盖解析逻辑
4. Skill 08: 重构内部实现

## 下一步

→ 执行 [Skill 05: 表征测试](../skills/skill-05-characterization.md)
```

---

## 验收标准

### 必须满足

- [ ] 模块卡片已创建
- [ ] 外部依赖完整列出
- [ ] Seam 候选点已识别
- [ ] 状态判定有明确理由
- [ ] 下一步路径清晰

### 验收检查

```bash
# 文档存在
[ -f "docs/testing/modules/<module>.md" ] && echo "PASS" || echo "FAIL"

# 状态明确
grep -q "状态: S[1-4]" "docs/testing/modules/<module>.md" && echo "PASS" || echo "FAIL"

# 下一步明确
grep -q "下一步\|Skill 0" "docs/testing/modules/<module>.md" && echo "PASS" || echo "FAIL"
```

---

## 应该做

- ✓ 深入阅读模块代码
- ✓ 实际运行依赖检测命令
- ✓ 保守判定状态（不确定时选更难的）
- ✓ 记录评估过程中发现的问题

## 不应该做

- ✗ 仅凭猜测判定状态
- ✗ 跳过依赖分析
- ✗ 忽略非确定性风险
- ✗ 遗漏全局状态依赖

---

## 状态跳转

评估完成后，根据状态选择下一步：

| 评估状态 | 下一步 Skill | 链接 |
|----------|--------------|------|
| S1 | 直接单测覆盖 | [Skill 06](skill-06-unit-tests.md) |
| S2 | 表征测试 | [Skill 05](skill-05-characterization.md) |
| S3 | 设计 Seam | [Skill 07](skill-07-seams.md) |
| S4 | 人工介入 | [Skill 10](skill-10-human-input.md) |

详细决策参考：[可测试性决策](../decisions/testability-decision.md)

---

## 时间预估

| 模块复杂度 | 预估时间 |
|------------|----------|
| 简单（<500 行） | 15 - 30 分钟 |
| 中等（500-2000 行） | 30 - 60 分钟 |
| 复杂（>2000 行） | 1 - 2 小时 |

---

**完成后**：根据评估状态跳转到对应 Skill
