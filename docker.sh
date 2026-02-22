#!/bin/bash

set -e

# ============================================
# 配置区域 - 可根据需要修改
# ============================================
# 若出现 "client version X is too new. Maximum supported API version is 1.42" 错误，
# 请取消下行注释以限制客户端使用的 API 版本：
# export DOCKER_API_VERSION=1.42
IMAGE_NAME="claude-code:0.0.4"
CONTAINER_USER="node"
CONTAINER_USER_UID=1000
CONTAINER_USER_GID=1000

# Docker socket 路径
DOCKER_SOCKET="/var/run/docker.sock"

# ============================================
# 使用说明
# ============================================
usage() {
    echo "用法: $0 <子路径>"
    echo ""
    echo "参数:"
    echo "  <子路径>    要挂载到容器内的工程子路径（相对于脚本所在目录或绝对路径）"
    echo ""
    echo "示例:"
    echo "  $0 src                    # 挂载 ./src 目录"
    echo "  $0 .                      # 挂载当前工程目录"
    echo "  $0 /mnt/local/project/tsinghua/papers/data   # 使用绝对路径"
    echo ""
    exit 1
}

# ============================================
# 参数检查
# ============================================
if [ $# -lt 1 ]; then
    usage
fi

SUB_PATH="$1"

# ============================================
# 路径处理
# ============================================
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
HOME_DIR="$(eval echo ~${USER})"
if [ -z "${HOME_DIR}" ]; then
    HOME_DIR="/root"
fi

# 如果是相对路径，转换为绝对路径（相对于脚本目录）
if [[ "${SUB_PATH}" != /* ]]; then
    MOUNT_PATH="${SCRIPT_DIR}/${SUB_PATH}"
else
    MOUNT_PATH="${SUB_PATH}"
fi

# 规范化路径（去除 .. 和 . ）
MOUNT_PATH="$(readlink -f "${MOUNT_PATH}")"

# 检查路径是否存在
if [ ! -d "${MOUNT_PATH}" ]; then
    echo "错误: 指定的路径不存在: ${MOUNT_PATH}"
    exit 1
fi

# ============================================
# Docker socket 检查和 GID 获取
# ============================================
DOCKER_GID=""
DOCKER_MOUNT_OPTS=""
if [ -S "${DOCKER_SOCKET}" ]; then
    # 获取 docker socket 的 GID
    DOCKER_GID=$(stat -c '%g' "${DOCKER_SOCKET}")
    echo "检测到 Docker socket: ${DOCKER_SOCKET} (GID=${DOCKER_GID})"
    DOCKER_MOUNT_OPTS="-v ${DOCKER_SOCKET}:${DOCKER_SOCKET}"
    
    # 如果存在 Docker 配置目录，也挂载它（用于 registry 认证等）
    if [ -d "${HOME_DIR}/.docker" ]; then
        DOCKER_MOUNT_OPTS="${DOCKER_MOUNT_OPTS} -v ${HOME_DIR}/.docker:/home/${CONTAINER_USER}/.docker:ro"
    fi
else
    echo "警告: Docker socket 不存在 (${DOCKER_SOCKET})，容器内将无法使用 Docker"
fi

echo "============================================"
echo "脚本目录: ${SCRIPT_DIR}"
echo "HOME目录: ${HOME_DIR}"
echo "挂载路径: ${MOUNT_PATH}"
echo "容器镜像: ${IMAGE_NAME}"
echo "容器用户: ${CONTAINER_USER} (uid=${CONTAINER_USER_UID}, gid=${CONTAINER_USER_GID})"
if [ -n "${DOCKER_GID}" ]; then
    echo "Docker GID: ${DOCKER_GID}"
fi
echo "============================================"

# ============================================
# 修改挂载目录权限，确保容器内 node 用户可访问
# ============================================
echo "正在设置目录权限..."
sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} "${MOUNT_PATH}" || {
    echo "警告: 无法修改目录权限，容器内可能无法写入文件"
    echo "请手动执行: sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} ${MOUNT_PATH}"
}

# 持久化配置挂载目录：先确保存在，再赋予容器用户权限
CLAUDE_SETTINGS_DIR="${SCRIPT_DIR}/claude_settings"
OPENCODE_SETTINGS_DIR="${SCRIPT_DIR}/opencode_settings"
for dir in "${CLAUDE_SETTINGS_DIR}/.claude" "${OPENCODE_SETTINGS_DIR}/.config"; do
    if [ ! -d "$dir" ]; then
        echo "创建配置目录: $dir"
        sudo mkdir -p "$dir"
    fi
done
if [ ! -f "${CLAUDE_SETTINGS_DIR}/.claude.json" ]; then
    sudo touch "${CLAUDE_SETTINGS_DIR}/.claude.json" 2>/dev/null || true
fi
echo "正在设置持久化配置目录权限..."
sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} "${CLAUDE_SETTINGS_DIR}" "${OPENCODE_SETTINGS_DIR}" 2>/dev/null || {
    echo "警告: 无法修改持久化配置目录权限，容器内可能无法写入 .claude / .claude.json / .config"
    echo "请手动执行: sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} ${CLAUDE_SETTINGS_DIR} ${OPENCODE_SETTINGS_DIR}"
}

# ============================================
# 构建 Docker 组参数
# ============================================
DOCKER_GROUP_OPTS=""
if [ -n "${DOCKER_GID}" ]; then
    DOCKER_GROUP_OPTS="--group-add ${DOCKER_GID}"
fi

# ============================================
# 启动容器
# ============================================
docker run -it --rm \
    --name "claude-code-dev-$$" \
    \
    `# === 安全和调试相关 ===` \
    --cap-add=SYS_PTRACE \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --security-opt seccomp=unconfined \
    --ulimit core=-1 \
    \
    `# === 网络配置 ===` \
    --network=host \
    \
    `# === 资源限制 ===` \
    --shm-size=32g \
    \
    `# === 用户配置 ===` \
    -u ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} \
    ${DOCKER_GROUP_OPTS} \
    \
    `# === 环境变量（来自 devcontainer.json）===` \
    -e NODE_OPTIONS="--max-old-space-size=4096" \
    -e CLAUDE_CONFIG_DIR="/home/${CONTAINER_USER}/.claude" \
    -e POWERLEVEL9K_DISABLE_GITSTATUS="true" \
    -e HOME="/home/${CONTAINER_USER}" \
    -e USER="${CONTAINER_USER}" \
    \
    `# === 工作目录挂载（镜像内外路径一致）===` \
    -v "${MOUNT_PATH}":"${MOUNT_PATH}" \
    -w "${MOUNT_PATH}" \
    \
    `# === 持久化配置挂载 ===` \
    -v "${SCRIPT_DIR}/claude_settings/.claude":"/home/${CONTAINER_USER}/.claude" \
    -v "${SCRIPT_DIR}/claude_settings/.claude.json":"/home/${CONTAINER_USER}/.claude.json" \
    -v "${SCRIPT_DIR}/opencode_settings/.config":"/home/${CONTAINER_USER}/.config" \
    \
    `# === Git 配置挂载（只读）===` \
    -v "${HOME_DIR}/.ssh":"/home/${CONTAINER_USER}/.ssh:ro" \
    -v "${HOME_DIR}/.gitconfig":"/home/${CONTAINER_USER}/.gitconfig:ro" \
    -v "${HOME_DIR}/.git-credentials":"/home/${CONTAINER_USER}/.git-credentials:ro" \
    \
    `# === Docker socket 挂载（用于容器内使用 Docker）===` \
    ${DOCKER_MOUNT_OPTS} \
    \
    ${IMAGE_NAME} /bin/zsh
