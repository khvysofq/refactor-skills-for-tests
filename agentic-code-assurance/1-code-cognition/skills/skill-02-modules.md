# Skill 02: 模块与依赖分析（含复杂度与验证）

> **触发条件**：Phase 02 指示（入口决策 Q2 为「否」）  
> **目标**：识别模块、梳理依赖、为每个模块撰写独立报告（含使用示例）、给出复杂度评级，并对高复杂度模块进行验证

---

## 输入

- 通过 Phase 01 的工程（已有总体报告概览和信息来源汇总）
- 代码目录与构建配置
- Phase 01 发现的示例目录、测试目录位置

---

## 输出

| 产出                       | 路径                                     | 必须 |
| -------------------------- | ---------------------------------------- | ---- |
| 模块报告（每模块一份）     | `docs/codearch/modules/<module_name>.md` | ✓    |
| 总体报告中的模块列表与链接 | `docs/codearch/overall_report.md`        | ✓    |
| 模块地图（可选）           | `docs/codearch/module_map.md`            | 可选 |

撰写时遵循 [产出结构约定](1-code-cognition/definitions/output_structure.md)。进行复杂度评级时查阅 [复杂度等级定义](1-code-cognition/definitions/complexity_levels.md)。进行模块验证时查阅 [验证等级定义](1-code-cognition/definitions/validation_levels.md)。

---

## 核心任务

**执行顺序**：首轮执行 Task 1 → 1.5 → 2 → 2.1 → 2.5（条件） → 3 → 4 → 5；修正轮由分解审视驱动，可只执行 Task 2–4 中受影响的模块、Task 4（更新总报告）与 Task 5。

### 任务 1: 识别模块

**目标**：列出所有主要模块

**步骤**：

1. 分析目录结构（常见：一目录一模块）
2. 分析构建 target（`add_library` / `add_executable`、`cc_library` / `cc_binary`、Makefile target）
3. 为每个模块确定唯一标识（用于文件名，如 `core_utils`、`io_file`）
4. 记录模块路径与类型（库/服务/驱动/工具）

**分析命令参考**：

```bash
find . -type d -maxdepth 3 | grep -v '\./\.' | sort
grep -r "add_library\|add_executable" . --include="CMakeLists.txt"
grep -r "cc_library\|cc_binary" . --include="BUILD*"
```

模块边界与依赖分析时可按需查阅 [C/C++ 注意点](1-code-cognition/definitions/cpp_cpp_notes.md)。

### 任务 1.5: 模块文档扫描

**目标**：为每个模块收集已有的文档和测试信息，作为撰写报告的高质量信息源

**步骤**：

1. **扫描模块目录下的文档**

   - 检查模块目录下是否有 README.md、doc/、docs/ 子目录
   - 阅读模块自带的文档描述

2. **定位对应的测试文件**

   - 根据模块名在测试目录中查找对应测试文件
   - 记录测试文件路径

3. **提取测试用例名称**

   - 从测试文件中提取 TEST/TEST_F/TEST_CASE 等宏
   - 测试用例名称反映模块的功能边界

4. **查找使用示例**

   - 在 examples/、tutorials/ 目录中查找与模块相关的示例
   - 检查文档中是否有代码示例

5. **阅读头文件注释**
   - 检查主要头文件中的类/函数文档注释
   - 提取 @brief、@param、@return 等 Doxygen 注释

**分析命令参考**：

```bash
# 对每个模块执行（以 <module> 为例）
MODULE_PATH="src/<module>"
MODULE_NAME="<module>"

# 查找模块文档
find $MODULE_PATH -name "README*" -o -name "*.md" 2>/dev/null

# 查找对应测试文件
find test/ tests/ -iname "*${MODULE_NAME}*" 2>/dev/null
ls test/*${MODULE_NAME}*.cpp tests/*${MODULE_NAME}*.cpp 2>/dev/null

# 提取测试用例名称
grep -E "TEST\(|TEST_F\(|TEST_P\(" test/*${MODULE_NAME}*.cpp 2>/dev/null

# 查找示例代码
find examples/ tutorials/ -iname "*${MODULE_NAME}*" 2>/dev/null

# 查看头文件注释
head -100 ${MODULE_PATH}/*.h 2>/dev/null | grep -E "@brief|@file|/\*\*"
```

**产出**：为每个模块记录可用的信息源，供任务 2 填写模块报告时使用。

