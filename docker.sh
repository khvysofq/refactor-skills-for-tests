#!/bin/bash

set -e

# ============================================
# 配置区域 - 可根据需要修改
# ============================================
IMAGE_NAME="claude-code:0.0.2"
CONTAINER_USER="node"
CONTAINER_USER_UID=1000
CONTAINER_USER_GID=1000

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

echo "============================================"
echo "脚本目录: ${SCRIPT_DIR}"
echo "HOME目录: ${HOME_DIR}"
echo "挂载路径: ${MOUNT_PATH}"
echo "容器镜像: ${IMAGE_NAME}"
echo "容器用户: ${CONTAINER_USER} (uid=${CONTAINER_USER_UID}, gid=${CONTAINER_USER_GID})"
echo "============================================"

# ============================================
# 修改挂载目录权限，确保容器内 node 用户可访问
# ============================================
echo "正在设置目录权限..."
sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} "${MOUNT_PATH}" || {
    echo "警告: 无法修改目录权限，容器内可能无法写入文件"
    echo "请手动执行: sudo chown -R ${CONTAINER_USER_UID}:${CONTAINER_USER_GID} ${MOUNT_PATH}"
}

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
    \
    `# === Git 配置挂载（只读）===` \
    -v "${HOME_DIR}/.ssh":"/home/${CONTAINER_USER}/.ssh:ro" \
    -v "${HOME_DIR}/.gitconfig":"/home/${CONTAINER_USER}/.gitconfig:ro" \
    -v "${HOME_DIR}/.git-credentials":"/home/${CONTAINER_USER}/.git-credentials:ro" \
    \
    ${IMAGE_NAME} /bin/zsh
