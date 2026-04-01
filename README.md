# vibe-coding-kit

面向 [Claude Code](https://code.claude.com) 和 [OpenCode](https://opencode.ai) 的扩展集合，通过 Agents、Skills、Commands 和 Plugins 提升 AI 编程助手的体验与效率。

---

## 特性

- **双端同步**：一套配置，同时发布到 Claude Code (`~/.claude`) 和 OpenCode (`~/.config/opencode`)
- **专业 Agent**：6 个预设子 Agent，覆盖调度、实现、探索、监察、检索、设计
- **实用 Commands**：内置 `commit`、`weeklog` 等高频 CLI 增强命令
- **增强 Plugins**：集成多模型 Hook 插件，修复、提示、拦截一应俱全
- **安全发布**：自动备份当前配置，支持一键回滚

---

## 目录结构

```
vibe-coding-kit/
├── agents/          # 子 Agent 定义
├── commands/        # Command 定义（CLI 增强）
├── config/          # 工具配置（claudecode / opencode）
├── mcp/             # MCP (Model Context Protocol) 扩展
├── plugins/         # 插件扩展
│   ├── claudecode/  # Claude Code 插件
│   └── opencode/    # OpenCode 插件
├── rules/           # 代码规则与约束
├── skills/          # Skill 定义（扩展 AI 能力）
├── docs/            # 文档
├── publish.sh       # 发布脚本
└── rollback.sh      # 回滚脚本
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
./publish.sh
```

脚本会自动：
- 备份现有的 `~/.claude` 和 `~/.config/opencode` 配置到 `backup/<timestamp>/`
- 将 `agents`、`commands`、`skills`、`plugins`、`config` 同步到对应目标目录
- 合并 `settings.json` / `opencode.json`，保留已有的其他配置

### 3. 回滚配置

```bash
# 交互式选择备份回滚
./rollback.sh

# 或指定时间戳直接回滚
./rollback.sh 20250401_234052

# 列出所有可用备份
./rollback.sh -l
```

---

## Agents

| Agent                            | 描述                                   |
| -------------------------------- | -------------------------------------- |
| [captain](agents/captain.md)     | 主控调度，协调专家 Agent 完成复杂任务  |
| [developer](agents/developer.md) | 快速实现专家，执行明确的任务规格       |
| [explorer](agents/explorer.md)   | 快速定位代码、理解代码结构             |
| [oracle](agents/oracle.md)       | 守护监察，架构评审、风险评估、问题诊断 |
| [librarian](agents/librarian.md) | 知识检索，获取外部知识和技术信息       |
| [designer](agents/designer.md)   | 体验设计，UI/UX 设计和前端实现指导     |

---

## Commands

| Command                        | 描述                                          |
| ------------------------------ | --------------------------------------------- |
| [commit](commands/commit.md)   | 创建符合内部规范的 git 提交                   |
| [weeklog](commands/weeklog.md) | 本周工作总结：查询 git 提交记录，梳理工作成果 |

---

## Skills

| Skill                                          | 描述                                                     |
| ---------------------------------------------- | -------------------------------------------------------- |
| [agent-browser](skills/agent-browser/SKILL.md) | 浏览器自动化 CLI，用于网页交互、表单填写、数据抓取等任务 |

---

## Plugins

### Claude Code Plugins

| Plugin                      | 来源                                         | 描述                                                 |
| --------------------------- | -------------------------------------------- | ---------------------------------------------------- |
| comment-checker             | [omo](https://github.com/omo/oh-my-opencode) | 检测 Java/Vue/Shell 代码中的 AI 风格注释             |
| edit-error-recovery         | omo                                          | 监听 Edit 工具错误，注入恢复提醒                     |
| delegate-task-retry         | omo                                          | 监听 Task 工具错误，注入即时重试指导                 |
| question-label-truncator    | omo                                          | 在 AskUserQuestion 执行前自动截断过长的 option label |
| compaction-context-injector | omo                                          | 在 session compaction 时注入结构化摘要提示词         |

### OpenCode Plugins

| Plugin     | 来源                                                 | 描述                                  |
| ---------- | ---------------------------------------------------- | ------------------------------------- |
| user-agent | [elfgzp](https://github.com/elfgzp/opencode-configs) | 模拟 KimiCLI 请求头以支持用量翻倍活动 |

> 更多插件开发细节请参考 [docs/plugin-development.md](docs/plugin-development.md)。

---

## 特别感谢

[everything-claude-code](https://github.com/affaan-m/everything-claude-code)  
[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)  
[oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)  

---

## License

MIT
