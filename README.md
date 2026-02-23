# 可测试性重构与代码架构分析 - Agent 工作流

本仓库提供三套 Agent 工作流，用于在复杂 C/C++ 项目上做架构分析、可测试性重构与自动化 BUG 分析。通过 ClaudeCode 或 OpenCode 加载对应工作流，可自动化执行相应任务。

## 项目简介

本项目提供**三套** Agent 工作流：

- **codearch-agents**（代码架构分析）：理解项目在做什么、分析模块与依赖、文档化构建与测试体系，产出总体报告与各模块报告（含使用示例与高复杂度模块验证），供后续代码审查与写测试按需引用。
- **automated-ut-agents**（可测试性重构）：从基线准备、工程分析、优先级排序到迭代重构，系统化提升 C/C++ 项目可测试性并补充单元测试。
- **agentic-code-assurance**（自动化 BUG 分析）：端到端流水线「代码认知 → 风险评估 → BUG 确认与修复」——先建立工程知识库，再通过路径追踪审查识别潜在 BUG，最后编写验证测试并修复，支持迭代深化与反馈更新知识库。

三者可配合使用：架构分析产出的文档可被可测试性重构、BUG 分析工作流按需引用；BUG 分析工作流的阶段一（代码认知）与 codearch-agents 产出结构兼容，可复用 `docs/codearch/` 知识库。推荐先跑架构分析，再按需跑可测试性重构或 BUG 分析。

## 三种工作流概览

| 维度 | codearch-agents | automated-ut-agents | agentic-code-assurance |
|------|-----------------|---------------------|------------------------|
| 入口 | `codearch-agents/Workflow.md` | `automated-ut-agents/Workflow.md` | `agentic-code-assurance/Workflow.md` |
| 目标 | 架构理解、模块/依赖分析、构建与测试文档化、产出结构化报告 | 建立门禁基线、分析、优先级排序、迭代重构与单测 | 代码认知 → 风险评估 → BUG 验证与修复，支持迭代深化 |
| 阶段数 | 4（概览 → 模块 → 构建与测试 → 报告） | 4（基线 → 分析 → 优先级 → 迭代） | 3（代码认知 → 风险评估 → BUG 修复） |
| 技能数 | 4 个 | 14 个 | 各子工作流内按阶段配置 |
| 典型产出 | `docs/codearch/` 下总体报告与 `modules/*.md` | 门禁基线、`docs/architecture/`、`docs/testing/backlog.md` 及迭代结果 | `docs/codearch/`（阶段一）、`docs/risk_tasks/`（阶段二）、`docs/remediation/`（阶段三） |

- **何时用 codearch-agents**：需要理解项目、撰写模块文档或为后续写测试/风险分析做准备时。
- **何时用 automated-ut-agents**：需要实际做可测试性重构、补充单测时。
- **何时用 agentic-code-assurance**：需要系统化发现潜在 BUG、验证并修复，且希望复用或先建立工程知识库时。

### 项目根目录结构

```
codearch-agents/          # 代码架构分析工作流
automated-ut-agents/      # 可测试性重构工作流
agentic-code-assurance/   # 自动化 BUG 分析端到端工作流（代码认知 → 风险评估 → BUG 修复）
docker/                   # 构建 Agent 运行环境
claude_settings/          # ClaudeCode 配置（可选）
opencode_settings/        # OpenCode 配置（可选）
```

## 快速开始

### 前置要求

- Docker 已安装并运行
- 具有 sudo 权限（用于设置目录权限）
- 需要重构的 C/C++ 项目

### 步骤 1: 构建 Docker 镜像

首先，使用 `docker/` 目录下的 Dockerfile 构建包含 ClaudeCode、OpenCode 和完整 C/C++ 开发环境的镜像：

```bash
cd docker
docker build -t claude-code:0.0.2 -f dockerfile .
```

镜像包含：
- **ClaudeCode**: 最新版本的 `@anthropic-ai/claude-code`
- **OpenCode**: 最新版本的 `opencode-ai`（可选使用的 Agent 环境）
- **C/C++ 开发工具链**: gcc, g++, clang, cmake, make, ninja-build 等
- **调试工具**: gdb, lldb, valgrind, strace 等
- **静态分析工具**: clang-tidy, cppcheck 等
- **测试框架**: Google Test, Google Mock
- **其他开发工具**: git, zsh, fzf 等

### 步骤 2: 准备项目目录

先确保下面的两个目录和文件是存在的，使用`docker.sh`的时候需要用。如果你会自己配置opencode和claudecode的环境，不需要特别看下面的内容。自己想办法启动镜像，挂载自己的目录就行了。

- 目录：`${SCRIPT_DIR}/claude_settings/.claude`
- 文件：`${SCRIPT_DIR}/claude_settings/.claude.json`
- 目录：`${SCRIPT_DIR}/opencode_settings/.config`

这些文件主要是用来存储默认情况下OpenCode和Claude的配置环境。

