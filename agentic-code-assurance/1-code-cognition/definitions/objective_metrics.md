# 客观指标定义与采集

> **阅读时机**：P0 元数据采集、P2 复杂度评级时阅读

---

## 目的

定义在 P0（工程元数据采集）和 P2（复杂度评级）阶段需要采集的全部客观指标。这些指标作为模型结构化推理的**证据输入（Evidence Inputs）**，而非复杂度的唯一决定因素。

模型在进行复杂度评级时，必须引用相关指标作为论据，但最终评级由模型的综合推理决定。

---

## 工程级指标（P0 采集）

在项目级别采集一次，为后续所有模块分析提供全局上下文。

| 指标 | 采集命令 | 用途 |
|------|----------|------|
| 目录树（3 层） | `find . -maxdepth 3 -type d \| grep -v '\./\.' \| sort` | 了解项目整体结构与模块划分 |
| 构建目标 | `grep -r "add_library\|add_executable" . --include="CMakeLists.txt"`（Bazel/Make 使用等价命令） | 识别可独立构建的模块边界 |
| 各目录代码行数 | `cloc --by-file-by-lang --csv <dir>` 或 `find <dir> -name "*.cpp" -o -name "*.h" -o -name "*.c" \| xargs wc -l \| tail -1` | 量化各模块规模 |
| 命名空间列表 | `grep -rn "^namespace " . --include="*.h" --include="*.cpp" \| sed 's/.*namespace //' \| sort -u` | 识别逻辑分组与模块边界 |
| 已有文档清单 | `find . -name "README*" -o -name "*.md" -o -name "AGENTS.md" \| head -20` | 评估现有文档覆盖率 |
| 测试目录结构 | `find . -type d -name "test*" -o -type d -name "*test" 2>/dev/null` | 识别测试组织方式与覆盖范围 |

---

## 模块级指标（P2 采集）

在 P2 阶段对每个模块逐一采集，用于复杂度维度分析。

| 指标 | 采集命令 | 对应维度 |
|------|----------|----------|
| 代码行数 | `cloc $MODULE_PATH --csv` 或 `find $MODULE_PATH -name "*.cpp" -o -name "*.h" -o -name "*.c" \| xargs wc -l \| tail -1` | 维度 a（代码规模） |
| 类/结构体数量 | `grep -rn "^class \|^struct " $MODULE_PATH --include="*.h" \| wc -l` | 维度 a |
| 公开头文件数量 | `ls $MODULE_PATH/*.h 2>/dev/null \| wc -l` | 维度 a |
| 内部依赖数量 | `grep -r "#include" $MODULE_PATH --include="*.cpp" --include="*.h" \| grep -v "third_party\|external" \| wc -l` | 维度 b |
| 外部依赖类型扫描 — I/O | `grep -rn "fopen\|ifstream\|ofstream\|open\|read\|write" $MODULE_PATH --include="*.cpp" --include="*.c" \| head -3` | 维度 b, c |
| 外部依赖类型扫描 — 网络 | `grep -rn "socket\|connect\|bind\|listen\|send\|recv" $MODULE_PATH --include="*.cpp" --include="*.c" \| head -3` | 维度 b, c |
| 外部依赖类型扫描 — 线程/并发 | `grep -rn "pthread\|std::thread\|std::async\|mutex\|atomic" $MODULE_PATH --include="*.cpp" --include="*.h" \| head -3` | 维度 b, c |
| 外部依赖类型扫描 — 硬件/SDK | `grep -rn "ioctl\|mmap\|driver\|gpu\|cuda\|opencl\|tensorrt\|qnn" $MODULE_PATH --include="*.cpp" --include="*.h" \| head -3` | 维度 b, c |
| 锁/互斥量数量 | `grep -rn "std::mutex\|pthread_mutex" $MODULE_PATH --include="*.h" \| wc -l` | 维度 c |
| 函数数量估计 | `grep -rn "^[a-zA-Z_].*(" $MODULE_PATH --include="*.cpp" \| wc -l` | 维度 a |

---

## 强制评估触发阈值

以下阈值触发模型的**强制评估义务**。当指标超过阈值时，模型必须在结构化推理中明确回应，但阈值本身不自动决定最终评级。

| 指标 | 阈值 | 触发动作 |
|------|------|----------|
| 代码行数 | > 5000 | 必须在复杂度评级中提供拆分可行性评估 |
| 代码行数 | > 10000 | 复杂度下限 = 高（除非提供充分理由） |
| 类数量 | > 10 | 必须提供拆分可行性评估 |
| 公开头文件数量 | > 8 | 必须提供拆分可行性评估 |
| 检测到硬件/SDK 依赖 | — | 复杂度下限 = 极高 |
| 检测到跨进程通信 | — | 复杂度下限 = 极高 |

> **注意**：以上为强制评估的**触发条件**，而非自动评级。模型必须在结构化推理中对触发的条目逐一作出回应。

---

## 指标与推理的关系

- 指标为模型推理提供**客观锚点（Objective Anchoring Points）**。
- 模型在维度分析中**必须引用**相关指标数据。
- 模型**可以覆盖**指标隐含的评级，但必须提供清晰的理由。

**合理覆盖示例**：

> 代码行数为 8000 行（按机械规则应为升一档），但经分析其中约 5000 行为自动生成的序列化代码，信息密度低，实际认知复杂度为中。

**不合理覆盖反例**：

> 模型不能在缺乏充分理由的情况下，将一个代码行数 15000 行、包含线程机制和网络 I/O 的模块评为"低"复杂度。
