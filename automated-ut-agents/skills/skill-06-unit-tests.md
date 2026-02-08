# Skill 06: 直接单测覆盖

> **触发条件**：Skill 04 评估结果为 S1  
> **目标**：对已具备可测条件的模块快速建立 L1 单测

---

## 输入

- Skill 04 产出的模块卡片
- 评估状态为 S1 的模块

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 单元测试 | `tests/unit/<module>_test.*` | ✓ |

---

## 核心任务

### 任务 1: 划分被测单元

**目标**：识别模块中可独立测试的单元

**优先级排序**：

| 优先级 | 单元类型 |
|--------|----------|
| 1 | 纯函数（无副作用、无状态） |
| 2 | 数据转换方法 |
| 3 | 计算/算法逻辑 |
| 4 | 解析/序列化函数 |
| 5 | 状态机转换 |
| 6 | 工具/辅助函数 |

**识别方法**：

```cpp
// 纯函数 - 优先测试
int calculate(int a, int b);
std::string format(const Data& data);

// 类方法 - 按复杂度排序
class Parser {
    Result parse(const std::string& input);  // 核心，优先
    bool validate(const Result& r);          // 验证，次优先
    void reset();                            // 简单，低优先
};
```

### 任务 2: 设计测试用例

**目标**：覆盖核心功能和边界条件

**用例设计模板**：

对于每个被测单元：

| 类别 | 覆盖内容 |
|------|----------|
| 正常路径 | 典型输入 → 预期输出、多个典型场景 |
| 边界条件 | 空输入/null/零值、最大值/最小值、刚好在边界/刚好越界 |
| 错误路径 | 无效输入、异常情况、资源不足 |
| 特殊情况 | 并发安全、性能边界（如适用） |

**示例**：

```cpp
// 被测函数：int divide(int a, int b);

// 正常路径
TEST(Divide, PositiveNumbers) {
    EXPECT_EQ(divide(10, 2), 5);
    EXPECT_EQ(divide(9, 3), 3);
}

// 边界条件
TEST(Divide, ZeroDividend) {
    EXPECT_EQ(divide(0, 5), 0);
}

TEST(Divide, DivideByOne) {
    EXPECT_EQ(divide(42, 1), 42);
}

// 错误路径
TEST(Divide, DivideByZero) {
    EXPECT_THROW(divide(10, 0), std::invalid_argument);
}

// 特殊情况
TEST(Divide, NegativeNumbers) {
    EXPECT_EQ(divide(-10, 2), -5);
    EXPECT_EQ(divide(10, -2), -5);
    EXPECT_EQ(divide(-10, -2), 5);
}
```

### 任务 3: 引入测试替身

**目标**：为有依赖的单元创建 fake/mock

**替身类型选择**：

| 类型 | 适用场景 | 示例 |
|------|----------|------|
| Stub | 提供固定返回值 | 配置读取 |
| Fake | 简化实现 | 内存数据库 |
| Mock | 验证交互 | 日志记录器 |
| Spy | 记录调用 | 事件发布 |

**原则**：

1. 优先使用 Fake 而非 Mock
2. Mock 只用于验证重要交互
3. 避免过度 Mock（测试实现而非行为）

**示例**：

```cpp
// 接口
class ILogger {
public:
    virtual void log(const std::string& msg) = 0;
};

// Fake 实现
class FakeLogger : public ILogger {
public:
    void log(const std::string& msg) override {
        messages.push_back(msg);
    }
    std::vector<std::string> messages;
};

// 测试使用
TEST(Service, LogsOnError) {
    FakeLogger logger;
    Service service(&logger);
    
    service.processInvalidInput();
    
    ASSERT_EQ(logger.messages.size(), 1);
    EXPECT_THAT(logger.messages[0], HasSubstr("error"));
}
```

### 任务 4: 补齐覆盖

**目标**：达到覆盖率门槛

**覆盖策略**：

1. 先覆盖主要路径（happy path）
2. 再覆盖错误路径
3. 最后补齐边界条件
4. 使用覆盖率工具指导

**覆盖率检查**：

```bash
# 运行带覆盖率的测试
# CMake + gcov
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage" ..
make
./run_tests
gcov <source_file>.cpp

# 或使用 lcov
lcov --capture --directory . --output-file coverage.info
lcov --remove coverage.info '/usr/*' --output-file coverage.info
genhtml coverage.info --output-directory coverage_html
```

---

## 输出格式

### 测试文件结构

```cpp
// tests/unit/<module>_test.cpp

#include <gtest/gtest.h>
#include "<module>.h"
#include "fakes/<module>_fakes.h"  // 如需要

//==============================================================================
// 测试夹具（如需要）
//==============================================================================
class ModuleTest : public ::testing::Test {
protected:
    void SetUp() override {
        // 初始化
    }
    
    void TearDown() override {
        // 清理
    }
    
    // 辅助方法
    // 共享 fake/mock
};

//==============================================================================
// FunctionA 测试
//==============================================================================
TEST_F(ModuleTest, FunctionA_NormalCase) {
    // Arrange
    auto input = ...;
    
    // Act
    auto result = module.functionA(input);
    
    // Assert
    EXPECT_EQ(result, expected);
}

TEST_F(ModuleTest, FunctionA_BoundaryEmpty) { ... }
TEST_F(ModuleTest, FunctionA_ErrorCase) { ... }

//==============================================================================
// FunctionB 测试
//==============================================================================
TEST_F(ModuleTest, FunctionB_NormalCase) { ... }
// ...
```

---

## 验收标准

### 必须满足

- [ ] 测试文件存在
- [ ] 核心功能路径有测试覆盖
- [ ] 关键边界条件有测试
- [ ] 所有测试通过
- [ ] 覆盖率达到门槛（建议 ≥70%）

### 验收检查

```bash
# 文件存在
ls tests/unit/*<module>* && echo "PASS" || echo "FAIL"

# 测试通过
./run_tests --gtest_filter="*<Module>*" && echo "PASS" || echo "FAIL"

# 覆盖率检查
# 查看覆盖率报告，确认达到门槛
```

---

## 应该做

- ✓ 从简单函数开始
- ✓ 使用 AAA 模式（Arrange-Act-Assert）
- ✓ 测试名称描述场景
- ✓ 保持测试独立性

## 不应该做

- ✗ 过度 Mock（测试实现细节）
- ✗ 测试之间相互依赖
- ✗ 在测试中使用 sleep
- ✗ 追求 100% 覆盖率（边际效益递减）

---

## 测试命名规范

```
格式：MethodName_StateOrInput_ExpectedBehavior

示例：
- Parse_ValidJson_ReturnsObject
- Parse_EmptyString_ReturnsNull
- Parse_InvalidJson_ThrowsException
- Calculate_OverflowInput_ClampToMax
```

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | [Skill 08: 小步重构](skill-08-refactor.md) |
| 未通过 - 依赖无法替换 | 重新评估，可能需要 Skill 07 |
| 未通过 - 覆盖率不足 | 补充用例 |
| 未通过 - 测试失败 | 检查是否发现 bug |

---

## 时间预估

| 模块复杂度 | 预估时间 |
|------------|----------|
| 简单（<10 个函数） | 1 - 2 小时 |
| 中等（10-30 个函数） | 2 - 4 小时 |
| 复杂（>30 个函数） | 4 - 8 小时 |

---

**完成后**：进入 [Skill 08: 小步重构](skill-08-refactor.md)