---

### 任务 2: 为每个模块撰写报告

**目标**：按 [模块报告模板](1-code-cognition/templates/module-report.md) 填写职责、边界、依赖、代码特征、信息来源、使用示例

**步骤**：

1. 为每个模块创建 `docs/codearch/modules/<module_name>.md`
2. 填写职责描述、输入/输出边界、内部依赖表、外部依赖表
3. 填写**关键设计要点**（建议 3–5 条：主要入口函数/类、核心数据结构、线程/并发假设、错误处理策略、扩展点等）
4. **填写「代码特征」**：执行任务 2.1 的扫描，填写内存管理、并发模型、I/O 操作、外部数据处理、错误处理各维度
5. **填写「关键代码位置索引」**：记录主要入口点和外部数据入口
6. 填写「与其它模块的关系」
7. **复杂度评级**：按 [complexity_levels](1-code-cognition/definitions/complexity_levels.md) 判定等级（低/中/高/极高）并写入报告，可选写一句依据
8. **填写「信息来源」**：记录分析所依据的信息源（任务 1.5 的产出）
9. **填写「使用示例」**：提供至少一个基本用法示例

#### 使用示例填写指导

**示例来源优先级**（按优先级从高到低）：

1. **官方示例目录**：`examples/`、`tutorials/`、`samples/`、`demo/` 中的示例代码
2. **单元测试中的典型用例**：测试文件中名为 `*Basic*`、`*Simple*`、`*Example*` 的测试
3. **集成测试中的使用场景**：展示完整使用流程的测试
4. **Agent 根据分析结果编写**：若无现有示例，可根据头文件和代码理解编写（需标注「Agent 编写」）

**提取命令参考**：

```bash
# 查找示例目录
find . -maxdepth 2 -type d -name "example*" -o -name "tutorial*" -o -name "sample*" -o -name "demo*" 2>/dev/null

# 从测试中提取典型用例（提取测试名及后续代码）
grep -A 30 "TEST.*Basic\|TEST.*Simple\|TEST.*Example" test/*<module>*.cpp 2>/dev/null

# 查找模块相关的示例文件
find examples/ tutorials/ -name "*<module>*" -type f 2>/dev/null
```

**示例格式要求**：

- 示例代码应可编译或接近可编译
- 标注示例来源（文件路径:行号 或「Agent 编写」）
- 包含必要的 include 语句
- 添加简要注释说明关键步骤

### 任务 2.1: 代码特征扫描

**目标**：为每个模块收集代码特征信息，填写模块报告的「代码特征」和「关键代码位置索引」章节

**步骤**：

1. **扫描内存管理特征**

   ```bash
   MODULE_PATH="src/<module>"

   # 检查手动内存管理
   grep -rn "malloc\|calloc\|realloc\|free" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   grep -rn "new \|delete \|new\[|delete\[" $MODULE_PATH --include="*.cpp" | head -5

   # 检查智能指针
   grep -rn "unique_ptr\|shared_ptr\|make_unique\|make_shared" $MODULE_PATH --include="*.cpp" | head -5
   ```

2. **扫描并发特征**

   ```bash
   # 检查线程相关
   grep -rn "pthread\|std::thread\|std::async" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5

   # 检查同步机制
   grep -rn "mutex\|atomic\|condition_variable\|semaphore" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   ```

3. **扫描 I/O 操作**

   ```bash
   # 文件 I/O
   grep -rn "fopen\|fclose\|fread\|fwrite\|open\|close\|read\|write" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   grep -rn "ifstream\|ofstream\|fstream" $MODULE_PATH --include="*.cpp" | head -5

   # 网络 I/O
   grep -rn "socket\|connect\|bind\|listen\|accept\|send\|recv" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   ```

4. **扫描外部数据处理**

   ```bash
   # 命令行参数
   grep -rn "argc\|argv\|getopt" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5

   # 环境变量
   grep -rn "getenv\|setenv" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   ```

5. **扫描错误处理**

   ```bash
   # 异常
   grep -rn "throw\|catch\|try" $MODULE_PATH --include="*.cpp" | head -5

   # 错误码
   grep -rn "errno\|perror\|strerror" $MODULE_PATH --include="*.c" --include="*.cpp" | head -5
   ```

6. **识别主要入口点**
   ```bash
   # 查找公开头文件中的主要函数/类
   grep -rn "^class \|^struct \|^[a-zA-Z_].*(" $MODULE_PATH/*.h 2>/dev/null | head -10
   ```

