# Skill 14: 静态分析工具集成

> **触发条件**：Phase 02 工程分析时、Skill 04 可测试性评估时  
> **目标**：利用C/C++静态分析工具自动化收集代码质量、依赖关系和风险指标

---

## 输入

- 可编译的C/C++代码库
- `compile_commands.json`（强烈推荐）

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 静态分析报告 | `docs/analysis/static_analysis_report.md` | ✓ |
| 依赖关系图 | `docs/analysis/dependency_graph.md` | ✓ |
| 复杂度报告 | `docs/analysis/complexity_report.md` | ✓ |
| 问题清单 | `docs/analysis/issues_list.md` | 推荐 |

---

## 工具链概述

### 推荐工具集

| 工具 | 用途 | 安装方式 |
|------|------|----------|
| **clang-tidy** | 代码质量检查、现代化建议 | `apt install clang-tidy` |
| **cppcheck** | 静态错误检测 | `apt install cppcheck` |
| **include-what-you-use** | 头文件依赖分析 | `apt install iwyu` |
| **lizard** | 圈复杂度分析 | `pip install lizard` |
| **cppdepend** | 依赖关系可视化 | 商业/开源替代 |
| **doxygen** | 文档生成与调用图 | `apt install doxygen` |
| **gcov/lcov** | 覆盖率分析 | `apt install lcov` |

### 工具安装脚本

```bash
#!/bin/bash
# tools/install_analysis_tools.sh

set -e

echo "=== 安装静态分析工具 ==="

# 基础工具
sudo apt-get update
sudo apt-get install -y \
    clang-tidy \
    cppcheck \
    iwyu \
    doxygen \
    graphviz \
    lcov

# Python工具
pip3 install lizard

echo "=== 验证安装 ==="
clang-tidy --version
cppcheck --version
lizard --version
iwyu --version 2>&1 | head -1

echo "=== 安装完成 ==="
```

---

## 核心任务

### 任务 1: 生成编译数据库

**目标**：确保 `compile_commands.json` 存在且完整

**步骤**：

```bash
# CMake项目
mkdir -p build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
cp compile_commands.json ..

# Make项目（使用bear）
sudo apt install bear
bear -- make clean all
# 生成 compile_commands.json

# Bazel项目
# 使用 hedron_compile_commands
bazel run @hedron_compile_commands//:refresh_all
```

**验证**：

```bash
# 检查文件存在且非空
[ -s compile_commands.json ] && echo "PASS" || echo "FAIL"

# 检查格式正确
python3 -c "import json; json.load(open('compile_commands.json'))" && echo "Valid JSON" || echo "Invalid JSON"

# 检查覆盖率
wc -l compile_commands.json
# 应该包含项目中大部分源文件
```

### 任务 2: 运行 Clang-Tidy 分析

**目标**：检测代码质量问题和现代化机会

**执行命令**：

```bash
#!/bin/bash
# tools/run_clang_tidy.sh

OUTPUT_DIR="docs/analysis"
mkdir -p "$OUTPUT_DIR"

# 定义检查规则集
CHECKS="-*,\
bugprone-*,\
cert-*,\
cppcoreguidelines-*,\
misc-*,\
modernize-*,\
performance-*,\
readability-*,\
-modernize-use-trailing-return-type,\
-readability-magic-numbers"

# 运行分析
echo "=== Running clang-tidy ==="
clang-tidy \
    -p compile_commands.json \
    --checks="$CHECKS" \
    src/**/*.cpp \
    2>&1 | tee "$OUTPUT_DIR/clang_tidy_raw.txt"

# 生成摘要
echo "=== Generating summary ==="
grep -E "warning:|error:" "$OUTPUT_DIR/clang_tidy_raw.txt" | \
    sed 's/\[.*\]//' | \
    sort | uniq -c | sort -rn > "$OUTPUT_DIR/clang_tidy_summary.txt"

echo "=== Done ==="
```

**输出解析**：

| 类别 | 含义 | 可测试性影响 |
|------|------|--------------|
| `bugprone-*` | 潜在Bug | 需要测试覆盖 |
| `cppcoreguidelines-*` | 核心指南违规 | 可能影响可测性 |
| `modernize-*` | 可现代化代码 | 重构机会 |
| `performance-*` | 性能问题 | 可选优化 |
| `readability-*` | 可读性问题 | 重构机会 |

### 任务 3: 运行 Cppcheck 分析

**目标**：检测静态错误和未定义行为

**执行命令**：

```bash
#!/bin/bash
# tools/run_cppcheck.sh

OUTPUT_DIR="docs/analysis"
mkdir -p "$OUTPUT_DIR"

echo "=== Running cppcheck ==="
cppcheck \
    --enable=all \
    --inconclusive \
    --std=c++17 \
    --xml \
    --xml-version=2 \
    --suppress=missingIncludeSystem \
    --project=compile_commands.json \
    2> "$OUTPUT_DIR/cppcheck_result.xml"

# 转换为可读格式
cppcheck-htmlreport \
    --file="$OUTPUT_DIR/cppcheck_result.xml" \
    --report-dir="$OUTPUT_DIR/cppcheck_html" \
    --source-dir=. \
    2>/dev/null || echo "HTML report skipped (cppcheck-htmlreport not installed)"

# 生成摘要
echo "=== Generating summary ==="
grep -oP 'severity="\K[^"]+' "$OUTPUT_DIR/cppcheck_result.xml" | \
    sort | uniq -c | sort -rn > "$OUTPUT_DIR/cppcheck_summary.txt"

echo "=== Done ==="
```

