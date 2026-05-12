#!/bin/bash
# OpenCode 回滚脚本：从备份恢复 OpenCode 配置
#
# 用法: ./rollback-opencode.sh [timestamp]
#   不带参数: 交互式选择备份
#   带参数: 直接恢复到指定时间戳的备份

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"

# 目标路径
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
        local opencode_mark=""

        if [ -d "$BACKUP_DIR/$backup/opencode" ]; then
            opencode_mark="[opencode]"
        else
            continue
        fi

        printf "  %2d. %s %s\n" "$i" "$backup" "$opencode_mark"
        ((i++))
    done

    if [ $i -eq 1 ]; then
        echo -e "${RED}没有找到可用的 OpenCode 备份${NC}"
        exit 1
    fi

    echo ""
}

select_backup() {
    local backups=($(ls -1 "$BACKUP_DIR" 2>/dev/null | sort -r))
    local opencode_backups=()

    for backup in "${backups[@]}"; do
        if [ -d "$BACKUP_DIR/$backup/opencode" ]; then
            opencode_backups+=("$backup")
        fi
    done

    if [ ${#opencode_backups[@]} -eq 0 ]; then
        echo -e "${RED}没有找到可用的 OpenCode 备份${NC}"
        exit 1
    fi

    read -p "请选择要恢复的备份编号 (1-${#opencode_backups[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#opencode_backups[@]} ]; then
        echo -e "${RED}无效的选择${NC}"
        exit 1
    fi

    SELECTED_BACKUP="${opencode_backups[$((choice-1))]}"
}

confirm_restore() {
    local backup_name="$1"

    echo ""
    echo -e "${YELLOW}警告: 恢复操作将覆盖当前配置${NC}"
    echo "备份: $backup_name"
    echo ""

    # 显示将要恢复的内容
    local opencode_backup="$BACKUP_DIR/$backup_name/opencode"

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

    local opencode_backup="$backup_path/opencode"

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

echo "=== OpenCode 回滚脚本 ==="
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
        if [ ! -d "$BACKUP_DIR/$SELECTED_BACKUP/opencode" ]; then
            echo -e "${RED}错误: 备份 '$SELECTED_BACKUP' 不存在或没有 OpenCode 备份${NC}"
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

restore_opencode "$BACKUP_PATH/opencode"

echo ""
echo "================================"
echo -e "${GREEN}回滚完成${NC}"
echo "从备份恢复: $SELECTED_BACKUP"
echo ""
echo "当前配置位置:"
echo "  - OpenCode:     $OPENCODE_DIR"