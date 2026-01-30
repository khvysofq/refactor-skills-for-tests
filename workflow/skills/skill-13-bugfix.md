# Skill 13: 缺陷修复（先红后绿）

> **触发条件**：Skill 09 判定为真实 Bug  
> **目标**：通过 TDD 方式修复缺陷，确保有回归测试覆盖

---

## 输入

- Skill 09 的差异分析报告
- 确认为 Bug 的行为

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 失败测试（红灯） | `tests/` | ✓ |
| Bug 修复 | 源代码 | ✓ |
| 通过测试（绿灯） | `tests/` | ✓ |

---

## 核心原则

### 先红后绿

1. **先写一个失败的测试（红灯）**：测试描述期望的正确行为，当前代码应该让这个测试失败
2. **修复代码（绿灯）**：最小改动修复问题，测试变为通过
3. **确保不引入新问题**：所有其他测试仍然通过，行为变化是预期的

### 为什么要先红后绿？

- 确认测试确实能检测到 bug
- 防止写出总是通过的测试
- 建立对修复的信心
- 创建可靠的回归防护

---

## 核心任务

### 任务 1: 理解 Bug

**信息收集**：

| 来源 | 收集内容 |
|------|----------|
| Skill 09 报告 | 错误行为描述、正确行为应该是什么、相关代码位置 |
| 确认理解 | 复现 bug 的步骤、触发条件、影响范围 |

**Bug 描述模板**：

```markdown
## Bug 描述

### 现象
<当前的错误行为>

### 期望
<正确的行为应该是>

### 复现步骤
1. ...
2. ...
3. ...

### 触发条件
<什么情况下会触发>

### 影响
<这个 bug 会造成什么问题>
```

### 任务 2: 写失败测试（红灯）

**测试设计**：

```cpp
// tests/unit/<module>_test.cpp 或 tests/regression/<module>_regression_test.cpp

// 测试命名：描述期望的正确行为
TEST(Module, ShouldReturnZeroWhenInputIsEmpty) {  // 期望行为
    // Arrange
    Module module;
    
    // Act
    int result = module.process("");
    
    // Assert - 这是正确的期望值
    EXPECT_EQ(result, 0);  // 当前代码可能返回其他值，测试会失败
}

// 更复杂的 bug 可能需要多个测试
TEST(Module, ShouldNotCrashWhenInputIsNull) {
    Module module;
    EXPECT_NO_THROW(module.process(nullptr));
}

TEST(Module, ShouldHandleNegativeNumbers) {
    Module module;
    EXPECT_EQ(module.calculate(-5), -10);  // 正确行为
}
```

**验证红灯**：

```bash
# 运行新测试，确认失败
./run_tests --gtest_filter="*ShouldReturnZeroWhenInputIsEmpty*"

# 应该看到失败输出
# [ FAILED ] Module.ShouldReturnZeroWhenInputIsEmpty
```

**如果测试意外通过**：
- 检查测试是否正确描述了 bug
- 可能 bug 已被其他改动修复
- 可能对 bug 理解有误

### 任务 3: 修复代码（绿灯）

**修复原则**：

| 原则 | 要点 |
|------|------|
| 最小改动 | 只修复 bug，不做额外重构；保持代码风格一致 |
| 专注于根因 | 不要只修复症状；找到真正的问题根源 |
| 考虑边界影响 | 修复是否会影响其他场景；是否需要额外测试覆盖 |

**修复示例**：

```cpp
// 修复前
int Module::process(const std::string& input) {
    return input.length();  // Bug: 空字符串应该返回 0，但返回 size_t 可能有问题
}

// 修复后
int Module::process(const std::string& input) {
    if (input.empty()) {
        return 0;  // 显式处理空输入
    }
    return static_cast<int>(input.length());
}
```

**验证绿灯**：

```bash
# 运行新测试，确认通过
./run_tests --gtest_filter="*ShouldReturnZeroWhenInputIsEmpty*"

# 应该看到通过输出
# [ OK ] Module.ShouldReturnZeroWhenInputIsEmpty
```

### 任务 4: 验证完整性

**检查所有测试**：

```bash
# 运行完整测试套件
./tools/test.sh

# 确认：
# 1. 新测试通过
# 2. 所有其他测试仍然通过
# 3. 没有引入新的行为漂移
```

**如果其他测试失败**：

1. **分析失败原因**：修复是否影响了预期行为？测试是否过度约束？
2. **判断处理方式**：

| 情况 | 处理方式 |
|------|----------|
| 修复引入了正确的行为变更 | 更新相关测试 |
| 修复引入了新 bug | 调整修复方案 |
| 测试过度约束 | 调整测试 |

### 任务 5: 提交修复

**提交内容**：

1. 失败测试（可以和修复在同一提交，或单独先提交）
2. Bug 修复代码
3. 更新的文档（如需要）

**提交消息格式**：

```
fix(<module>): <简短描述>

问题：<bug 描述>
原因：<根因分析>
修复：<修复方法>

添加回归测试：test_xxx

Fixes #<issue-number>  (如有)
```

---

## Bug 修复检查清单

```markdown
## Bug 修复检查清单

- [ ] Bug 理解
  - [ ] 能复现 bug
  - [ ] 理解期望行为

- [ ] 测试先行
  - [ ] 写了失败测试
  - [ ] 测试确实因为 bug 而失败

- [ ] 修复代码
  - [ ] 最小改动
  - [ ] 针对根因

- [ ] 验证
  - [ ] 新测试通过
  - [ ] 其他测试通过
  - [ ] 门禁通过

- [ ] 提交
  - [ ] 提交消息清晰
  - [ ] 包含测试
```

---

## 验收标准

### 必须满足

- [ ] 有针对 bug 的回归测试
- [ ] 测试在修复前失败
- [ ] 测试在修复后通过
- [ ] 所有其他测试仍通过
- [ ] 门禁通过

### 验收检查

```bash
# 完整门禁
./tools/test.sh && echo "PASS" || echo "FAIL"

# 确认回归测试存在
grep -r "Regression\|ShouldNot\|Bug" tests/ | head -5
```

---

## 应该做

- ✓ 先写失败测试再修复
- ✓ 最小改动原则
- ✓ 清晰的提交消息
- ✓ 记录 bug 信息供未来参考

## 不应该做

- ✗ 不写测试直接修复
- ✗ 大规模重构同时修复
- ✗ 忽略对其他测试的影响
- ✗ 只修复症状不修复根因

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Skill 08: 小步重构](skill-08-refactor.md) 或 [Skill 11: 文档更新](skill-11-documentation.md) |
| 未通过 - 修复引入新问题 | 调整修复方案 |
| 未通过 - 其他测试失败 | 可能是行为漂移 → Skill 09 |
| 未通过 - 无法确定正确行为 | Skill 10 |

---

## 时间预估

| Bug 复杂度 | 预估时间 |
|------------|----------|
| 简单（明确的边界问题） | 30 分钟 - 1 小时 |
| 中等（需要理解上下文） | 1 - 2 小时 |
| 复杂（涉及多处改动） | 2 - 4 小时 |

---

**完成后**：返回 [Skill 08](skill-08-refactor.md) 继续重构流程，或进入 [Skill 11](skill-11-documentation.md) 更新文档
