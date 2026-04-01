#!/bin/bash

# 同步脚本：分别发布到 Claude Code (~/.claude) 和 OpenCode (~/.config/opencode)
#
# 目标：
#   ~/.claude/           - agents + commands + skills + plugins (Claude Code 原生)
#   ~/.config/opencode/  - agents + commands + plugins + skills (OpenCode)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 目标路径
CLAUDE_DIR="$HOME/.claude"
OPENCODE_DIR="$HOME/.config/opencode"

# 本地配置
LOCAL_AGENT_DIR="$SCRIPT_DIR/agents"
LOCAL_COMMAND_DIR="$SCRIPT_DIR/commands"
LOCAL_PLUGIN_DIR="$SCRIPT_DIR/plugins/opencode"
LOCAL_CC_PLUGIN_DIR="$SCRIPT_DIR/plugins/claudecode"
LOCAL_SKILL_DIR="$SCRIPT_DIR/skills"
LOCAL_CONFIG="$SCRIPT_DIR/config/opencode/opencode.json"
LOCAL_CC_CONFIG="$SCRIPT_DIR/config/claudecode/settings.json"

echo "=== Claude Code / OpenCode 发布脚本 ==="
echo "时间戳: $TIMESTAMP"
echo ""

# ==================== 备份阶段 ====================
TIMED_BACKUP_DIR="$BACKUP_DIR/$TIMESTAMP"
mkdir -p "$TIMED_BACKUP_DIR"

backup_if_exists() {
    local src="$1"
    local name="$2"
    if [ -d "$src" ]; then
        echo "[备份] $name..."
        mkdir -p "$TIMED_BACKUP_DIR/$(basename "$src")"
        cp -r "$src/"* "$TIMED_BACKUP_DIR/$(basename "$src")/" 2>/dev/null || true
    fi
}

