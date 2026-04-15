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
CLAUDE_BACKUP_DIR="$TIMED_BACKUP_DIR/claudecode"
OPENCODE_BACKUP_DIR="$TIMED_BACKUP_DIR/opencode"
mkdir -p "$CLAUDE_BACKUP_DIR"
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

# 备份 Claude Code (~/.claude) 配置
backup_if_exists "$CLAUDE_DIR/agents" "$CLAUDE_BACKUP_DIR" "~/.claude/agents"
backup_if_exists "$CLAUDE_DIR/commands" "$CLAUDE_BACKUP_DIR" "~/.claude/commands"
backup_if_exists "$CLAUDE_DIR/skills" "$CLAUDE_BACKUP_DIR" "~/.claude/skills"
# 备份 marketplace（如果存在）
if [ -d "$CLAUDE_DIR/plugins/marketplaces/local" ]; then
    echo "[备份] ~/.claude/plugins/marketplaces/local..."
    mkdir -p "$CLAUDE_BACKUP_DIR/plugins/marketplaces"
    cp -r "$CLAUDE_DIR/plugins/marketplaces/local" "$CLAUDE_BACKUP_DIR/plugins/marketplaces/" 2>/dev/null || true
fi

# 备份 claudecode plugins 相关 JSON 文件
if [ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]; then
    echo "[备份] ~/.claude/plugins/installed_plugins.json..."
    mkdir -p "$CLAUDE_BACKUP_DIR/plugins"
    cp "$CLAUDE_DIR/plugins/installed_plugins.json" "$CLAUDE_BACKUP_DIR/plugins/installed_plugins.json"
fi

if [ -f "$CLAUDE_DIR/plugins/known_marketplaces.json" ]; then
    echo "[备份] ~/.claude/plugins/known_marketplaces.json..."
    mkdir -p "$CLAUDE_BACKUP_DIR/plugins"
    cp "$CLAUDE_DIR/plugins/known_marketplaces.json" "$CLAUDE_BACKUP_DIR/plugins/known_marketplaces.json"
fi

# 备份 claudecode plugins cache/local 目录
if [ -d "$CLAUDE_DIR/plugins/cache/local" ]; then
    echo "[备份] ~/.claude/plugins/cache/local..."
    mkdir -p "$CLAUDE_BACKUP_DIR/plugins/cache"
    cp -r "$CLAUDE_DIR/plugins/cache/local" "$CLAUDE_BACKUP_DIR/plugins/cache/" 2>/dev/null || true
fi

# 备份 claudecode settings.json（如果存在）
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    echo "[备份] ~/.claude/settings.json..."
    cp "$CLAUDE_DIR/settings.json" "$CLAUDE_BACKUP_DIR/settings.json"
fi

# 备份 claudecode CLAUDE.md（如果存在）
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    echo "[备份] ~/.claude/CLAUDE.md..."
    cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_BACKUP_DIR/CLAUDE.md"
fi

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

# ==================== 发布到 Claude Code (~/.claude) ====================
echo "=== 发布到 Claude Code (~/.claude) ==="

mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"

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

# 发布 Claude Code CLAUDE.md
LOCAL_CC_CLAUDE_MD="$SCRIPT_DIR/config/claudecode/CLAUDE.md"
if [ -f "$LOCAL_CC_CLAUDE_MD" ]; then
    echo "[claude] 发布 CLAUDE.md..."
    cp "$LOCAL_CC_CLAUDE_MD" "$CLAUDE_DIR/CLAUDE.md"
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
    # claude plugin install ralph-loop@local 2>/dev/null || true
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
