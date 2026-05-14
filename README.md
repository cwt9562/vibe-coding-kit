# vibe-coding-kit

面向 [Claude Code](https://code.claude.com) 和 [OpenCode](https://opencode.ai) 的扩展集合，通过 Agents、Skills、Commands 和 Plugins 提升 AI 编程助手的体验与效率。

---

## 特性

### 多 Agent 协作
主对话 Agent 只读不写，由子 Agent 负责写代码。这样既能节省上下文空间，也能避免主对话被代码操作污染。

### Windows 消息提醒
集成 Windows 系统通知，任务完成、出错等场景自动弹窗提示，不用时刻盯着终端。

### 固定 settings.json 配置
预设并锁定 `.claude/settings.json` 中的关键配置项，发布时自动同步，保持体验一致。

### 智能 Git 提交
自定义 `/commit` 指令，自动生成符合规范的 git 提交信息，并支持按文件自动拆分为多个提交。

---

## 目录结构

```
vibe-coding-kit/
├── claudecode/          # Claude Code 配置
│   ├── agents/          # SubAgent 定义（专业角色）
│   ├── bin/             # 启动脚本
│   ├── commands/        # Command 定义（CLI 增强）
│   ├── config/          # Claude Code 设置
│   ├── mcp/             # MCP (Model Context Protocol) 扩展
│   ├── plugins/         # 插件扩展
│   ├── rules/           # 代码规则与约束
│   └── skills/          # Skill 定义（扩展 AI 能力）
├── docs/                # 文档
├── opencode/            # OpenCode 配置
│   ├── agents/          # SubAgent 定义（专业角色）
│   ├── bin/             # 启动脚本
│   ├── commands/        # Command 定义（CLI 增强）
│   ├── config/          # OpenCode 设置
│   ├── mcp/             # MCP (Model Context Protocol) 扩展
│   ├── plugins/         # 插件扩展
│   ├── rules/           # 代码规则与约束
│   └── skills/          # Skill 定义（扩展 AI 能力）
├── CLAUDE.md
├── publish.sh           # 发布脚本（Claude Code）
├── publish-opencode.sh  # 发布脚本（OpenCode）
├── rollback.sh          # 回滚脚本（Claude Code）
└── rollback-opencode.sh # 回滚脚本（OpenCode）
```

---

## 快速开始

### 1. 克隆仓库

```bash
git clone <repo-url> ~/vibe-coding-kit
cd ~/vibe-coding-kit
```

### 2. 发布配置

```bash
# 发布 Claude Code 配置
./publish.sh

# 发布 OpenCode 配置
./publish-opencode.sh
```

脚本会自动：
- 备份现有配置到 `backup/<timestamp>/`
- 将 `agents`、`commands`、`skills`、`plugins`、`config` 同步到对应目标目录
- 合并 `settings.json`（Claude Code）或 `opencode.json`（OpenCode），保留已有配置

### 3. 开始使用

发布完成后，启动脚本已安装到 `~/.local/bin`，直接在终端中使用：

```bash
# 启动 Claude Code，并默认开启 --dangerously-skip-permissions
cc

# 启动 OpenCode
oc
```


## 回滚配置

每次发布前会自动备份当前配置到 `backup/<timestamp>/` 目录。如需回退：

### 交互式回滚

```bash
# 列出可用备份并选择恢复
./rollback.sh               # Claude Code
./rollback-opencode.sh      # OpenCode
```

### 指定时间戳回滚

```bash
./rollback.sh 20250401_234052
./rollback-opencode.sh 20250401_234052
```

### 列出所有可用备份

```bash
./rollback.sh -l
./rollback-opencode.sh -l
```

### 备份目录结构

```
backup/
└── 20250401_234052/
    ├── claudecode/          # Claude Code 备份
    │   ├── agents/
    │   ├── commands/
    │   ├── skills/
    │   ├── plugins/
    │   └── settings.json
    └── opencode/            # OpenCode 备份
        ├── agents/
        ├── commands/
        ├── skills/
        ├── plugins/
        └── opencode.json
```

---

## Agents

| Agent                              | 来源                   | 模型                  | 描述                                        |
| ---------------------------------- | ---------------------- | --------------------- | ------------------------------------------- |
| [captain](agents/captain.md)       | omo/Sisyphus           | Kimi                  | 主控调度，协调专家 Agent 完成复杂任务        |
| [assistant](agents/assistant.md)    | omo/Sisyphus-junior    | M2.7-highspeed        | 执行者，处理所有非代码任务（配置/文本/文档） |
| [developer](agents/developer.md)    | omo/Hephaestus         | M2.7                  | 执行者，专注代码实现，处理所有代码任务        |
| [explorer](agents/explorer.md)     | omo/Explore            | M2.7-highspeed        | 快速定位代码、理解代码结构                   |
| [oracle](agents/oracle.md)         | omo/Oracle             | Kimi                  | 守护监察，架构评审、风险评估、问题诊断       |
| [librarian](agents/librarian.md)   | omo/Librarian          | M2.7-highspeed        | 知识检索，获取外部知识和技术信息             |
| [designer](agents/designer.md)     | omo/Prometheus         | Kimi                  | 体验设计，UI/UX、图像分析和前端实现         |

---

## Commands

| Command                        | 描述                                          |
| ------------------------------ | --------------------------------------------- |
| [commit](commands/commit.md)   | 创建符合内部规范的 git 提交                   |
| [weeklog](commands/weeklog.md) | 本周工作总结：查询 git 提交记录，梳理工作成果 |

> **关于 `/weeklog` 的 YAML 配置**
> 
> 命令依赖 `weeklog.config.yaml` 文件来识别要统计的 git 仓库。
> 
> 配置格式示例：
> ```yaml
> projects:
>   - name: 项目名称A
>     repos:
>       - /path/to/repo1
>       - /path/to/repo2
> ```
> 
> 文件按以下优先级查找：
> 1) 当前工程根目录 → 2) 当前工程 `.claude/` → 3) 当前工程 `.opencode/` → 4) `~/.claude/` → 5) `~/.config/opencode/`
> 
> 若未找到配置文件，命令会自动检测：
> - 当前目录是否为 git 仓库 → 直接使用
> - 一级子目录中是否有 git 仓库 → 让用户选择
> - 最终在当前根目录自动生成 `weeklog.config.yaml`
> 

