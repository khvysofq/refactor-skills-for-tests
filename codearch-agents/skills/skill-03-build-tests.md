# Skill 03: 构建与测试体系

> **触发条件**：Phase 03 指示（入口决策 Q3 为「否」）  
> **目标**：梳理编译系统、单元测试体系及测试运行方式，并文档化

---

## 输入

- 待分析的 C/C++ 工程
- 构建脚本与配置文件（CMakeLists.txt、Makefile、BUILD、configure 等）

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 构建与测试文档 | `docs/codearch/build_and_tests.md` | ✓ |

内容需覆盖：编译系统说明、主要构建命令、是否存在单元测试体系、如何运行测试（命令、环境、可选过滤）。

---

## 核心任务

### 任务 1: 梳理编译系统

**目标**：识别构建系统类型与主入口，文档化常用命令

**步骤**：

1. 识别构建系统：CMake、Bazel、Make、Autotools、自定义脚本等
2. 定位主入口（顶层 CMakeLists.txt、Makefile、WORKSPACE、configure）
3. 列出主要 target：可执行文件、静态库/动态库、测试 target
4. 记录常用构建命令（如 `cmake -B build && cmake --build build`、`make -j`、`bazel build //...`）
5. 如有多种配置（Debug/Release、平台），简要说明

**分析命令参考**：

```bash
ls -la CMakeLists.txt Makefile BUILD WORKSPACE 2>/dev/null
grep -r "add_executable\|add_library\|add_test" . --include="CMakeLists.txt" | head -40
```

### 任务 2: 判断单元测试体系

**目标**：确认是否存在单元测试及所用框架

**步骤**：

1. 查找测试目录（tests/、test/、*_test、unittests/ 等）
2. 识别测试框架（Google Test、Catch2、Check、自定义 runner）
3. 在文档中写明：是否有单元测试、框架名称、测试代码位置与命名约定

**分析命令参考**：

```bash
find . -type d -name "test*" -o -type d -name "*test" 2>/dev/null
grep -rn "gtest\|TEST(\|Catch\|CHECK\|assert" . --include="*.cpp" --include="*.c" | head -20
```

### 任务 3: 文档化测试运行方式

**目标**：写出如何运行全部测试、如何按 target/过滤运行

**步骤**：

1. 列出运行测试的命令（如 `ctest`、`make test`、`bazel test //...`、`./tools/test.sh`）
2. 说明是否需要先构建、是否需要特定环境或数据
3. 如有过滤方式（按 suite、按名、按标签），简要说明
4. 在文档中提供可直接复制执行的命令示例

---

## 输出格式示例

```markdown
# 构建与测试说明

## 编译系统

- **类型**: CMake
- **主入口**: 顶层 `CMakeLists.txt`
- **常用命令**:
  ```bash
  mkdir -p build && cd build
  cmake ..
  cmake --build . -j
  ```
- **主要 target**: 可执行文件 `app_main`，库 `libcore.a`，测试 `unit_tests`

## 单元测试体系

- **是否存在**: 是
- **框架**: Google Test
- **位置**: `tests/`，`*_test.cpp`

## 运行测试

```bash
cd build && ctest -V
# 或
./unit_tests --gtest_filter="*"
```
```

---

## 验收标准

### 必须满足

- [ ] `docs/codearch/build_and_tests.md` 存在
- [ ] 文档包含「编译系统」或等价节，且含至少一条构建命令
- [ ] 文档包含「单元测试」或「运行测试」说明（有则写命令，无则写明「当前无单元测试」）
- [ ] 文档中所列构建/测试命令在工程中可执行（建议执行一次验证返回码）

### 验收检查

```bash
[ -f docs/codearch/build_and_tests.md ] && echo "PASS" || echo "FAIL"
grep -q "编译\|构建\|build\|cmake\|make" docs/codearch/build_and_tests.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 以可执行命令为主，便于后续 Agent 或人工复现
- 无单元测试时明确写出「当前无单元测试体系」

## 不应该做

- 不臆造不存在的 target 或命令
- 不省略环境或前置步骤（若运行测试依赖先 build，需写明）

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 03](../phases/03-build-and-tests.md) 完成阶段验收，然后进入 Phase 04 或结束 |
| 未通过 | 补全文档并重新验收 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型 | 20–40 分钟 |
| 中型 | 40–90 分钟 |
| 大型 | 1–2 小时 |

---

**完成后**：返回 [Phase 03](../phases/03-build-and-tests.md) 进行阶段验收
