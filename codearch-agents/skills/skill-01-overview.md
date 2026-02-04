# Skill 01: 工程概览与主流程

> **触发条件**：Phase 01 指示（入口决策 Q1 为「否」）  
> **目标**：归纳工程主要做什么、输入/输出、主流程，并写入总体报告的概览部分

---

## 输入

- 待分析的 C/C++ 工程（可无需已通过完整构建）
- README、入口源码、构建配置等

---

## 输出

| 产出 | 路径 | 必须 |
|------|------|------|
| 总体报告（概览部分） | `docs/codearch/overall_report.md` | ✓ |

撰写时遵循 [产出结构约定](../definitions/output_structure.md)。可先只写「工程概览」章节，模块列表与构建/测试摘要由后续 Phase 补充。

---

## 核心任务

### 任务 1: 确定工程目标

**目标**：用一段话说明工程主要做什么

**步骤**：

1. 阅读 README、项目描述、文档首页
2. 查看 main 或顶层入口（如 `main()`、服务启动函数）
3. 归纳领域与主要功能（例如：编译器前端、网络代理、嵌入式控制固件）

### 任务 2: 识别输入

**目标**：列出工程的主要输入来源

**步骤**：

1. 检查命令行参数（argc/argv、getopt、CLI 库）
2. 检查配置文件路径与环境变量
3. 检查输入文件、网络端点、消息队列等
4. 在总体报告中按类型列出（配置、文件、命令行、网络等）

### 任务 3: 识别输出

**目标**：列出工程的主要输出

**步骤**：

1. 检查写入文件、标准输出、日志
2. 检查网络响应、RPC 返回、消息发布
3. 在总体报告中按类型列出（结果文件、服务响应、日志等）

### 任务 4: 梳理主流程

**目标**：用步骤列表或流程图描述从启动到完成的主路径

**步骤**：

1. 从入口跟踪主要调用链（main → 初始化 → 主循环/主逻辑 → 收尾）
2. 识别关键分支（如模式 A/B、守护进程 vs 单次执行）
3. 用编号步骤或 Mermaid 图写出主流程，放入总体报告「主流程」节

**分析命令参考**：

```bash
# 查找 main 或入口
grep -rn "int main\|void main\|WinMain" . --include="*.c" --include="*.cpp"
grep -rn "int main" . --include="*.cc"

# 查找配置/命令行解析
grep -rn "getopt\|argc\|argv\|config\|Config" . --include="*.c" --include="*.cpp" | head -30
```

---

## 验收标准

### 必须满足

- [ ] `docs/codearch/overall_report.md` 存在
- [ ] 文档包含「工程目标」且非空
- [ ] 文档包含「输入」且至少列出一类输入
- [ ] 文档包含「输出」且至少列出一类输出
- [ ] 文档包含「主流程」且至少有三步或等价描述

### 验收检查

```bash
[ -f docs/codearch/overall_report.md ] && echo "PASS" || echo "FAIL"
grep -q "工程目标\|工程目标" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
grep -q "输入" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
grep -q "输出" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
grep -q "主流程" docs/codearch/overall_report.md && echo "PASS" || echo "FAIL"
```

---

## 应该做

- 基于 README 与代码归纳，不臆测
- 主流程聚焦主路径，复杂分支可简述
- 不确定的输入/输出可标注「待确认」

## 不应该做

- 不预先填写模块列表与构建/测试（由后续 Phase 负责）
- 不写过长叙述，保持概览简洁

---

## 状态跳转

| 验收结果 | 下一步 |
|----------|--------|
| 通过 | 返回 [Phase 01](../phases/01-overview.md) 完成阶段验收，然后根据入口决策进入 Phase 02 或结束 |
| 未通过 | 补全缺失章节后重新验收 |

---

## 时间预估

| 工程规模 | 预估时间 |
|----------|----------|
| 小型 | 15–30 分钟 |
| 中型 | 30–60 分钟 |
| 大型 | 1–2 小时 |

---

**完成后**：返回 [Phase 01](../phases/01-overview.md) 进行阶段验收