---

## Skills

| Skill                                          | 描述                                                     |
| ---------------------------------------------- | -------------------------------------------------------- |
| [agent-browser](skills/agent-browser/SKILL.md) | 浏览器自动化 CLI，用于网页交互、表单填写、数据抓取等任务 |

---

## Plugins

### Claude Code Plugins

| Plugin                      | 来源                                         | 描述                                                     |
| --------------------------- | -------------------------------------------- | ------------------------------------------------------- |
| comment-checker             | [omo](https://github.com/omo/oh-my-opencode) | 检测 Java/Vue/Shell 代码中的 AI 风格注释                |
| edit-error-recovery         | omo                                          | 监听 Edit 工具错误，注入恢复提醒                         |
| delegate-task-retry         | omo                                          | 监听 Task 工具错误，注入即时重试指导                     |
| question-label-truncator    | omo                                          | 在 AskUserQuestion 执行前自动截断过长的 option label     |
| windows-notification        | 本地开发                                     | 在事件触发时弹出 Windows 系统通知                         |
| ralph-loop                  | omo                                          | 自引用开发循环，让 Agent 自动继续工作（实验性）          |

### OpenCode Plugins

| Plugin                      | 来源                                                 | 描述                                              |
| --------------------------- | ---------------------------------------------------- | ------------------------------------------------- |
| user-agent                  | [elfgzp](https://github.com/elfgzp/opencode-configs) | 模拟 KimiCLI 请求头以支持用量翻倍活动             |
| edit-error-recovery         | omo                                                  | 监听 Edit 工具错误，注入恢复提醒                   |
| comment-checker             | omo                                                  | 检测 Java/Vue/Shell 代码中的 AI 风格注释           |
| compaction-context-injector | omo                                                  | 在 session compaction 时注入结构化摘要提示词       |
| delegate-task-retry         | omo                                                  | 监听 Task 工具错误，注入即时重试指导               |

> 更多插件开发细节请参考 [docs/plugin-development.md](docs/plugin-development.md)。

---

## 特别感谢

[everything-claude-code](https://github.com/affaan-m/everything-claude-code)  
[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)  
[oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)  

---

## License

MIT