将需要重构的项目下载或克隆到本地，作为当前项目的一个子文件夹。例如：

```bash
# 假设当前项目在 /path/to/project/refactor-skills-for-tests
# 将目标项目克隆到子目录
git clone <your-project-url> target-project
# 或者
cd /path/to/your/project
```

### 步骤 3: 启动容器并配置环境

使用 `docker.sh` 脚本启动容器并进入开发环境：

```bash
# 进入项目子目录（相对路径或绝对路径）
./docker.sh target-project

# 或者使用绝对路径
./docker.sh /path/to/project/your-project
```

脚本会自动：
- 设置目录权限（确保容器内 node 用户可访问）
- 挂载项目目录到容器内
- 挂载 ClaudeCode 配置目录（`claude_settings/`）
- 挂载 OpenCode 配置目录（`opencode_settings/.config`）
- 挂载 Git 配置（SSH 密钥、gitconfig 等）
- 启动交互式 zsh shell

### 步骤 4: 配置 Agent 使用工作流

在容器内，使用 **ClaudeCode** 或 **OpenCode** 时，根据目标选择要加载的工作流：

- **做架构分析**：让 Agent 加载 `codearch-agents/Workflow.md`
- **做可测试性重构**：让 Agent 加载 `automated-ut-agents/Workflow.md`
- **做自动化 BUG 分析**：让 Agent 加载 `agentic-code-assurance/Workflow.md`

各工作流均包含决策树/阶段编排、阶段文档与按需加载的技能文档，详见下方「工作流说明」。

## 工作流说明

### 工作流 1：codearch-agents（代码架构分析）

**入口**：`codearch-agents/Workflow.md`

**决策树**（从 Q1 开始，首个「否」进入对应阶段）：

1. **Q1**：是否存在满足约定结构的总体介绍报告（含信息来源汇总）？  
   - 否 → Phase 01: 工程概览与主流程  
   - 是 → 继续 Q2
2. **Q2**：是否已为主要模块生成独立模块报告（含使用示例）且总体报告中已引用？  
   - 否 → Phase 02: 模块与依赖分析  
   - 是 → 继续 Q2b / Q2c / Q3
3. **Q2b**：当前模块划分是否已稳定、合理？  
   - 否 → 执行分解审视，按结果回到 Phase 01 或 Phase 02  
   - 是 → 继续 Q2c
4. **Q2c**：是否已对高复杂度模块完成验证？  
   - 否 → 先看 Q3，再执行验证  
   - 是 → 继续 Q3
5. **Q3**：构建与测试是否已文档化且可执行？  
   - 否 → Phase 03: 编译与测试体系  
   - 是 → Phase 04: 报告产出与引用

**核心文档结构**：

```
codearch-agents/
├── Workflow.md                 # 主入口
├── phases/
│   ├── 01-overview.md         # 工程概览与主流程
│   ├── 02-modules.md          # 模块与依赖分析
│   ├── 03-build-and-tests.md  # 编译与测试体系
│   └── 04-reports.md          # 报告产出与引用
├── skills/
│   ├── skill-01-overview.md
│   ├── skill-02-modules.md
│   ├── skill-03-build-tests.md
│   └── skill-04-reports.md
├── definitions/                # 复杂度、验证等级、产出结构、分解审视等
└── templates/                  # overall-report, module-report
```

完整判断依据与索引见 [codearch-agents/Workflow.md](codearch-agents/Workflow.md)。

### 工作流 2：automated-ut-agents（可测试性重构）

**入口**：`automated-ut-agents/Workflow.md`

**决策树**（从 Q1 开始，首个「否」进入对应阶段）：

1. **Q1**：工程是否已建立门禁基线？
   - 否 → 执行 Phase 01: 基线准备
   - 是 → 继续 Q2
2. **Q2**：是否已完成工程分析？
   - 否 → 执行 Phase 02: 工程分析
   - 是 → 继续 Q3
3. **Q3**：是否已建立模块优先级队列？
   - 否 → 执行 Phase 03: 优先级排序
   - 是 → 进入 Phase 04: 迭代循环

**核心文档结构**：

```
automated-ut-agents/
├── Workflow.md                 # 主入口
├── phases/
│   ├── 01-setup.md            # 基线准备
│   ├── 02-analysis.md         # 工程分析
│   ├── 03-prioritization.md   # 优先级排序
│   └── 04-iteration.md        # 迭代循环
├── skills/                     # 14 个技能（baseline, analysis, prioritization, ...）
├── definitions/               # 全局约束、状态定义、测试分层
├── decisions/                 # 可测试性决策、门禁失败决策
└── templates/                 # module-card, backlog-entry, question-set 等
```

### 工作流 3：agentic-code-assurance（自动化 BUG 分析）

**入口**：`agentic-code-assurance/Workflow.md`

本工作流为**端到端三阶段**流水线，按顺序执行：代码认知 → 风险评估 → BUG 修复。阶段一含编译与测试门禁，未通过则中止；阶段二、三可根据前置产出跳过或重跑；阶段三完成后可经迭代深化重新进入阶段二。

