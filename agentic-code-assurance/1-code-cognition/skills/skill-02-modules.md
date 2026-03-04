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

撰写时遵循 [产出结构约定](../definitions/output_structure.md)。进行复杂度评级时查阅 [复杂度等级定义](../definitions/complexity_levels.md)。进行模块验证时查阅 [验证等级定义](../definitions/validation_levels.md)。

---

## 核心任务

**执行顺序**：首轮执行 Task 1 → 1.5 → 2 → 2.1 → 2.2 → 2.3 → 2.4（条件） → 2.5（条件） → 3 → 4 → 5；修正轮由分解审视驱动，可只执行 Task 2–4 中受影响的模块、Task 4（更新总报告）与 Task 5。

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

模块边界与依赖分析时可按需查阅 [C/C++ 注意点](../definitions/cpp_cpp_notes.md)。

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

**目标**：按 [模块报告模板](../templates/module-report.md) 填写职责、边界、依赖、代码特征、信息来源、使用示例

**步骤**：

1. 为每个模块创建 `docs/codearch/modules/<module_name>.md`
2. 填写职责描述、输入/输出边界、内部依赖表、外部依赖表
3. 填写**关键设计要点**（建议 3–5 条：主要入口函数/类、核心数据结构、线程/并发假设、错误处理策略、扩展点等）
4. **填写「代码特征」**：执行任务 2.1 的扫描，填写内存管理、并发模型、I/O 操作、外部数据处理、错误处理各维度
5. **填写「关键代码位置索引」**：记录主要入口点和外部数据入口
6. **填写「与其它模块的关系」**：按结构化表格格式（上游依赖/下游依赖）填写，**须标注依赖类型**（调用/数据传递/事件通知/配置读取/继承）和**是否涉及跨模块所有权转移**；若本模块被 ≥3 个模块依赖，须在此节顶部注明「本模块为枢纽模块（HUB）」。依赖类型与所有权转移信息来源于任务 3 的分析结果（任务 3 完成后回填）。
7. **复杂度评级**：按 [complexity_levels](../definitions/complexity_levels.md) 判定等级（低/中/高/极高）并写入报告，可选写一句依据；**极高复杂度模块须填写拆分说明**（已拆/不拆的理由），高复杂度模块建议填写。
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

**产出**：为每个模块填写「代码特征」和「关键代码位置索引」章节（含错误/异常路径与外部数据入口首道校验位置）。

**填写原则**：

- 只记录客观事实，不做风险判断
- 简洁版：每个维度只填写「是/否」和简要说明
- 若某特征不存在，填写「否」或「无」

---

### 任务 2.2: 数据流路径分析

**目标**：为每个模块识别关键的数据流转路径，记录数据从入口到出口的完整流程与所有权转移

**步骤**：

1. **识别关键数据入口**
   - 从「关键代码位置索引 - 外部数据入口」中获取外部数据进入点
   - 从「关键代码位置索引 - 主要入口点」中获取模块接口入口

2. **追踪数据流转路径**
   - 对每个关键入口，沿代码追踪数据的流转过程
   - 记录数据经过的中间处理函数/步骤
   - 标记数据在流转过程中的所有权转移点（如：指针传递给另一个函数、对象移入容器）

3. **识别所有权转移**
   - 在每个转移点确认：调用方是否放弃所有权？被调用方是否接管所有权？
   - 标注转移语义：移动、借用（引用/指针）、拷贝、共享

4. **填写模块报告**
   - 将结果填入模块报告的「关键数据流路径」表

**分析命令参考**：

```bash
MODULE_PATH="src/<module>"

# 查找关键函数的调用链
grep -rn "函数名" $MODULE_PATH --include="*.cpp" --include="*.c" | head -10

# 查找指针/对象传递模式
grep -rn "std::move\|std::forward\|release()\|reset(" $MODULE_PATH --include="*.cpp" | head -10
```

**产出**：每个模块报告的「关键数据流路径」章节。

---

### 任务 2.3: 生命周期与所有权分析

**目标**：为关键对象/资源（特别是涉及手动内存管理或跨函数/跨模块生命周期的）记录完整的创建-销毁-所有权语义

**步骤**：

1. **识别关键对象/资源**
   - 从「代码特征 - 内存管理」中判断模块是否涉及手动内存管理
   - 若为「手动管理」或「混合」，扫描 malloc/new 调用，列出关键的动态分配对象
   - 关注跨函数传递的对象、回调中引用的对象、容器中管理的对象

2. **追踪每个关键对象的生命周期**
   - 记录创建位置（malloc/new/工厂函数）
   - 记录销毁位置（free/delete/析构函数）
   - 确认销毁是否在所有执行路径上都能到达（包括错误路径、异常路径、early return）
   - 若对象在函数间传递，确认每次传递时所有权语义