**严重级别说明**：

| 级别 | 含义 | 处理优先级 |
|------|------|------------|
| `error` | 确定的Bug | 高 |
| `warning` | 可能的问题 | 中 |
| `style` | 代码风格 | 低 |
| `performance` | 性能建议 | 可选 |
| `portability` | 可移植性 | 视情况 |
| `information` | 信息提示 | 参考 |

### 任务 4: 运行复杂度分析

**目标**：识别高复杂度函数，评估可测试性

**执行命令**：

```bash
#!/bin/bash
# tools/run_complexity.sh

OUTPUT_DIR="docs/analysis"
mkdir -p "$OUTPUT_DIR"

echo "=== Running lizard complexity analysis ==="

# 运行分析
lizard \
    --CCN 15 \
    --length 100 \
    --arguments 6 \
    --warnings_only \
    --csv \
    src/ \
    > "$OUTPUT_DIR/complexity_warnings.csv"

# 完整报告
lizard \
    --csv \
    src/ \
    > "$OUTPUT_DIR/complexity_full.csv"

# 生成Markdown报告
echo "# 复杂度分析报告" > "$OUTPUT_DIR/complexity_report.md"
echo "" >> "$OUTPUT_DIR/complexity_report.md"
echo "> 生成时间: $(date '+%Y-%m-%d %H:%M')" >> "$OUTPUT_DIR/complexity_report.md"
echo "" >> "$OUTPUT_DIR/complexity_report.md"

echo "## 高风险函数（CCN > 15）" >> "$OUTPUT_DIR/complexity_report.md"
echo "" >> "$OUTPUT_DIR/complexity_report.md"
echo "| 文件 | 函数 | CCN | 行数 | 参数数 |" >> "$OUTPUT_DIR/complexity_report.md"
echo "|------|------|-----|------|--------|" >> "$OUTPUT_DIR/complexity_report.md"

# 解析CSV并生成表格
tail -n +2 "$OUTPUT_DIR/complexity_warnings.csv" | \
    awk -F',' '{printf "| %s | %s | %s | %s | %s |\n", $NF, $2, $3, $1, $5}' \
    >> "$OUTPUT_DIR/complexity_report.md"

echo "" >> "$OUTPUT_DIR/complexity_report.md"
echo "## 统计摘要" >> "$OUTPUT_DIR/complexity_report.md"
lizard --csv src/ 2>/dev/null | tail -1 >> "$OUTPUT_DIR/complexity_report.md"

echo "=== Done ==="
```

**复杂度阈值说明**：

| 指标 | 阈值 | 含义 |
|------|------|------|
| CCN (圈复杂度) | > 15 | 高风险，难以测试 |
| CCN | > 10 | 中风险，建议重构 |
| CCN | ≤ 10 | 低风险，易于测试 |
| 函数行数 | > 100 | 过长，建议拆分 |
| 参数数量 | > 6 | 过多，建议引入参数对象 |

### 任务 5: 运行依赖分析

**目标**：生成模块依赖关系图

**执行命令**：

```bash
#!/bin/bash
# tools/run_dependency_analysis.sh

OUTPUT_DIR="docs/analysis"
mkdir -p "$OUTPUT_DIR"

echo "=== Running include-what-you-use ==="

# 分析头文件依赖
iwyu_tool.py -p compile_commands.json -- \
    -Xiwyu --no_fwd_decls \
    2>&1 | tee "$OUTPUT_DIR/iwyu_raw.txt"

echo "=== Generating include dependency graph ==="

# 使用自定义脚本生成依赖图
cat > /tmp/gen_dep_graph.py << 'EOF'
import os
import re
import sys
from collections import defaultdict

def analyze_includes(src_dir):
    deps = defaultdict(set)
    include_pattern = re.compile(r'#include\s*[<"]([^>"]+)[>"]')
    
    for root, dirs, files in os.walk(src_dir):
        for f in files:
            if f.endswith(('.cpp', '.cc', '.c', '.h', '.hpp')):
                filepath = os.path.join(root, f)
                module = os.path.dirname(filepath).replace(src_dir, '').strip('/')
                if not module:
                    module = 'root'
                
                with open(filepath, 'r', errors='ignore') as file:
                    for line in file:
                        match = include_pattern.search(line)
                        if match:
                            inc = match.group(1)
                            # 提取模块名
                            inc_module = os.path.dirname(inc).split('/')[0] if '/' in inc else 'external'
                            if inc_module and inc_module != module:
                                deps[module].add(inc_module)
    
    return deps

def generate_mermaid(deps):
    print("```mermaid")
    print("graph TD")
    for src, targets in sorted(deps.items()):
        for tgt in sorted(targets):
            print(f"    {src.replace('/', '_')}[{src}] --> {tgt.replace('/', '_')}[{tgt}]")
    print("```")

