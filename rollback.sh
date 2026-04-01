#!/bin/bash

# 回滚脚本：从备份恢复 Claude Code 和 OpenCode 配置
#
# 用法: ./rollback.sh [timestamp]
#   不带参数: 交互式选择备份
#   带参数: 直接恢复到指定时间戳的备份

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"

# 目标路径
CLAUDE_DIR="$HOME/.claude"
OPENCODE_DIR="$HOME/.config/opencode"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ==================== 函数定义 ====================

list_backups() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}错误: 备份目录不存在 $BACKUP_DIR${NC}"
        exit 1
    fi

    local backups=($(ls -1 "$BACKUP_DIR" 2>/dev/null | sort -r))

    if [ ${#backups[@]} -eq 0 ]; then
        echo -e "${RED}没有找到可用的备份${NC}"
        exit 1
    fi

    echo "可用的备份:"
    echo ""
    local i=1
    for backup in "${backups[@]}"; do
        local claudecode_mark=""
        local opencode_mark=""

        if [ -d "$BACKUP_DIR/$backup/claudecode" ]; then
            claudecode_mark="[claudecode]"
        fi
        if [ -d "$BACKUP_DIR/$backup/opencode" ]; then
            opencode_mark="[opencode]"
        fi

        printf "  %2d. %s %s %s\n" "$i" "$backup" "$claudecode_mark" "$opencode_mark"
        ((i++))
    done

    echo ""
}

select_backup() {
    local backups=($(ls -1 "$BACKUP_DIR" 2>/dev/null | sort -r))

    read -p "请选择要恢复的备份编号 (1-${#backups[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#backups[@]} ]; then
        echo -e "${RED}无效的选择${NC}"
        exit 1
    fi

    SELECTED_BACKUP="${backups[$((choice-1))]}"
}

confirm_restore() {
    local backup_name="$1"

    echo ""
    echo -e "${YELLOW}警告: 恢复操作将覆盖当前配置${NC}"
    echo "备份: $backup_name"
    echo ""

    # 显示将要恢复的内容
    local claudecode_backup="$BACKUP_DIR/$backup_name/claudecode"
    local opencode_backup="$BACKUP_DIR/$backup_name/opencode"

    if [ -d "$claudecode_backup" ]; then
        echo "[Claude Code] 将恢复:"
        [ -d "$claudecode_backup/agents" ] && echo "  - agents"
        [ -d "$claudecode_backup/commands" ] && echo "  - commands"
        [ -d "$claudecode_backup/skills" ] && echo "  - skills"
        [ -f "$claudecode_backup/settings.json" ] && echo "  - settings.json"
        [ -d "$claudecode_backup/plugins" ] && echo "  - plugins"
        [ -f "$claudecode_backup/plugins/installed_plugins.json" ] && echo "  - installed_plugins.json"
        [ -f "$claudecode_backup/plugins/known_marketplaces.json" ] && echo "  - known_marketplaces.json"
        [ -d "$claudecode_backup/plugins/cache/local" ] && echo "  - plugins/cache/local"
    fi

    if [ -d "$opencode_backup" ]; then
        echo "[OpenCode] 将恢复:"
        [ -d "$opencode_backup/agents" ] && echo "  - agents"
        [ -d "$opencode_backup/commands" ] && echo "  - commands"
        [ -d "$opencode_backup/skills" ] && echo "  - skills"
        [ -d "$opencode_backup/plugins" ] && echo "  - plugins"
        [ -f "$opencode_backup/opencode.json" ] && echo "  - opencode.json"
    fi

    echo ""
    read -p "确认恢复? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "已取消"
        exit 0
    fi
}

restore_claudecode() {
    local src="$1"

    if [ ! -d "$src" ]; then
        return 0
    fi

    echo ""
    echo "=== 恢复 Claude Code 配置 ==="

    mkdir -p "$CLAUDE_DIR"

    if [ -d "$src/agents" ]; then
        echo "[claudecode] 恢复 agents..."
        rm -rf "$CLAUDE_DIR/agents"
        cp -r "$src/agents" "$CLAUDE_DIR/"
    fi

    if [ -d "$src/commands" ]; then
        echo "[claudecode] 恢复 commands..."
        rm -rf "$CLAUDE_DIR/commands"
        cp -r "$src/commands" "$CLAUDE_DIR/"
    fi

    if [ -d "$src/skills" ]; then
        echo "[claudecode] 恢复 skills..."
        rm -rf "$CLAUDE_DIR/skills"
        cp -r "$src/skills" "$CLAUDE_DIR/"
    fi

    if [ -d "$src/plugins" ]; then
        echo "[claudecode] 恢复 plugins..."
        rm -rf "$CLAUDE_DIR/plugins"
        cp -r "$src/plugins" "$CLAUDE_DIR/"
    fi

    if [ -f "$src/settings.json" ]; then
        echo "[claudecode] 恢复 settings.json..."
        cp "$src/settings.json" "$CLAUDE_DIR/settings.json"
    fi

    if [ -f "$src/plugins/installed_plugins.json" ]; then
        echo "[claudecode] 恢复 installed_plugins.json..."
        mkdir -p "$CLAUDE_DIR/plugins"
        cp "$src/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"
    fi

    if [ -f "$src/plugins/known_marketplaces.json" ]; then
        echo "[claudecode] 恢复 known_marketplaces.json..."
        mkdir -p "$CLAUDE_DIR/plugins"
        cp "$src/plugins/known_marketplaces.json" "$CLAUDE_DIR/plugins/known_marketplaces.json"
    fi

    if [ -d "$src/plugins/cache/local" ]; then
        echo "[claudecode] 恢复 plugins/cache/local..."
        rm -rf "$CLAUDE_DIR/plugins/cache/local"
        mkdir -p "$CLAUDE_DIR/plugins/cache"
        cp -r "$src/plugins/cache/local" "$CLAUDE_DIR/plugins/cache/"
    fi

    echo -e "${GREEN}[claudecode] 恢复完成${NC}"
}

restore_opencode() {
    local src="$1"

    if [ ! -d "$src" ]; then
        return 0
    fi

    echo ""
    echo "=== 恢复 OpenCode 配置 ==="

    mkdir -p "$OPENCODE_DIR"

    if [ -d "$src/agents" ]; then
        echo "[opencode] 恢复 agents..."
        rm -rf "$OPENCODE_DIR/agents"
        cp -r "$src/agents" "$OPENCODE_DIR/"
    fi

    if [ -d "$src/commands" ]; then
        echo "[opencode] 恢复 commands..."
        rm -rf "$OPENCODE_DIR/commands"
        cp -r "$src/commands" "$OPENCODE_DIR/"
    fi

    if [ -d "$src/skills" ]; then
        echo "[opencode] 恢复 skills..."
        rm -rf "$OPENCODE_DIR/skills"
        cp -r "$src/skills" "$OPENCODE_DIR/"
    fi

    if [ -d "$src/plugins" ]; then
        echo "[opencode] 恢复 plugins..."
        rm -rf "$OPENCODE_DIR/plugins"
        cp -r "$src/plugins" "$OPENCODE_DIR/"
    fi

    if [ -f "$src/opencode.json" ]; then
        echo "[opencode] 恢复 opencode.json..."
        cp "$src/opencode.json" "$OPENCODE_DIR/opencode.json"
    fi

    echo -e "${GREEN}[opencode] 恢复完成${NC}"
}

show_backup_detail() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"

    echo ""
    echo "备份详情: $backup_name"
    echo "================================"

    local claudecode_backup="$backup_path/claudecode"
    local opencode_backup="$backup_path/opencode"

    if [ -d "$claudecode_backup" ]; then
        echo ""
        echo "[Claude Code]"
        echo "  路径: $claudecode_backup"
        [ -d "$claudecode_backup/agents" ] && echo "  - agents: $(find "$claudecode_backup/agents" -type f 2>/dev/null | wc -l) 个文件"
        [ -d "$claudecode_backup/commands" ] && echo "  - commands: $(find "$claudecode_backup/commands" -type f 2>/dev/null | wc -l) 个文件"
        [ -d "$claudecode_backup/skills" ] && echo "  - skills: $(find "$claudecode_backup/skills" -type f 2>/dev/null | wc -l) 个文件"
        [ -f "$claudecode_backup/settings.json" ] && echo "  - settings.json: 存在"
        [ -f "$claudecode_backup/plugins/installed_plugins.json" ] && echo "  - installed_plugins.json: 存在"
        [ -f "$claudecode_backup/plugins/known_marketplaces.json" ] && echo "  - known_marketplaces.json: 存在"
        [ -d "$claudecode_backup/plugins/cache/local" ] && echo "  - plugins/cache/local: 存在"
    fi

    if [ -d "$opencode_backup" ]; then
        echo ""
        echo "[OpenCode]"
        echo "  路径: $opencode_backup"
        [ -d "$opencode_backup/agents" ] && echo "  - agents: $(find "$opencode_backup/agents" -type f 2>/dev/null | wc -l) 个文件"
        [ -d "$opencode_backup/commands" ] && echo "  - commands: $(find "$opencode_backup/commands" -type f 2>/dev/null | wc -l) 个文件"
        [ -d "$opencode_backup/skills" ] && echo "  - skills: $(find "$opencode_backup/skills" -type f 2>/dev/null | wc -l) 个文件"
        [ -d "$opencode_backup/plugins" ] && echo "  - plugins: $(find "$opencode_backup/plugins" -type f 2>/dev/null | wc -l) 个文件"
        [ -f "$opencode_backup/opencode.json" ] && echo "  - opencode.json: 存在"
    fi
}