3. **记录所有权模型**
   - RAII：对象生命周期由作用域管理
   - 调用方释放：创建者负责释放
   - 框架释放：框架/调度器在回调后释放
   - 共享所有权：引用计数或多个持有者

4. **填写模块报告**
   - 将结果填入模块报告的「生命周期与所有权模型」表

**分析命令参考**：

```bash
MODULE_PATH="src/<module>"

# 查找动态分配
grep -rn "malloc\|calloc\|new " $MODULE_PATH --include="*.c" --include="*.cpp" | head -15

# 查找释放
grep -rn "free\|delete " $MODULE_PATH --include="*.c" --include="*.cpp" | head -15

# 查找所有权转移模式
grep -rn "std::move\|release()\|->set_\|callback" $MODULE_PATH --include="*.cpp" | head -10
```

**产出**：每个模块报告的「生命周期与所有权模型」章节。

**填写原则**：

- 只记录涉及手动内存管理或跨函数传递的关键对象，无需记录栈上局部变量
- 若模块无动态分配，标注「无需记录」
- 对象过多时优先记录：跨模块传递的、回调中引用的、容器管理的

---

### 任务 2.4: 并发不变量提取（条件执行）

**触发条件**：模块的「代码特征 - 并发模型 - 多线程」为「是」

**目标**：提取模块的并发不变量，记录共享数据的保护机制和线程上下文假设

**步骤**：

1. **识别共享数据**
   - 扫描成员变量、全局变量、静态变量中被多线程访问的
   - 关注回调函数中访问的数据（回调可能在不同线程上下文中执行）

2. **记录保护机制**
   - 每个共享数据对应的锁/原子操作/无锁结构
   - 若无保护，标注「未保护」（这是潜在风险点）

3. **提取锁获取顺序**
   - 若模块中存在多把锁，记录约定的获取顺序
   - 查找代码中是否存在不一致的获取顺序

4. **记录线程上下文假设**
   - 某些函数只在特定线程上下文中调用（如 poller 线程、handler 线程）
   - 记录这些假设，供下游审查验证

5. **填写模块报告**
   - 将结果填入模块报告的「并发不变量」表

**分析命令参考**：

```bash
MODULE_PATH="src/<module>"

# 查找锁定义
grep -rn "mutex\|pthread_mutex_t\|std::mutex" $MODULE_PATH --include="*.h" --include="*.cpp" | head -10

# 查找锁操作
grep -rn "lock\|unlock\|lock_guard\|unique_lock" $MODULE_PATH --include="*.cpp" | head -10

# 查找原子操作
grep -rn "atomic\|__sync_\|__atomic_" $MODULE_PATH --include="*.c" --include="*.cpp" | head -10
```

**产出**：每个多线程模块报告的「并发不变量」章节。非多线程模块标注「本模块为单线程模型，无并发不变量」。

---

### 任务 2.5: 模块验证（条件执行）

**触发条件**：模块复杂度为「高」或「极高」

**目标**：通过运行测试或编写探索性测试，验证对模块的理解是否正确

**前置检查**：

执行验证前，必须确认：

- [ ] Phase 03（构建与测试体系）已完成，或至少已知道如何构建和运行测试
- [ ] 构建环境可用（能够编译项目）
- [ ] 已识别模块对应的测试文件

**若前置条件不满足**：先跳转执行 [Phase 03](../phases/03-build-and-tests.md)，完成后返回继续验证。

**步骤**：

1. **确定验证等级**

   - 参照 [验证等级定义](../definitions/validation_levels.md)
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

### 任务 3: 解析依赖方向与关系结构化

**目标**：建立模块间依赖关系，识别依赖类型与跨模块所有权转移，避免循环依赖遗漏，为总体报告「模块依赖图」提供数据

**步骤**：

1. **分析 include 与链接依赖**，确认基础依赖方向：

   ```bash
   grep -r "#include" src/ | sed 's/.*#include [<"]\(.*\)[>"]/\1/' | sort | uniq -c | sort -rn
   grep -r "target_link_libraries" . --include="CMakeLists.txt"
   ```

2. **为每条依赖边标注依赖类型**，从以下枚举中选取：
   - `调用`：A 直接调用 B 的函数/方法（检查：B 的函数被 A 直接 call）
   - `数据传递`：A 将数据对象传给 B 或从 B 获取数据对象（检查：函数参数/返回值传递指针或对象）
   - `事件通知`：A 注册回调给 B，B 触发时调用 A 的函数（检查：callback 注册与触发模式）
   - `配置读取`：A 从 B 读取配置（检查：B 提供 get_config/get_option 类接口被 A 消费）
   - `继承`：A 继承/实现 B 定义的接口或基类（检查：class A : public B）

