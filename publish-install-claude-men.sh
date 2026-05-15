echo "[claude] 安装 claude-mem..."

# 检测并安装 bun
if command -v bun > /dev/null 2>&1; then
    echo "[claude] bun 已安装，跳过"
else
    npm install -g bun
fi

# 检测并添加 claude-mem marketplace
if [ -d "$HOME/.claude/plugins/marketplaces/thedotmack" ]; then
    echo "[claude] claude-mem marketplace 已添加，跳过"
else
    claude plugin marketplace add thedotmack/claude-mem
fi

# 检测并安装 claude-mem 插件
if [ -d "$HOME/.claude/plugins/cache/thedotmack/claude-mem" ]; then
    echo "[claude] claude-mem 插件已安装，跳过"
else
    claude plugin install claude-mem
fi

echo "[claude] 配置 claude-mem settings..."
node -e "
    const fs = require('fs');
    const path = require('path');
    const os = require('os');

    const claudeMemDir = path.join(os.homedir(), '.claude-mem');
    const settingsPath = path.join(claudeMemDir, 'settings.json');

    // 确保目录存在
    if (!fs.existsSync(claudeMemDir)) {
        fs.mkdirSync(claudeMemDir, { recursive: true });
    }

    // 读取现有配置（如果有）
    let settings = {};
    try {
        settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
        console.log('读取现有 claude-mem settings.json');
    } catch(e) {
        console.log('创建新的 claude-mem settings.json');
    }

    // 设置 CLAUDE_MEM_MODE
    settings.CLAUDE_MEM_MODE = 'code--zh';

    fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
    console.log('CLAUDE_MEM_MODE 已设置为 code--zh');
"