# ==================== 主程序 ====================

echo "=== Claude Code / OpenCode 回滚脚本 ==="
echo ""

# 检查是否有备份目录
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}错误: 备份目录不存在 $BACKUP_DIR${NC}"
    exit 1
fi

# 处理命令行参数
if [ $# -eq 1 ]; then
    if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
        list_backups
        exit 0
    elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "用法: $0 [timestamp|选项]"
        echo ""
        echo "选项:"
        echo "  -l, --list     列出所有可用备份"
        echo "  -h, --help     显示帮助信息"
        echo ""
        echo "示例:"
        echo "  $0                    # 交互式选择备份"
        echo "  $0 20250401_120000    # 恢复到指定时间戳的备份"
        exit 0
    else
        # 直接指定时间戳
        SELECTED_BACKUP="$1"
        if [ ! -d "$BACKUP_DIR/$SELECTED_BACKUP" ]; then
            echo -e "${RED}错误: 备份 '$SELECTED_BACKUP' 不存在${NC}"
            echo "可用备份:"
            list_backups
            exit 1
        fi
    fi
else
    # 交互式选择
    list_backups
    select_backup
fi

# 显示备份详情
show_backup_detail "$SELECTED_BACKUP"

# 确认恢复
confirm_restore "$SELECTED_BACKUP"

# 执行恢复
BACKUP_PATH="$BACKUP_DIR/$SELECTED_BACKUP"

restore_claudecode "$BACKUP_PATH/claudecode"
restore_opencode "$BACKUP_PATH/opencode"

echo ""
echo "================================"
echo -e "${GREEN}回滚完成${NC}"
echo "从备份恢复: $SELECTED_BACKUP"
echo ""
echo "当前配置位置:"
echo "  - Claude Code:  $CLAUDE_DIR"
echo "  - OpenCode:     $OPENCODE_DIR"