3. **识别跨模块所有权转移**：对依赖类型为「数据传递」的每条边，判断是否涉及所有权转移：
   - 转移标志：裸指针传入后由接收方负责 free/delete；`unique_ptr` 通过 `std::move` 传入；函数文档/注释说明"调用方将所有权交给被调用方"
   - 记录转移方向：「A 获得所有权」或「B 获得所有权」

4. **识别枢纽模块**：统计每个模块被其他模块依赖的数量，被 ≥3 个模块依赖的标记为枢纽模块（HUB）。

5. **在模块报告中填写「与其它模块的关系」结构化表格**：按上游依赖/下游依赖分别列出，填入依赖类型与所有权转移信息（可回填任务 2 步骤 6 留的占位）。

6. **在总体报告中生成/更新「模块依赖图」**：用 Mermaid flowchart 表示所有模块及依赖边，边标签写明依赖类型；有所有权转移的边追加 `[所有权转移]`；枢纽模块节点标注 `[HUB]`。

**分析命令参考**：

```bash
# 查找回调注册模式
grep -rn "callback\|register\|set_handler\|add_listener" src/ --include="*.cpp" --include="*.h" | head -10

# 查找所有权转移模式
grep -rn "std::move\|release()\|unique_ptr" src/ --include="*.cpp" | head -10

# 查找继承关系
grep -rn "class.*:.*public\|class.*:.*private" src/ --include="*.h" | head -10
```

### 任务 4: 更新总体报告中的模块列表、技术特征统计与模块依赖图

**目标**：在 `docs/codearch/overall_report.md` 中更新「模块列表」「技术特征概览」和「模块依赖图」

**步骤**：

1. 打开或创建总体报告
2. 插入或更新模块列表表/列表，确保每项含路径/范围，链接为相对路径 `modules/<module_name>.md`
3. **更新「技术特征概览」的「技术特征统计」**：
   - 统计各技术特征涉及的模块数量
   - 列出涉及该特征的主要模块名称
   - 基于各模块报告的「代码特征」章节汇总
4. **生成或更新「模块依赖图」**：
   - 基于任务 3 的分析结果，用 Mermaid flowchart 绘制全局依赖图
   - 每条边标注依赖类型（调用/数据传递/事件通知/配置读取/继承）
   - 涉及所有权转移的边追加 `[所有权转移]` 标注
   - 枢纽模块节点标注 `[HUB]`

### 任务 5: 分解质量自检（分解审视）

**目标**：按 [分解审视约定](../definitions/decomposition_review.md) 检查当前模块划分是否稳定、合理

**步骤**：

