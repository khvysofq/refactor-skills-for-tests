# 可测试性重构工作流 - Agent Workflow

这是一个用于重构复杂 C/C++ 项目的 Agent Workflow 工作流系统。通过 ClaudeCode 或 OpenCode 和预定义的工作流，帮助自动化执行可测试性重构任务。

## 项目简介

本项目提供了一套完整的 Agent Workflow 工作流，用于指导 AI Agent 系统化地重构复杂 C/C++ 项目，提升项目的可测试性。工作流包含多个阶段和技能，从基线准备、工程分析、优先级排序到迭代重构，确保重构过程的可控性和可追溯性。

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

在容器内，使用 **ClaudeCode** 或 **OpenCode** 时，让 Agent 加载项目中的 `workflow/Workflow.md` 中定义的工作流。该工作流包含：

- **决策树**: 根据工程状态自动选择执行阶段
- **4 个主要阶段**:
  - Phase 01: 基线准备
  - Phase 02: 工程分析
  - Phase 03: 优先级排序
  - Phase 04: 迭代循环
- **13+ 个技能模块**: 涵盖从基线建立到重构完成的各个环节

## 工作流说明

### 工作流入口

工作流的主入口文档位于 `workflow/Workflow.md`。Agent 会根据以下决策树自动选择执行路径：

1. **Q1**: 工程是否已建立门禁基线？
   - 否 → 执行 Phase 01: 基线准备
   - 是 → 继续 Q2

2. **Q2**: 是否已完成工程分析？
   - 否 → 执行 Phase 02: 工程分析
   - 是 → 继续 Q3

3. **Q3**: 是否已建立模块优先级队列？
   - 否 → 执行 Phase 03: 优先级排序
   - 是 → 进入 Phase 04: 迭代循环

### 核心文档结构

```
workflow/
├── Workflow.md                 # 主入口文档（Agent 从这里开始）
├── phases/                     # 阶段文档
│   ├── 01-setup.md            # 基线准备
│   ├── 02-analysis.md         # 工程分析
│   ├── 03-prioritization.md   # 优先级排序
│   └── 04-iteration.md        # 迭代循环
├── skills/                     # 技能文档
│   ├── skill-01-baseline.md   # 工程基线与门禁准备
│   ├── skill-02-analysis.md   # 工程深度分析
│   ├── skill-03-prioritization.md  # 模块分级与优先级
│   └── ...                    # 其他技能
├── definitions/               # 定义文档
│   ├── constraints.md         # 全局约束
│   ├── states.md              # 状态定义
│   └── test_levels.md         # 测试分层
├── decisions/                 # 决策文档
│   ├── testability-decision.md
│   └── gate-failure-decision.md
└── templates/                 # 模板文档
    ├── module-card.md
    ├── backlog-entry.md
    └── ...
```

### 使用方式

1. **启动容器后**，在容器内打开 ClaudeCode 或 OpenCode。
2. **告诉 Agent**："请按照 `workflow/Workflow.md` 中的工作流开始执行可测试性重构"。
3. **Agent 会自动**：
   - 读取 `workflow/Workflow.md` 作为入口
   - 根据决策树判断当前工程状态
   - 进入对应的阶段文档
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

- 确保 `workflow/Workflow.md` 文件存在（在挂载的项目路径下）
- 检查对应配置目录是否正确挂载：ClaudeCode 使用 `claude_settings/.claude`，OpenCode 使用 `opencode_settings/.config`
- 在容器内验证文件路径: `ls -la <挂载路径>/workflow/Workflow.md`

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工作流系统。