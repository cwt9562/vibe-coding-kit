#!/bin/bash

# 同步脚本：发布 Claude Code 配置到 ~/.claude
#
# 目标：
#   ~/.claude/           - agents + skills + plugins (Claude Code 原生)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 目标路径
CLAUDE_DIR="$HOME/.claude"

# 本地配置
LOCAL_AGENT_CC_DIR="$SCRIPT_DIR/claudecode/agents"
LOCAL_PLUGIN_CC_DIR="$SCRIPT_DIR/claudecode/plugins"
LOCAL_SKILL_CC_DIR="$SCRIPT_DIR/claudecode/skills"
LOCAL_CC_CONFIG="$SCRIPT_DIR/claudecode/config/settings.json"

echo "=== Claude Code 发布脚本 ==="
echo "时间戳: $TIMESTAMP"
echo ""

# ==================== 备份阶段 ====================
TIMED_BACKUP_DIR="$BACKUP_DIR/$TIMESTAMP"
CLAUDE_BACKUP_DIR="$TIMED_BACKUP_DIR/claudecode"
mkdir -p "$CLAUDE_BACKUP_DIR"

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

echo ""

# ==================== 发布到 Claude Code (~/.claude) ====================
echo "=== 发布到 Claude Code (~/.claude) ==="

mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/skills"

if [ -d "$LOCAL_AGENT_CC_DIR" ]; then
    echo "[claude] 发布 agents..."
    cp -r "$LOCAL_AGENT_CC_DIR/"* "$CLAUDE_DIR/agents/"
fi

if [ -d "$LOCAL_SKILL_CC_DIR" ]; then
    echo "[claude] 发布 skills..."
    cp -r "$LOCAL_SKILL_CC_DIR/"* "$CLAUDE_DIR/skills/"
fi

# 发布 Claude Code CLAUDE.md
LOCAL_CC_CLAUDE_MD="$SCRIPT_DIR/claudecode/config/CLAUDE.md"
if [ -f "$LOCAL_CC_CLAUDE_MD" ]; then
    echo "[claude] 发布 CLAUDE.md..."
    cp "$LOCAL_CC_CLAUDE_MD" "$CLAUDE_DIR/CLAUDE.md"
fi

# 发布 Claude Code plugins (使用 CLI 命令)
LOCAL_CC_MARKETPLACE_DIR="$SCRIPT_DIR/claudecode/plugins/marketplaces/local"
if [ -d "$LOCAL_CC_MARKETPLACE_DIR" ]; then
    echo "[claude] 注册 local marketplace..."
    claude plugin marketplace remove local 2>/dev/null || true
    claude plugin marketplace add "$LOCAL_CC_MARKETPLACE_DIR"
    echo "[claude] 安装 plugins..."
    claude plugin install comment-checker@local 2>/dev/null || true
    claude plugin install edit-error-recovery@local 2>/dev/null || true
    claude plugin install delegate-task-retry@local 2>/dev/null || true
    claude plugin install windows-notification@local 2>/dev/null || true
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
        const localSettings = JSON.parse(fs.readFileSync(path.resolve(scriptDir, 'claudecode', 'config', 'settings.json'), 'utf8'));

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

        // 合并配置：env 字段追加合并（本地优先），其他字段直接覆盖
        const merged = { ...settings };
        for (const key of Object.keys(localSettings)) {
            if (key === 'env' && typeof settings[key] === 'object' && typeof localSettings[key] === 'object') {
                merged[key] = { ...settings[key], ...localSettings[key] };
            } else {
                merged[key] = localSettings[key];
            }
        }

        // 递归排序对象的键（数组元素顺序保持不变）
        function sortKeys(obj) {
            if (Array.isArray(obj)) return obj.map(sortKeys);
            if (obj && typeof obj === 'object') {
                return Object.keys(obj).sort().reduce((acc, k) => {
                    acc[k] = sortKeys(obj[k]);
                    return acc;
                }, {});
            }
            return obj;
        }

        fs.writeFileSync(settingsPath, JSON.stringify(sortKeys(merged), null, 2));
    "
else
    echo "[警告] 本地 claudecode/config/settings.json 不存在，跳过配置合并"
fi

# 发布 claudecode/bin/ 脚本到 ~/.local/bin
echo "[claude] 发布 bin 脚本..."
LOCAL_CC_BIN_DIR="$SCRIPT_DIR/claudecode/bin"
TARGET_BIN_DIR="$HOME/.local/bin"
if [ -d "$LOCAL_CC_BIN_DIR" ]; then
    mkdir -p "$TARGET_BIN_DIR"
    for file in "$LOCAL_CC_BIN_DIR"/*; do
        if [ -f "$file" ]; then
            cp -f "$file" "$TARGET_BIN_DIR/"
            chmod +x "$TARGET_BIN_DIR/$(basename "$file")"
            echo "  - $(basename "$file")"
        fi
    done
else
    echo "[警告] 本地 claudecode/bin 目录不存在，跳过"
fi

echo "[claude] 完成"
echo ""
echo "=== 完成 ==="
echo "备份位置: $TIMED_BACKUP_DIR"
echo ""
echo "发布目标:"
echo "  - Claude Code:  $CLAUDE_DIR"
