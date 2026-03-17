# Skill 00: 工程元数据采集

> **触发**: Phase 00 指示  
> **目标**: 机械化采集工程客观指标数据  
> **预计耗时**: 10–20 分钟

---

## 输入

- C/C++ 工程源码树
- 构建配置文件（CMakeLists.txt / BUILD / Makefile 等）

## 输出

| 产出物 | 路径 | 必须 |
|---|---|---|
| 工程元数据报告 | `docs/codearch/engineering_metadata.md` | ✅ |

---

## 核心任务

### 任务 1: 目录结构扫描

扫描前三层目录结构，排除隐藏目录：

```bash
find . -maxdepth 3 -type d | grep -v '\./\.' | sort
```

将输出完整粘贴到报告的「目录结构（前三层）」章节。

### 任务 2: 构建 Target 提取

提取所有构建目标（库、可执行文件、测试）：

```bash
# CMake 项目
grep -r "add_library\|add_executable\|add_test" . --include="CMakeLists.txt" | head -40

# Bazel 项目
grep -r "cc_library\|cc_binary\|cc_test" . --include="BUILD*" | head -40
```

将结果整理到报告的「构建 Target 列表」表格。

### 任务 3: 代码行数统计

按顶层源码目录统计 C/C++ 代码行数：

```bash
# 逐目录统计
for dir in src/*/; do
  echo "=== $dir ==="
  find "$dir" -name "*.cpp" -o -name "*.h" -o -name "*.c" | xargs wc -l 2>/dev/null | tail -1
done
```

若系统安装了 `cloc`，可使用更精确的统计：

```bash
cloc --by-file-by-lang --csv src/
```

将结果填入报告的「各目录代码行数统计」表格。

### 任务 4: 命名空间提取

提取所有命名空间声明：

```bash
grep -rn "^namespace " . --include="*.h" --include="*.cpp" | sed 's/.*namespace //' | sed 's/{.*//' | sort -u
```

将结果填入报告的「命名空间列表」表格。

### 任务 5: 文档清单

扫描已有文档文件：

```bash
find . -name "README*" -o -name "*.md" -o -name "AGENTS.md" -o -name "CONTRIBUTING*" | head -20
```

将结果填入报告的「已有文档清单」表格。

### 任务 6: 测试目录识别

识别测试目录结构与测试框架：

```bash
# 测试目录
find . -type d -name "test*" -o -type d -name "*test" -o -type d -name "*unittest*" 2>/dev/null

# 测试框架检测
grep -rn "gtest\|TEST(\|TEST_F(\|Catch\|BOOST_AUTO_TEST" . --include="*.cpp" --include="*.c" | head -10
```

将结果填入报告的「测试目录结构」表格。

### 任务 7: 计算复杂度阈值配置

基于任务 3 采集的代码行数统计，计算项目自适应的复杂度阈值。这些阈值将被 P2 评级和 P3 收敛检查引用，取代硬编码的固定数值。

```bash
# 计算工程总有效代码行数 T
T=$(find src/ -name "*.cpp" -o -name "*.h" -o -name "*.c" 2>/dev/null | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
echo "工程总有效代码行数 T = $T"

# 计算各阈值（使用整数算术）
FLOOR_HIGH=$(( T * 15 / 100 ))
[ $FLOOR_HIGH -lt 3000 ] && FLOOR_HIGH=3000

SPLIT_EVAL=$(( T * 8 / 100 ))
[ $SPLIT_EVAL -lt 1500 ] && SPLIT_EVAL=1500

PER_DIR_JUSTIFY=$(( T * 25 / 100 ))
[ $PER_DIR_JUSTIFY -lt 8000 ] && PER_DIR_JUSTIFY=8000

echo "地板阈值_高 = $FLOOR_HIGH (max(T*15%, 3000))"
echo "拆分评估阈值 = $SPLIT_EVAL (max(T*8%, 1500))"
echo "逐目录论证阈值 = $PER_DIR_JUSTIFY (max(T*25%, 8000))"
```

将计算结果填入报告的「复杂度阈值配置」章节。详见 [objective_metrics — 阈值配置](../definitions/objective_metrics.md)。

### 任务 8: 汇总到报告

使用模板 [engineering_metadata.md](../templates/engineering_metadata.md) 格式化所有采集数据，生成 `docs/codearch/engineering_metadata.md`。

---

## 验收标准

- [ ] `docs/codearch/engineering_metadata.md` 文件已生成
- [ ] 报告包含全部 7 个章节（目录结构、构建 Target、代码行数、命名空间、文档清单、测试目录、复杂度阈值配置）
- [ ] 复杂度阈值配置已基于工程总代码量计算填写
- [ ] 所有数据均来自命令直接输出，无模型解读或主观分析

---

## 注意事项

| 类别 | 说明 |
|---|---|
| **DO** | 执行所有列出的命令，完整记录输出 |
| **DON'T** | 不要对采集结果做任何解读或分析——那是 P1/P2 的职责 |

---

## 跳转

| 结果 | 下一步 |
|---|---|
| 验收通过 | → Phase 00 验收 |