if __name__ == '__main__':
    src_dir = sys.argv[1] if len(sys.argv) > 1 else 'src'
    deps = analyze_includes(src_dir)
    generate_mermaid(deps)
EOF

python3 /tmp/gen_dep_graph.py src > "$OUTPUT_DIR/dependency_graph.md"

echo "=== Done ==="
```

### 任务 6: 生成综合报告

**目标**：整合所有分析结果

**执行命令**：

```bash
#!/bin/bash
# tools/generate_analysis_report.sh

OUTPUT_DIR="docs/analysis"
REPORT="$OUTPUT_DIR/static_analysis_report.md"

cat > "$REPORT" << 'EOF'
# 静态分析综合报告

> 生成时间: $(date '+%Y-%m-%d %H:%M')

---

## 概要

| 指标 | 值 |
|------|-----|
| 分析文件数 | $(find src -name "*.cpp" -o -name "*.c" | wc -l) |
| 总代码行数 | $(find src -name "*.cpp" -o -name "*.c" -exec cat {} \; | wc -l) |
| Clang-Tidy 警告数 | $(grep -c "warning:" docs/analysis/clang_tidy_raw.txt 2>/dev/null || echo "N/A") |
| Cppcheck 问题数 | $(grep -c "severity=" docs/analysis/cppcheck_result.xml 2>/dev/null || echo "N/A") |
| 高复杂度函数数 | $(wc -l < docs/analysis/complexity_warnings.csv 2>/dev/null || echo "N/A") |

---

## 可测试性风险评估

基于静态分析结果，以下模块存在较高的可测试性风险：

### 高风险模块

| 模块 | 风险因素 | 建议 |
|------|----------|------|
| (根据分析结果填写) | | |

### 依赖复杂度

参见 [依赖关系图](dependency_graph.md)

### 代码复杂度

参见 [复杂度报告](complexity_report.md)

---

## 详细报告链接

- [Clang-Tidy 原始输出](clang_tidy_raw.txt)
- [Clang-Tidy 摘要](clang_tidy_summary.txt)
- [Cppcheck 结果](cppcheck_result.xml)
- [复杂度报告](complexity_report.md)
- [依赖关系图](dependency_graph.md)

---

## 建议的优先处理项

1. **高复杂度函数**：优先重构CCN > 20的函数
2. **确定性Bug**：修复Cppcheck error级别问题
3. **现代化机会**：应用modernize-*建议
4. **依赖解耦**：处理循环依赖

EOF

echo "Report generated: $REPORT"
```

---

## 分析结果应用

### 在 Skill 02（工程分析）中的应用

| 分析结果 | 应用方式 |
|----------|----------|
| 依赖关系图 | 直接用于模块地图的依赖分析 |
| 复杂度报告 | 标注高复杂度模块的风险 |
| 头文件依赖 | 识别模块边界 |

### 在 Skill 04（可测试性评估）中的应用

| 分析结果 | 应用方式 |
|----------|----------|
| 圈复杂度 | 影响可测性评分 |
| 全局变量使用 | 识别全局状态依赖 |
| 函数参数数量 | 评估接口复杂度 |
| 静态警告 | 识别潜在Bug和风险 |

### 在 Skill 03（优先级排序）中的应用

| 分析结果 | 应用方式 |
|----------|----------|
| Bug密度 | 影响收益评分 |
| 复杂度 | 影响风险评分 |
| 依赖数量 | 影响可测性评分 |

---

## 验收标准

### 必须满足

- [ ] `compile_commands.json` 存在且有效
- [ ] 静态分析报告已生成
- [ ] 复杂度报告已生成
- [ ] 依赖关系图已生成

### 验收检查

```bash
# 检查文件存在
ls docs/analysis/static_analysis_report.md && echo "PASS" || echo "FAIL"
ls docs/analysis/complexity_report.md && echo "PASS" || echo "FAIL"
ls docs/analysis/dependency_graph.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- ✓ 确保 compile_commands.json 完整
- ✓ 使用多种工具交叉验证
- ✓ 关注高风险指标
- ✓ 将结果整合到模块地图

## 不应该做

- ✗ 忽略分析工具的警告
- ✗ 只运行一种工具
- ✗ 不验证工具输出
- ✗ 分析结果不持久化

---

## 状态跳转

| 触发来源 | 完成后返回 |
|----------|------------|
| Phase 02 | 返回 [Phase 02](../phases/02-analysis.md) 继续工程分析 |
| Skill 04 | 返回 [Skill 04](skill-04-assessment.md) 继续可测试性评估 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型（<10K 行） | 15 - 30 分钟 |
| 中型（10K-100K 行） | 30 - 60 分钟 |
| 大型（>100K 行） | 1 - 2 小时 |

---

**完成后**：返回触发此 Skill 的位置继续执行
