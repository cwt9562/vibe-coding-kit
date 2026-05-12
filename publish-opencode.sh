#!/bin/bash
# OpenCode 发布脚本：将本地配置同步到 ~/.config/opencode

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 目标路径
OPENCODE_DIR="$HOME/.config/opencode"

# 本地配置
LOCAL_AGENT_OC_DIR="$SCRIPT_DIR/opencode/agents"
LOCAL_COMMAND_OC_DIR="$SCRIPT_DIR/opencode/commands"
LOCAL_PLUGIN_OC_DIR="$SCRIPT_DIR/opencode/plugins"
LOCAL_SKILL_OC_DIR="$SCRIPT_DIR/opencode/skills"
LOCAL_CONFIG="$SCRIPT_DIR/opencode/config/opencode.json"

echo "=== OpenCode 发布脚本 ==="
echo "时间戳: $TIMESTAMP"
echo ""

# ==================== 备份阶段 ====================
TIMED_BACKUP_DIR="$BACKUP_DIR/$TIMESTAMP"
OPENCODE_BACKUP_DIR="$TIMED_BACKUP_DIR/opencode"
mkdir -p "$OPENCODE_BACKUP_DIR"

backup_if_exists() {
    local src="$1"
    local dest="$2"
    local name="$3"
    if [ -d "$src" ]; then
        echo "[备份] $name..."
        mkdir -p "$dest/$(basename "$src")"
        cp -r "$src/"* "$dest/$(basename "$src")/" 2>/dev/null || true
    fi
}

# 备份 OpenCode (~/.config/opencode) 配置
backup_if_exists "$OPENCODE_DIR/agents" "$OPENCODE_BACKUP_DIR" "~/.config/opencode/agents"
backup_if_exists "$OPENCODE_DIR/commands" "$OPENCODE_BACKUP_DIR" "~/.config/opencode/commands"
backup_if_exists "$OPENCODE_DIR/skills" "$OPENCODE_BACKUP_DIR" "~/.config/opencode/skills"
backup_if_exists "$OPENCODE_DIR/plugins" "$OPENCODE_BACKUP_DIR" "~/.config/opencode/plugins"

# 备份 opencode.json（如果存在）
if [ -f "$OPENCODE_DIR/opencode.json" ]; then
    echo "[备份] ~/.config/opencode/opencode.json..."
    cp "$OPENCODE_DIR/opencode.json" "$OPENCODE_BACKUP_DIR/opencode.json"
fi

echo ""

# ==================== 发布到 OpenCode (~/.config/opencode) ====================
echo "=== 发布到 OpenCode (~/.config/opencode) ==="

# 确保基础目录存在（修复 Windows 下路径可能不存在的问题）
mkdir -p "$OPENCODE_DIR"

mkdir -p "$OPENCODE_DIR/agents"
mkdir -p "$OPENCODE_DIR/commands"
mkdir -p "$OPENCODE_DIR/plugins"
mkdir -p "$OPENCODE_DIR/skills"

# 发布 agents
if [ -d "$LOCAL_AGENT_OC_DIR" ]; then
    echo "[opencode] 发布 agents..."
    cp -r "$LOCAL_AGENT_OC_DIR/"* "$OPENCODE_DIR/agents/"
fi

# 发布 commands
if [ -d "$LOCAL_COMMAND_OC_DIR" ]; then
    echo "[opencode] 发布 commands..."
    cp -r "$LOCAL_COMMAND_OC_DIR/"* "$OPENCODE_DIR/commands/"
fi

# 发布 plugins
if [ -d "$LOCAL_PLUGIN_OC_DIR" ]; then
    echo "[opencode] 发布 plugins..."
    mkdir -p "$OPENCODE_DIR/plugins"
    cp -r "$LOCAL_PLUGIN_OC_DIR/"* "$OPENCODE_DIR/plugins/"
fi

# 发布 skills
if [ -d "$LOCAL_SKILL_OC_DIR" ]; then
    echo "[opencode] 发布 skills..."
    mkdir -p "$OPENCODE_DIR/skills"
    cp -r "$LOCAL_SKILL_OC_DIR/"* "$OPENCODE_DIR/skills/"
fi

# 发布 opencode/bin/ 脚本到 ~/.local/bin
echo "[opencode] 发布 bin 脚本..."
LOCAL_OC_BIN_DIR="$SCRIPT_DIR/opencode/bin"
TARGET_BIN_DIR="$HOME/.local/bin"
if [ -d "$LOCAL_OC_BIN_DIR" ]; then
    mkdir -p "$TARGET_BIN_DIR"
    for file in "$LOCAL_OC_BIN_DIR"/*; do
        if [ -f "$file" ]; then
            cp -f "$file" "$TARGET_BIN_DIR/"
            chmod +x "$TARGET_BIN_DIR/$(basename "$file")"
            echo "  - $(basename "$file")"
        fi
    done
else
    echo "[警告] 本地 opencode/bin 目录不存在，跳过"
fi

# 合并 opencode.json 的 agent 和 plugins 配置
echo "[opencode] 合并 opencode.json 配置..."

if [ -f "$LOCAL_CONFIG" ]; then
    # 使用 Node.js 直接处理，避免 shell 传递 JSON 的格式问题
    node -e "
        const fs = require('fs');
        const path = require('path');
        const os = require('os');

        // 修复 Windows 路径格式
        let scriptDir = '$SCRIPT_DIR';
        if(scriptDir.startsWith('/d/')) scriptDir = 'D:/' + scriptDir.slice(3);

        // 读取本地配置
        const localConfig = JSON.parse(fs.readFileSync(path.resolve(scriptDir, 'opencode', 'config', 'opencode.json'), 'utf8'));
        const localAgents = localConfig.agent || {};
        const localPlugins = localConfig.plugin || {};

        // 目标路径
        const opencodeDir = path.join(os.homedir(), '.config', 'opencode');
        const configPath = path.join(opencodeDir, 'opencode.json');

        // 确保目录存在
        if (!fs.existsSync(opencodeDir)) {
            fs.mkdirSync(opencodeDir, { recursive: true });
        }

        // 读取现有配置（如果有）
        let config = {};
        try {
            config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        } catch(e) {
            console.log('创建新的 opencode.json');
        }

        // 只替换 agent 和 plugins 部分，保留其他所有配置
        config.agent = localAgents;
        config.plugin = localPlugins;

        fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    "
else
    echo "[警告] 本地 opencode/config/opencode.json 不存在，跳过配置合并"
fi

echo ""
echo "=== 完成 ==="
echo "备份位置: $TIMED_BACKUP_DIR"
echo "发布目标: OpenCode: $OPENCODE_DIR"