backup_if_exists "$CLAUDE_DIR/hooks" "~/.claude/hooks"
backup_if_exists "$CLAUDE_DIR/agents" "~/.claude/agents"
backup_if_exists "$CLAUDE_DIR/commands" "~/.claude/commands"
backup_if_exists "$CLAUDE_DIR/skills" "~/.claude/skills"
# 备份 plugins 目录（排除系统目录）
if [ -d "$CLAUDE_DIR/plugins" ]; then
    echo "[备份] ~/.claude/plugins (排除系统目录)..."
    mkdir -p "$TIMED_BACKUP_DIR/plugins"
    for item in "$CLAUDE_DIR/plugins"/*/; do
        item_name=$(basename "$item")
        # 跳过系统目录
        if [ "$item_name" != "cache" ] && [ "$item_name" != "marketplaces" ]; then
            cp -r "$item" "$TIMED_BACKUP_DIR/plugins/" 2>/dev/null || true
        fi
    done
fi
# 备份 marketplace（如果存在）
if [ -d "$CLAUDE_DIR/plugins/marketplaces/local" ]; then
    echo "[备份] ~/.claude/plugins/marketplaces/local..."
    mkdir -p "$TIMED_BACKUP_DIR/plugins/marketplaces"
    cp -r "$CLAUDE_DIR/plugins/marketplaces/local" "$TIMED_BACKUP_DIR/plugins/marketplaces/" 2>/dev/null || true
fi
# 备份 claudecode settings.json（如果存在）
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$CLAUDE_DIR/settings.json" "$TIMED_BACKUP_DIR/settings.json"
fi

backup_if_exists "$OPENCODE_DIR/agents" "~/.config/opencode/agents"
backup_if_exists "$OPENCODE_DIR/commands" "~/.config/opencode/commands"
backup_if_exists "$OPENCODE_DIR/skills" "~/.config/opencode/skills"

# 备份 opencode.json（如果存在）
if [ -f "$OPENCODE_DIR/opencode.json" ]; then
    cp "$OPENCODE_DIR/opencode.json" "$TIMED_BACKUP_DIR/opencode.json"
fi

echo ""

# ==================== 发布到 Claude Code (~/.claude) ====================
echo "=== 发布到 Claude Code (~/.claude) ==="

mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/commands"

if [ -d "$LOCAL_AGENT_DIR" ]; then
    echo "[claude] 发布 agents..."
    cp -r "$LOCAL_AGENT_DIR/"* "$CLAUDE_DIR/agents/"
fi

if [ -d "$LOCAL_COMMAND_DIR" ]; then
    echo "[claude] 发布 commands..."
    cp -r "$LOCAL_COMMAND_DIR/"* "$CLAUDE_DIR/commands/"
fi

if [ -d "$LOCAL_SKILL_DIR" ]; then
    echo "[claude] 发布 skills..."
    cp -r "$LOCAL_SKILL_DIR/"* "$CLAUDE_DIR/skills/"
fi

# 发布 Claude Code plugins (使用 CLI 命令)
LOCAL_CC_MARKETPLACE_DIR="$SCRIPT_DIR/plugins/claudecode/marketplaces/local"
if [ -d "$LOCAL_CC_MARKETPLACE_DIR" ]; then
    echo "[claude] 注册 local marketplace..."
    claude plugin marketplace remove local 2>/dev/null || true
    claude plugin marketplace add "$LOCAL_CC_MARKETPLACE_DIR"
    echo "[claude] 安装 plugins..."
    claude plugin install comment-checker@local 2>/dev/null || true
    claude plugin install edit-error-recovery@local 2>/dev/null || true
    claude plugin install delegate-task-retry@local 2>/dev/null || true
    claude plugin install question-label-truncator@local 2>/dev/null || true
fi

# 合并 settings.json 配置
if [ -f "$LOCAL_CC_CONFIG" ]; then
    echo "[claude] 合并 settings.json 配置..."
    node -e "
        const fs = require('fs');
        const path = require('path');
        const os = require('os');

        // 修复 Windows 路径格式
        let scriptDir = '$SCRIPT_DIR';
        if(scriptDir.startsWith('/d/')) scriptDir = 'D:/' + scriptDir.slice(3);

        // 读取本地配置
        const localSettings = JSON.parse(fs.readFileSync(path.resolve(scriptDir, 'config', 'claudecode', 'settings.json'), 'utf8'));

        // 目标路径
        const claudeDir = path.join(os.homedir(), '.claude');
        const settingsPath = path.join(claudeDir, 'settings.json');

        // 确保目录存在
        if (!fs.existsSync(claudeDir)) {
            fs.mkdirSync(claudeDir, { recursive: true });
        }

        // 读取现有配置（如果有）
        let settings = {};
        try {
            settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
        } catch(e) {
            console.log('创建新的 settings.json');
        }

        // 只替换本地配置中存在的字段，保留其他所有配置
        Object.assign(settings, localSettings);

        fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
    "
else
    echo "[警告] 本地 config/claudecode/settings.json 不存在，跳过配置合并"
fi

echo "[claude] 完成"
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
if [ -d "$LOCAL_AGENT_DIR" ]; then
    echo "[opencode] 发布 agents..."
    cp -r "$LOCAL_AGENT_DIR/"* "$OPENCODE_DIR/agents/"
fi

# 发布 commands
if [ -d "$LOCAL_COMMAND_DIR" ]; then
    echo "[opencode] 发布 commands..."
    cp -r "$LOCAL_COMMAND_DIR/"* "$OPENCODE_DIR/commands/"
fi

# 发布 plugins
if [ -d "$LOCAL_PLUGIN_DIR" ]; then
    echo "[opencode] 发布 plugins..."
    mkdir -p "$OPENCODE_DIR/plugins"
    cp -r "$LOCAL_PLUGIN_DIR/"* "$OPENCODE_DIR/plugins/"
fi

# 发布 skills
if [ -d "$LOCAL_SKILL_DIR" ]; then
    echo "[opencode] 发布 skills..."
    mkdir -p "$OPENCODE_DIR/skills"
    cp -r "$LOCAL_SKILL_DIR/"* "$OPENCODE_DIR/skills/"
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
        const localConfig = JSON.parse(fs.readFileSync(path.resolve(scriptDir, 'config', 'opencode', 'opencode.json'), 'utf8'));
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
    echo "[警告] 本地 config/opencode/opencode.json 不存在，跳过配置合并"
fi

echo ""
echo "=== 完成 ==="
echo "备份位置: $TIMED_BACKUP_DIR"
echo ""
echo "发布目标:"
echo "  - Claude Code:  $CLAUDE_DIR"
echo "  - OpenCode:     $OPENCODE_DIR"