**产出**：为每个模块填写「代码特征」和「关键代码位置索引」章节。

**填写原则**：

- 只记录客观事实，不做风险判断
- 简洁版：每个维度只填写「是/否」和简要说明
- 若某特征不存在，填写「否」或「无」

---

### 任务 2.5: 模块验证（条件执行）

**触发条件**：模块复杂度为「高」或「极高」

**目标**：通过运行测试或编写探索性测试，验证对模块的理解是否正确

**前置检查**：

执行验证前，必须确认：

- [ ] Phase 03（构建与测试体系）已完成，或至少已知道如何构建和运行测试
- [ ] 构建环境可用（能够编译项目）
- [ ] 已识别模块对应的测试文件

**若前置条件不满足**：先跳转执行 [Phase 03](1-code-cognition/phases/03-build-and-tests.md)，完成后返回继续验证。

**步骤**：

1. **确定验证等级**

   - 参照 [验证等级定义](1-code-cognition/definitions/validation_levels.md)
   - 复杂度「高」→ L2（运行测试）
   - 复杂度「极高」或测试不足 → L3（探索性测试）

2. **L2: 运行测试验证**

   ```bash
   # 构建测试目标
   cmake --build build --target <module>_test

   # 运行模块相关测试
   ./build/test/<module>_test
   # 或使用过滤
   ./build/unit_tests --gtest_filter="*<Module>*"
   # 或使用 CTest
   ctest -R "<module>" -V
   ```

3. **L3: 探索性测试验证**

   - 从静态分析中提取 3–5 个待验证的关键假设
   - 编写简单测试验证每个假设
   - 执行测试并分析结果

4. **分析验证结果**

   - 记录测试通过/失败情况
   - 对比测试结果与静态分析的理解
   - 若有差异，修正模块报告中的相关描述

5. **更新模块报告**
   - 填写「验证状态」章节
   - 记录验证等级、方式、结果
   - 记录验证发现（确认/修正/新发现）

**产出**：每个高/极高复杂度模块的报告中包含完整的「验证状态」章节。

---

### 任务 3: 解析依赖方向

**目标**：建立模块间依赖关系，避免循环依赖遗漏

**步骤**：

1. 分析 include 与链接依赖（`#include`、`target_link_libraries` 等）
2. 在模块报告中写清「依赖谁 / 被谁依赖」
3. 可选：在 `module_map.md` 或总体报告中画 Mermaid 依赖图

**分析命令参考**：

```bash
grep -r "#include" src/ | sed 's/.*#include [<"]\(.*\)[>"]/\1/' | sort | uniq -c | sort -rn
grep -r "target_link_libraries" . --include="CMakeLists.txt"
```

### 任务 4: 更新总体报告中的模块列表与技术特征统计

**目标**：在 `docs/codearch/overall_report.md` 中更新「模块列表」和「技术特征概览」

**步骤**：

1. 打开或创建总体报告
2. 插入或更新模块列表表/列表，确保每项含路径/范围，链接为相对路径 `modules/<module_name>.md`
3. **更新「技术特征概览」的「技术特征统计」**：
   - 统计各技术特征涉及的模块数量
   - 列出涉及该特征的主要模块名称
   - 基于各模块报告的「代码特征」章节汇总

### 任务 5: 分解质量自检（分解审视）

**目标**：按 [分解审视约定](1-code-cognition/definitions/decomposition_review.md) 检查当前模块划分是否稳定、合理

**步骤**：