**三阶段与子入口**：

| 阶段 | 说明 | 子工作流入口 |
|------|------|--------------|
| **1 代码认知** | 建立/更新工程知识库（总体报告、模块报告、构建与测试文档） | [1-code-cognition/Workflow.md](agentic-code-assurance/1-code-cognition/Workflow.md) |
| **2 风险评估** | 加载知识库，路径追踪审查，输出疑似 BUG 任务列表 | [2-risk-assessment/Workflow.md](agentic-code-assurance/2-risk-assessment/Workflow.md) |
| **3 BUG 修复** | 编写验证测试、修复并通过测试、回归与归档 | [3-bug-remediation/Workflow.md](agentic-code-assurance/3-bug-remediation/Workflow.md) |

**核心文档结构**：

```
agentic-code-assurance/
├── Workflow.md                 # 总入口：端到端编排、契约、反馈与迭代机制
├── definitions/                # 执行原则、反馈操作约定
├── 1-code-cognition/           # 代码认知（与 codearch 产出结构兼容）
│   ├── Workflow.md
│   ├── phases/ & skills/ & definitions/ & templates/
├── 2-risk-assessment/          # 风险评估
│   ├── Workflow.md
│   ├── phases/ & skills/ & definitions/ & templates/
└── 3-bug-remediation/          # BUG 确认与修复
    ├── Workflow.md
    ├── phases/ & skills/ & definitions/ & templates/
```

完整编排、输入输出契约、反馈机制与迭代深化规则见 [agentic-code-assurance/Workflow.md](agentic-code-assurance/Workflow.md)。

### 使用方式

1. **启动容器后**，在容器内打开 ClaudeCode 或 OpenCode。
2. **根据目标告诉 Agent**：
   - 架构分析：例如「请按照 `codearch-agents/Workflow.md` 中的工作流执行代码架构分析」
   - 可测试性重构：例如「请按照 `automated-ut-agents/Workflow.md` 中的工作流开始执行可测试性重构」
   - 自动化 BUG 分析：例如「请按照 `agentic-code-assurance/Workflow.md` 中的工作流执行自动化 BUG 分析」
3. **Agent 会自动**：
   - 读取对应工作流的 `Workflow.md` 作为入口
   - 根据决策树/阶段编排判断当前工程状态
   - 进入对应的阶段文档（或子工作流入口）
   - 按需加载技能文档执行具体任务

## 配置说明

### Docker 镜像配置

镜像名称和版本在 `docker.sh` 中配置：

```bash
IMAGE_NAME="claude-code:0.0.2"
CONTAINER_USER="node"
CONTAINER_USER_UID=1000
CONTAINER_USER_GID=1000
```

### ClaudeCode 配置

ClaudeCode 的配置目录挂载在：
- 容器内: `/home/node/.claude`
- 宿主机: `./claude_settings/.claude`

首次使用前，可以在宿主机创建 `claude_settings/.claude` 目录并配置相关设置。

### OpenCode 配置

OpenCode 的配置目录挂载在：
- 容器内: `/home/node/.config`
- 宿主机: `./opencode_settings/.config`

首次使用前，可以在宿主机创建 `opencode_settings/.config` 目录并配置相关设置。

## 注意事项

1. **权限设置**: `docker.sh` 脚本会尝试使用 sudo 修改挂载目录的权限。如果失败，请手动执行：
   ```bash
   sudo chown -R 1000:1000 <your-project-path>
   ```

2. **网络配置**: 容器使用 `--network=host` 模式，可以直接访问宿主机网络。

3. **资源限制**: 容器默认共享内存为 32GB，可根据需要调整 `docker.sh` 中的 `--shm-size` 参数。

4. **Git 配置**: 容器的 Git 配置（SSH 密钥、gitconfig）会从宿主机的 `~/.ssh` 和 `~/.gitconfig` 挂载（只读）。

## 故障排查

### 容器无法启动

- 检查 Docker 是否运行: `docker ps`
- 检查镜像是否存在: `docker images | grep claude-code`
- 检查路径是否正确: 确保 `docker.sh` 的参数路径存在

### 权限问题

- 确保挂载目录对 node 用户（UID 1000）可读写
- 检查 `docker.sh` 中的权限设置是否正确

### ClaudeCode / OpenCode 无法加载工作流

- 确保所选用工作流入口存在：`codearch-agents/Workflow.md`、`automated-ut-agents/Workflow.md` 或 `agentic-code-assurance/Workflow.md`（路径相对于挂载的项目根目录）
- 检查对应配置目录是否正确挂载：ClaudeCode 使用 `claude_settings/.claude`，OpenCode 使用 `opencode_settings/.config`
- 在容器内验证：`ls -la <挂载路径>/codearch-agents/Workflow.md`、`<挂载路径>/automated-ut-agents/Workflow.md` 或 `<挂载路径>/agentic-code-assurance/Workflow.md`

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工作流系统。