1. 阅读并执行 [decomposition_review](../definitions/decomposition_review.md) 中的审视维度（checklist）：单一职责、边界清晰、粒度一致、循环依赖、与 Phase 01 概览一致
2. **若自检通过或变更列表为空**：返回 [Phase 02](../phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04
3. **若自检不通过**：写出本轮变更列表（拆/合/重命名），更新总体报告中的模块列表与链接；根据回退规则选择：
   - 仅模块边界/数量调整 → 只重做 Task 2–4（受影响的模块）及 Task 5
   - 主流程或顶层分解需修正 → 返回 [Phase 01](../phases/01-overview.md)，更新概览后重新执行 Phase 02

---

## 验收标准

### 必须满足

- [ ] 主要模块（建议 ≥80% 的已识别模块）均有对应 `docs/codearch/modules/<module_name>.md`
- [ ] 每份模块报告含：职责、边界（输入/输出）、依赖（内部/外部）、**复杂度评级**、**关键设计要点**（建议 3–5 条）
- [ ] **极高复杂度模块报告的「复杂度评级」中含拆分说明**（已拆/不拆的理由）
- [ ] 每份模块报告含「代码特征」章节，包含内存管理、并发模型、I/O 操作、外部数据处理、错误处理各维度
- [ ] 每份模块报告含「关键代码位置索引」章节，至少包含主要入口点、错误/异常路径、外部数据入口（含首道校验位置）
- [ ] 每份模块报告含「关键数据流路径」章节，至少包含一条关键数据流转路径
- [ ] 每份模块报告含「生命周期与所有权模型」章节（涉及手动内存管理的模块须列出关键对象）
- [ ] 多线程模块的报告含「并发不变量」章节（非多线程模块标注「本模块为单线程模型」）
- [ ] **每份模块报告含「与其它模块的关系」结构化表格**，上游/下游依赖各有独立表格，每行含依赖类型与跨模块所有权转移标注
- [ ] 每份模块报告含「信息来源」章节，记录分析依据
- [ ] 每份模块报告含「使用示例」章节，至少一个基本用法，并标注来源
- [ ] 复杂度为「高」或「极高」的模块报告含「验证状态」章节
- [ ] 总体报告中存在「模块列表」且每条含路径/范围、到该模块报告的链接
- [ ] **总体报告中存在「模块依赖图」（Mermaid 图）**，每条边含依赖类型标注，枢纽模块标注 `[HUB]`，所有权转移边标注 `[所有权转移]`
- [ ] 总体报告中「技术特征概览」的「技术特征统计」已更新
- [ ] 链接指向的文件存在
- [ ] **分解审视已执行**且结论为「通过」或已达成收敛（Task 5）

### 验收检查

```bash
# 模块报告目录存在且非空
[ -d docs/codearch/modules ] && [ "$(ls -A docs/codearch/modules 2>/dev/null)" ] && echo "PASS" || echo "FAIL"
# 总体报告存在且含模块链接
[ -f docs/codearch/overall_report.md ] && grep -q "modules/.*\.md" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
# 检查总体报告是否含模块依赖图（Mermaid）
grep -q "flowchart\|graph " docs/codearch/overall_report.md && echo "PASS (依赖图存在)" || echo "FAIL (缺少模块依赖图)"
# 检查总体报告依赖图是否含依赖类型标注
grep -q "调用\|数据传递\|事件通知\|配置读取\|继承" docs/codearch/overall_report.md && echo "PASS (含依赖类型)" || echo "CHECK (依赖图可能缺少类型标注)"
# 检查模块报告是否含代码特征（抽样检查）
grep -l "代码特征\|Code Characteristics" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含使用示例（抽样检查）
grep -l "使用示例\|Usage Example" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含关键代码位置索引
grep -l "关键代码位置索引\|主要入口点" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含关键数据流路径
grep -l "关键数据流路径\|数据流" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含生命周期与所有权模型
grep -l "生命周期与所有权\|所有权模型" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查模块报告是否含结构化的与其它模块的关系（上游依赖/下游依赖）
grep -l "上游依赖\|下游依赖" docs/codearch/modules/*.md 2>/dev/null | wc -l
# 检查多线程模块是否含并发不变量
for f in docs/codearch/modules/*.md; do
  if grep -q "多线程.*是" "$f" 2>/dev/null; then
    grep -q "并发不变量" "$f" && echo "$f: PASS" || echo "$f: FAIL (missing concurrency invariants)"
  fi
done
# 检查高复杂度模块是否含验证状态
for f in docs/codearch/modules/*.md; do
  if grep -q "等级.*高\|等级.*极高" "$f" 2>/dev/null; then
    grep -q "验证状态\|验证等级" "$f" && echo "$f: PASS" || echo "$f: FAIL (missing validation)"
  fi
done
# 检查极高复杂度模块是否含拆分说明
for f in docs/codearch/modules/*.md; do
  if grep -q "等级.*极高" "$f" 2>/dev/null; then
    grep -q "拆分说明\|已拆\|不拆" "$f" && echo "$f: PASS" || echo "$f: FAIL (missing split evaluation)"
  fi
done
# 检查总体报告是否含技术特征统计
grep -q "技术特征统计\|技术特征概览" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 使用 [complexity_levels](../definitions/complexity_levels.md) 统一评级
- 使用 [validation_levels](../definitions/validation_levels.md) 确定验证等级
- 依赖关系结合构建配置与 include 验证
- **为每条依赖边标注依赖类型**（调用/数据传递/事件通知/配置读取/继承），并识别跨模块所有权转移
- **极高复杂度模块须评估拆分可行性**，并在报告中写明结论（已拆/不拆的理由）
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
| 审视通过或已收敛      | 返回 [Phase 02](../phases/02-modules.md) 完成阶段验收，然后根据入口决策进入 Phase 03 或 Phase 04                  |
| 审视不通过            | 按变更列表修正后重做 Task 2–4（受影响模块）及 Task 5，或返回 [Phase 01](../phases/01-overview.md) 后重做 Phase 02 |
| 未通过 - 模块遗漏     | 继续任务 1、1.5、2                                                                                                              |
| 未通过 - 链接缺失     | 继续任务 4                                                                                                                      |
| 未通过 - 使用示例缺失 | 继续任务 1.5、2（补充示例部分）                                                                                                 |
| 未通过 - 验证缺失     | 执行任务 2.5（需先确认 Phase 03 已完成）                                                                                        |
| 验证需要构建环境      | 先执行 [Phase 03](../phases/03-build-and-tests.md)，完成后返回执行任务 2.5                                        |

---

## 时间预估

| 工程规模           | 预估时间 |
| ------------------ | -------- |
| 小型（<10 模块）   | 1–2 小时 |
| 中型（10–50 模块） | 2–4 小时 |
| 大型（>50 模块）   | 4–8 小时 |

---

**完成后**：返回 [Phase 02](../phases/02-modules.md) 进行阶段验收