1. 阅读并执行 [decomposition_review](1-code-cognition/definitions/decomposition_review.md) 中的审视维度（checklist）：单一职责、边界清晰、粒度一致、循环依赖、与 Phase 01 概览一致
2. **若自检通过或变更列表为空**：返回 [Phase 02](1-code-cognition/phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04
3. **若自检不通过**：写出本轮变更列表（拆/合/重命名），更新总体报告中的模块列表与链接；根据回退规则选择：
   - 仅模块边界/数量调整 → 只重做 Task 2–4（受影响的模块）及 Task 5
   - 主流程或顶层分解需修正 → 返回 [Phase 01](1-code-cognition/phases/01-overview.md)，更新概览后重新执行 Phase 02

---

## 验收标准

### 必须满足

- [ ] 主要模块（建议 ≥80% 的已识别模块）均有对应 `docs/codearch/modules/<module_name>.md`
- [ ] 每份模块报告含：职责、边界（输入/输出）、依赖（内部/外部）、**复杂度评级**、**关键设计要点**（建议 3–5 条）
- [ ] 每份模块报告含「代码特征」章节，包含内存管理、并发模型、I/O 操作、外部数据处理、错误处理各维度
- [ ] 每份模块报告含「关键代码位置索引」章节，至少包含主要入口点
- [ ] 每份模块报告含「信息来源」章节，记录分析依据
- [ ] 每份模块报告含「使用示例」章节，至少一个基本用法，并标注来源
- [ ] 复杂度为「高」或「极高」的模块报告含「验证状态」章节
- [ ] 总体报告中存在「模块列表」且每条含路径/范围、到该模块报告的链接
- [ ] 总体报告中「技术特征概览」的「技术特征统计」已更新
- [ ] 链接指向的文件存在
- [ ] **分解审视已执行**且结论为「通过」或已达成收敛（Task 5）

### 验收检查

```bash
# 模块报告目录存在且非空
[ -d docs/codearch/modules ] && [ "$(ls -A docs/codearch/modules 2>/dev/null)" ] && echo "PASS" || echo "FAIL"
# 总体报告存在且含模块链接
[ -f docs/codearch/overall_report.md ] && grep -q "modules/.*\.md" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
# 检查模块报告是否含代码特征（抽样检查）
grep -l "代码特征\|Code Characteristics" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含使用示例（抽样检查）
grep -l "使用示例\|Usage Example" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含关键代码位置索引
grep -l "关键代码位置索引\|主要入口点" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查高复杂度模块是否含验证状态
for f in docs/codearch/modules/*.md; do
  if grep -q "等级.*高\|等级.*极高" "$f" 2>/dev/null; then
    grep -q "验证状态\|验证等级" "$f" && echo "$f: PASS" || echo "$f: FAIL (missing validation)"
  fi
done
# 检查总体报告是否含技术特征统计
grep -q "技术特征统计\|技术特征概览" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 使用 [complexity_levels](1-code-cognition/definitions/complexity_levels.md) 统一评级
- 使用 [validation_levels](1-code-cognition/definitions/validation_levels.md) 确定验证等级
- 依赖关系结合构建配置与 include 验证
- 优先利用已有文档和测试作为信息来源，文档内容优先于代码推断
- 使用示例优先从现有示例/测试中提取，标注来源
- 对高复杂度模块进行验证，确认理解正确
- 代码特征只记录客观事实（是/否 + 简要说明），不做风险判断
- 不确定处标注「待确认」

## 不应该做

- 不凭猜测填写职责与依赖
- 不忽略项目自带的 README 和文档
- 不编造使用示例而不加标注（Agent 编写的示例需标注）
- 不跳过高复杂度模块的验证步骤
- 不在模块报告中写可测试性状态（S1–S4）或测试策略
- 不在代码特征中做风险判断（如「可能存在内存泄漏」），只记录事实（如「使用手动内存管理」）

---

## 状态跳转

| 验收结果              | 下一步                                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 审视通过或已收敛      | 返回 [Phase 02](1-code-cognition/phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04                  |
| 审视不通过            | 按变更列表修正后重做 Task 2–4（受影响模块）及 Task 5，或返回 [Phase 01](1-code-cognition/phases/01-overview.md) 后重做 Phase 02 |
| 未通过 - 模块遗漏     | 继续任务 1、1.5、2                                                                                                              |
| 未通过 - 链接缺失     | 继续任务 4                                                                                                                      |
| 未通过 - 使用示例缺失 | 继续任务 1.5、2（补充示例部分）                                                                                                 |
| 未通过 - 验证缺失     | 执行任务 2.5（需先确认 Phase 03 已完成）                                                                                        |
| 验证需要构建环境      | 先执行 [Phase 03](1-code-cognition/phases/03-build-and-tests.md)，完成后返回执行任务 2.5                                        |

---

## 时间预估

| 工程规模           | 预估时间 |
| ------------------ | -------- |
| 小型（<10 模块）   | 1–2 小时 |
| 中型（10–50 模块） | 2–4 小时 |
| 大型（>50 模块）   | 4–8 小时 |

---

**完成后**：返回 [Phase 02](1-code-cognition/phases/02-modules.md) 进行阶段验收
