# Skill 01: 工程基线与门禁准备

> **触发条件**：Phase 01 指示  
> **目标**：建立"最小可编译 + 可运行测试 + 本地门禁"基线

---

## 输入

- 仓库代码
- 构建系统信息（CMake / Bazel / Make / 其他）

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 测试目录结构 | `tests/` | ✓ |
| 门禁脚本 | `tools/test.sh` 或等效 | ✓ |
| 编译数据库 | `compile_commands.json` | 推荐 |
| CI 配置 | `.github/workflows/` 等 | 可选 |

---

## 核心任务

### 任务 1: 建立最小构建路径

**目标**：选定核心 target 能稳定编译

**步骤**：

1. **识别构建系统类型**：
   - CMake: 查找 CMakeLists.txt
   - Bazel: 查找 BUILD / WORKSPACE
   - Make: 查找 Makefile
   - 其他: 查找构建脚本

2. **尝试构建**：
   - CMake: `mkdir build && cd build && cmake .. && make`
   - Bazel: `bazel build //...`
   - Make: `make`

3. **解决依赖问题**：
   - 缺失工具链: 安装编译器/工具
   - 缺失库: 安装系统库或配置第三方
   - 配置错误: 修复构建配置

4. **确认编译成功**：至少一个核心 target 能成功编译，记录编译命令

**验证**：

```bash
# 执行构建命令
<build_command>
echo $?  # 应该返回 0
```

### 任务 2: 生成编译数据库（推荐）

**目标**：生成 `compile_commands.json` 用于代码分析

**步骤**：

```
CMake:
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

Make (使用 bear):
  bear -- make

Bazel:
  bazel run @hedron_compile_commands//:refresh_all
```

**验证**：

```bash
ls compile_commands.json
head -20 compile_commands.json  # 应该是有效 JSON
```

### 任务 3: 引入测试骨架

**目标**：建立测试目录结构和运行器

**步骤**：

1. **创建测试目录**：`mkdir -p tests/unit tests/integration`
2. **选择测试框架**（使用项目已有的，或推荐）：
   - C++: Google Test / Catch2 / doctest
   - C: Unity / Check / CUnit
3. **创建最小示例测试**：`tests/unit/dummy_test.cpp`
4. **配置测试构建**：更新 CMakeLists.txt / BUILD / Makefile，添加测试 target
5. **确认测试可运行**

**最小示例测试（Google Test）**：

```cpp
// tests/unit/dummy_test.cpp
#include <gtest/gtest.h>

TEST(Dummy, AlwaysPass) {
    EXPECT_TRUE(true);
}
```

**验证**：

```bash
# 运行测试
<test_command>
echo $?  # 应该返回 0
```

### 任务 4: 定义门禁命令

**目标**：创建一键构建+测试脚本

**步骤**：

1. **创建门禁脚本**：`mkdir -p tools && touch tools/test.sh && chmod +x tools/test.sh`
2. **编写脚本内容**（见下方模板）
3. **验证脚本可重复执行**

**门禁脚本模板**：

```bash
#!/bin/bash
set -e

echo "=== Build Gate ==="
<build_command>

echo "=== Test Gate ==="
<test_command>

echo "=== All gates passed ==="
```

**验证**：

```bash
./tools/test.sh
./tools/test.sh  # 执行两次，确认结果一致
```

---

## 验收标准

### 必须满足

- [ ] 核心 target 编译成功
- [ ] `tests/` 目录存在
- [ ] 测试运行器能执行并返回 0
- [ ] 门禁命令可重复执行且结果一致

### 验收检查命令

```bash
# 1. 构建检查
<build_command> && echo "BUILD: PASS" || echo "BUILD: FAIL"

# 2. 测试目录检查
[ -d tests ] && echo "TESTS DIR: PASS" || echo "TESTS DIR: FAIL"

# 3. 测试运行检查
<test_command> && echo "TEST RUN: PASS" || echo "TEST RUN: FAIL"

# 4. 门禁重复性检查
./tools/test.sh && ./tools/test.sh && echo "GATE: PASS" || echo "GATE: FAIL"
```

---

## 应该做

- ✓ 使用项目现有的构建系统
- ✓ 使用项目现有的测试框架（如果有）
- ✓ 保持最小改动原则
- ✓ 记录所有安装的依赖
- ✓ 确保脚本可在干净环境重现

## 不应该做

- ✗ 强制更换构建系统
- ✗ 强制更换测试框架
- ✗ 引入不必要的复杂性
- ✗ 跳过验证直接声明完成

---

## 常见问题处理

### 构建依赖缺失

**症状**：编译报错缺少头文件/库

**处理**：1. 识别缺失的依赖 → 2. 通过包管理器安装（apt/yum/brew）或配置第三方库路径 → 3. 重新构建

### 测试框架不存在

**症状**：项目无现有测试框架

**处理**：1. 选择轻量级框架（推荐 Google Test 或 Catch2） → 2. 作为子模块或系统包引入 → 3. 最小配置集成

### 平台差异

**症状**：构建命令在不同平台不一致

**处理**：1. 在门禁脚本中检测平台 → 2. 使用条件分支或使用跨平台构建系统（CMake）

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 01](../phases/01-setup.md) 完成验收，然后进入 [Phase 02](../phases/02-analysis.md) |
| 未通过 - 构建失败 | 修复构建问题，重试任务 1 |
| 未通过 - 测试框架问题 | 修复测试配置，重试任务 3 |
| 未通过 - 门禁不稳定 | 检查脚本，重试任务 4 |

---

## 时间预估

| 情况 | 预估时间 |
|------|----------|
| 构建系统完善 | 30 分钟 - 1 小时 |
| 需要修复构建 | 2 - 4 小时 |
| 需要引入测试框架 | 1 - 2 小时 |

---

**完成后**：返回 [Phase 01](../phases/01-setup.md) 进行阶段验收
