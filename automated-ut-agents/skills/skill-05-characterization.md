# Skill 05: 表征测试 / Golden Master

> **触发条件**：Skill 04 评估结果为 S2  
> **目标**：在不理解全部业务语义时，先锁定"现状行为"，为后续重构提供护栏

---

## 输入

- Skill 04 产出的模块卡片
- 评估状态为 S2 的模块

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 表征测试 | `tests/characterization/<module>_golden_test.*` | ✓ |
| Golden 数据 | `tests/characterization/golden/<module>/` | ✓ |

---

## 核心任务

### 任务 1: 选择稳定输入集

**目标**：构建覆盖关键路径的测试输入

**选择原则**：

1. **典型路径优先**：最常见的使用场景、主要业务流程
2. **边界条件覆盖**：空输入、最大/最小值、特殊字符
3. **错误路径**：无效输入、超时/失败场景
4. **确定性优先**：避免依赖时间/随机数的输入，或先确定化这些依赖

**输入来源**：
- 现有单元测试（如果有）
- 集成测试数据
- 生产环境样本（脱敏）
- 手工构造的边界用例

### 任务 2: 建立边界测试

**目标**：在模块边界记录输入输出对应关系

**测试结构**：

```cpp
// tests/characterization/<module>_golden_test.cpp

#include <gtest/gtest.h>
#include "<module>.h"

class ModuleGoldenTest : public ::testing::Test {
protected:
    void SetUp() override {
        // 固定化非确定性依赖
        // 例如：设置固定时间、种子等
    }
};

TEST_F(ModuleGoldenTest, TypicalCase001) {
    // 输入
    auto input = LoadGoldenInput("typical_001.input");
    
    // 执行
    auto result = Module::Process(input);
    
    // 对比 Golden
    auto expected = LoadGoldenOutput("typical_001.expected");
    EXPECT_EQ(result, expected);
}

TEST_F(ModuleGoldenTest, BoundaryEmpty) {
    auto input = "";
    auto result = Module::Process(input);
    auto expected = LoadGoldenOutput("boundary_empty.expected");
    EXPECT_EQ(result, expected);
}

// 更多用例...
```

**Golden 数据管理**：

```
tests/characterization/golden/<module>/
├── typical_001.input
├── typical_001.expected
├── boundary_empty.expected
├── error_invalid.input
├── error_invalid.expected
└── ...
```

### 任务 3: 约束非确定性

**目标**：确保测试可重复

**常见非确定性来源与处理**：

| 来源 | 处理方法 |
|------|----------|
| 时间 | 注入固定时间或 Mock Clock |
| 随机数 | 设置固定种子 |
| 并发顺序 | 单线程执行或同步点 |
| 文件系统时间戳 | 忽略或 normalize |
| 浮点精度 | 使用 approx 比较 |
| 内存地址 | 过滤或 normalize |

**确定化示例**：

```cpp
// 固定时间
TEST_F(ModuleGoldenTest, WithFixedTime) {
    // 注入固定时间
    FakeClock clock(1609459200);  // 2021-01-01 00:00:00
    Module module(&clock);
    
    auto result = module.Process(input);
    // ...
}

// 固定随机种子
TEST_F(ModuleGoldenTest, WithFixedSeed) {
    std::srand(42);  // 或使用依赖注入的 RNG
    
    auto result = Module::Process(input);
    // ...
}
```

### 任务 4: 稳定性验证

**目标**：确保表征测试稳定

**验证方法**：

```bash
# 重复运行 20 次
for i in {1..20}; do
    ./run_tests --gtest_filter="*GoldenTest*"
    if [ $? -ne 0 ]; then
        echo "FAIL at iteration $i"
        exit 1
    fi
done
echo "PASS: 20 iterations completed"
```

**如果不稳定**：
- 检查是否有未控制的非确定性
- 如果无法解决 → 转 [Skill 12: 稳定性治理](skill-12-stability.md)

---

## 输出格式

### 表征测试文件结构

```
tests/
└── characterization/
    ├── <module>_golden_test.cpp
    └── golden/
        └── <module>/
            ├── Workflow.md.md          # 说明 golden 数据来源和更新方法
            ├── typical_001.input
            ├── typical_001.expected
            ├── typical_002.input
            ├── typical_002.expected
            ├── boundary_*.input
            ├── boundary_*.expected
            └── error_*.input/expected
```

### Golden Workflow.md 模板

```markdown
# Golden 数据说明

## 模块: <module>

## 数据来源
- typical_*: 从生产日志提取（脱敏）
- boundary_*: 手工构造
- error_*: 手工构造

## 更新方法
1. 确认行为变更是预期的
2. 运行: ./tools/update_golden.sh <module>
3. 检查 diff，确认变更合理
4. 提交新的 golden 文件

## 注意事项
- 时间相关输出已 normalize 为固定值
- 文件路径已替换为占位符
```

---

## 验收标准

### 必须满足

- [ ] 表征测试文件存在
- [ ] Golden 数据文件存在
- [ ] 覆盖至少 N 条关键路径（建议 N=10）
- [ ] 重复运行 20 次无波动

### 验收检查

```bash
# 文件存在
ls tests/characterization/*golden_test* && echo "PASS" || echo "FAIL"
ls tests/characterization/golden/<module>/ && echo "PASS" || echo "FAIL"

# 测试通过
./run_tests --gtest_filter="*GoldenTest*" && echo "PASS" || echo "FAIL"

# 稳定性
for i in {1..20}; do ./run_tests --gtest_filter="*GoldenTest*" || exit 1; done
echo "STABILITY: PASS"
```

---

## 应该做

- ✓ 优先覆盖主要业务路径
- ✓ 记录 Golden 数据来源
- ✓ 验证测试稳定性
- ✓ 建立 Golden 更新流程

## 不应该做

- ✗ 试图理解所有业务逻辑（表征测试目的是锁行为）
- ✗ 忽略非确定性问题
- ✗ 一次性覆盖所有边界（迭代补充）
- ✗ 手工维护 Golden 数据（应有脚本）

---

## 常见问题

### Q: Golden 数据太大怎么办？

**A**: 1. 使用 hash 比较而非全量比较 → 2. 只比较关键字段 → 3. 使用压缩存储

### Q: 输出包含无法控制的动态内容？

**A**: 1. 提取动态部分为单独断言 → 2. 使用正则匹配 → 3. normalize 处理（替换为占位符）

### Q: 没有现成的测试数据？

**A**: 1. 从日志/监控提取 → 2. 运行程序记录输入输出 → 3. 手工构造典型场景

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | [Skill 07: 设计 Seam](skill-07-seams.md) |
| 未通过 - 测试不稳定 | [Skill 12: 稳定性治理](skill-12-stability.md) |
| 未通过 - 覆盖不足 | 补充用例，重试 |
| 未通过 - 无法构造输入 | [Skill 10: 人工介入](skill-10-human-input.md) |

---

## 时间预估

| 模块复杂度 | 预估时间 |
|------------|----------|
| 简单 | 1 - 2 小时 |
| 中等 | 2 - 4 小时 |
| 复杂 | 4 - 8 小时 |

---

**完成后**：进入 [Skill 07: 设计 Seam](skill-07-seams.md)
