# 模块卡片模板

> **用途**：记录单个模块的评估结果、测试覆盖和重构进度  
> **位置**：`docs/testing/modules/<module_name>.md`

---

## 使用说明

1. 复制此模板到对应位置
2. 替换 `<placeholders>` 为实际内容
3. 在各阶段持续更新

---

```markdown
# 模块卡片: <module_name>

> 创建日期: YYYY-MM-DD
> 最后更新: YYYY-MM-DD
> 状态: [评估中 | 测试中 | 重构中 | 已完成 | 阻塞]

---

## 基本信息

| 属性 | 值 |
|------|-----|
| **路径** | `<src/path/to/module/>` |
| **类型** | [库 / 服务 / 驱动 / 工具] |
| **代码行数** | ~XXX 行 |
| **评估状态** | [S1 / S2 / S3 / S4] |
| **测试策略** | [L1 / L2 / L3] |

### 职责描述

<一段话描述模块的核心职责>

### 边界定义

**输入**:
- <输入类型1>: <描述>
- <输入类型2>: <描述>

**输出**:
- <输出类型1>: <描述>
- <输出类型2>: <描述>

---

## 依赖分析

### 内部依赖

| 依赖模块 | 依赖类型 | 说明 |
|----------|----------|------|
| <module_a> | 直接调用 | <说明> |
| <module_b> | 接口依赖 | <说明> |

### 外部依赖

| 类型 | 位置 | 用途 | 风险等级 |
|------|------|------|----------|
| 文件系统 | `file.cpp:45` | 读取配置 | 中 |
| 网络 | `client.cpp:120` | HTTP 请求 | 高 |
| 时间 | `timer.cpp:30` | 超时检测 | 中 |
| 线程 | `worker.cpp:80` | 并行处理 | 高 |
| 全局状态 | `config.cpp:10` | 配置单例 | 高 |

### Seam 候选点

| 位置 | 类型 | 当前状态 | 说明 |
|------|------|----------|------|
| `Class::Class(IDep*)` | 构造注入 | ✅ 已存在 | 可直接使用 |
| `globalFunc()` | 全局函数 | ❌ 需引入 | 需要包装为接口 |

---

## 评估结论

### 状态: <S1/S2/S3/S4>

**判定理由**:
1. <理由1>
2. <理由2>
3. <理由3>

### 风险点

- [ ] <风险1>
- [ ] <风险2>

### 建议路径

1. <步骤1> - Skill XX
2. <步骤2> - Skill YY
3. <步骤3> - Skill ZZ

---

## 测试覆盖（完成后填写）

### 单元测试

| 指标 | 值 |
|------|-----|
| **文件** | `tests/unit/<module>_test.cpp` |
| **用例数** | XX |
| **行覆盖率** | XX% |
| **分支覆盖率** | XX% |

### 表征测试（如有）

| 指标 | 值 |
|------|-----|
| **文件** | `tests/characterization/<module>_golden_test.cpp` |
| **Golden 数据** | `tests/characterization/golden/<module>/` |
| **场景数** | XX |

### 运行命令

```bash
# 运行该模块所有测试
./run_tests --gtest_filter="*<Module>*"

# 运行单元测试
./run_tests --gtest_filter="*<Module>Unit*"

# 运行表征测试
./run_tests --gtest_filter="*<Module>Golden*"
```

---

## 引入的 Seam（完成后填写）

| 接口 | 定义位置 | 默认实现 | 测试替身 |
|------|----------|----------|----------|
| `IClock` | `include/interfaces/clock.h` | `SystemClock` | `FakeClock` |
| `IFileReader` | `include/interfaces/file_reader.h` | `RealFileReader` | `FakeFileReader` |

---

## 经验记录

### 遇到的问题

1. **问题**: <描述>
   - **解决**: <解决方法>
   - **耗时**: X 小时

2. **问题**: <描述>
   - **解决**: <解决方法>
   - **耗时**: X 小时

### 可复用模式

- <模式1描述> - 参考 `<路径>`
- <模式2描述> - 参考 `<路径>`

### 发现的 Bug

| Bug | 状态 | 说明 |
|-----|------|------|
| <描述> | [已修复 / 待确认 / 已记录] | <备注> |

### 遗留问题

- [ ] <遗留项1>
- [ ] <遗留项2>

---

## 时间统计

| 阶段 | 耗时 |
|------|------|
| 评估 (Skill 04) | X 小时 |
| 表征测试 (Skill 05) | X 小时 |
| 单元测试 (Skill 06) | X 小时 |
| 引入 Seam (Skill 07) | X 小时 |
| 重构 (Skill 08) | X 小时 |
| **总计** | **X 小时** |

---

## 变更历史

| 日期 | 变更 | 操作者 |
|------|------|--------|
| YYYY-MM-DD | 创建模块卡片 | Agent |
| YYYY-MM-DD | 完成评估，状态 S2 | Agent |
| YYYY-MM-DD | 完成测试覆盖 | Agent |
```

---

## 快速填充脚本

```bash
#!/bin/bash
# tools/init_module_card.sh <module_name>

MODULE=$1
OUTPUT="docs/testing/modules/${MODULE}.md"

mkdir -p docs/testing/modules

cat > "$OUTPUT" << EOF
# 模块卡片: ${MODULE}

> 创建日期: $(date +%Y-%m-%d)
> 最后更新: $(date +%Y-%m-%d)
> 状态: 评估中

## 基本信息

| 属性 | 值 |
|------|-----|
| **路径** | \`src/${MODULE}/\` |
| **评估状态** | 待评估 |
| **测试策略** | 待定 |

（继续填充...）
EOF

echo "Created: $OUTPUT"
```
