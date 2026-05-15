# vibe-coding-kit

面向 [Claude Code](https://code.claude.com) 和 [OpenCode](https://opencode.ai) 的一站式增强配置包，内置多 Agent 协作、智能 Skill、自动化插件，clone 即用。

---

## 项目亮点

- **多 Agent 协作** — 主 Agent 只读调度，子 Agent 专注执行，上下文不污染
- **丰富的 Skill 生态** — 10+ 个开箱即用的 Skill（代码审查、周报、TDD、README 生成等）
- **双平台支持** — 同时支持 Claude Code 和 OpenCode，按需发布
- **一键发布与安全回滚** — publish.sh 发布，自动备份，rollback.sh 一键恢复

---

## 快速开始

```bash
git clone <repo-url> ~/vibe-coding-kit
cd ~/vibe-coding-kit

# 发布 Claude Code 配置到 ~/.claude
./publish.sh

# 或发布 OpenCode 配置到 ~/.config/opencode
./publish-opencode.sh
```

发布完成后，启动脚本已安装到 `~/.local/bin`：

```bash
cc    # 启动 Claude Code
oc    # 启动 OpenCode
```

开始愉快的vibe吧~~

### 安装 MCP 服务（可选）

根据需要安装 MCP 扩展，详细说明见各目录下的 `install.md`：

| MCP              | 描述              | 安装说明                                                 |
| ---------------- | ----------------- | -------------------------------------------------------- |
| context7         | 查询技术文档      | [install.md](claudecode/mcp/context7/install.md)         |
| duckduckgo       | 联网搜索          | [install.md](claudecode/mcp/duckduckgo/install.md)       |
| mcp_server_mysql | 连接 MySQL 数据库 | [install.md](claudecode/mcp/mcp_server_mysql/install.md) |

### 安装 claude-mem 持久化记忆（可选）

[claude-mem](https://github.com/thedotmack/claude-mem) 提供跨会话的持久化记忆，让 Claude 拥有"长期记忆"。

```bash
./publish-install-claude-men.sh
```

详细说明见 [claude-mem 官方文档](https://docs.claude-mem.ai)。

---

## 架构概览

项目同时维护两套独立的配置源（claudecode / opencode），通过发布脚本同步到对应的目标目录。关键层级如下：

```
vibe-coding-kit/
├── claudecode/          # Claude Code 配置源
│   ├── agents/          # 7 个专业 Agent
│   ├── skills/          # 10+ 个 Skill
│   ├── bin/             # 启动脚本 (cc)
│   ├── mcp/             # MCP 扩展 (context7, duckduckgo, mysql)
│   └── config/          # settings.json
├── opencode/            # OpenCode 配置源
│   ├── agents/          # 7 个专业 Agent
│   ├── skills/          # 2 个 Skill
│   ├── plugins/         # 6 个 JS 插件
│   ├── commands/        # 2 个 Command
│   └── bin/             # 启动脚本 (oc, ocw)
├── docs/                # 开发文档
├── publish.sh           # 发布脚本 (Claude Code)
├── publish-opencode.sh  # 发布脚本 (OpenCode)
├── rollback.sh          # 回滚脚本 (Claude Code)
└── rollback-opencode.sh # 回滚脚本 (OpenCode)
```

---

## Agents

| Agent     | 模型   | 描述                                     |
| --------- | ------ | ---------------------------------------- |
| captain   | opus   | 主控调度，协调专家 Agent 完成复杂任务    |
| assistant | haiku  | 执行者，处理非代码任务（配置/文本/文档） |
| developer | sonnet | 执行者，专注代码实现                     |
| explorer  | haiku  | 快速定位代码、理解代码结构               |
| librarian | sonnet | 知识检索，获取外部知识和技术信息         |
| oracle    | opus   | 守护监察，架构评审、风险评估、问题诊断   |
| designer  | opus   | 体验设计，UI/UX 设计和前端实现           |

---

## Skills

| Skill          | 触发            | 描述                                          |
| -------------- | --------------- | --------------------------------------------- |
| code-review    | /code-review    | 中文代码审查专家，多维度全面评估代码质量      |
| commit         | /commit         | 创建符合规范的 git 提交，支持按文件拆分       |
| weeklog        | /weeklog        | 本周工作总结，查询 git 提交记录梳理成果       |
| write-readme   | /write-readme   | 中文 README 生成器，先分析项目类型再选模板    |
| frontend-ui-ux | /frontend-ui-ux | 无稿设计师型开发者，无设计稿也能创建精美 UI   |
| tdd            | /tdd            | 测试驱动开发，遵循 red-green-refactor 循环    |
| to-prd         | /to-prd         | 将对话上下文转化为 PRD 并发布到 issue 跟踪器  |
| to-issues      | /to-issues      | 将计划或 PRD 分解为可独立领取的垂直切片 issue |
| caveman        | /caveman        | 超压缩通信模式，砍掉填充词保持技术准确度      |
| agent-browser  | /agent-browser  | 浏览器自动化 CLI，网页交互/数据抓取           |

---

## Plugins

### Claude Code Plugins

| Plugin                   | 描述                                        |
| ------------------------ | ------------------------------------------- |
| comment-checker          | 检测代码中的 AI 风格注释                    |
| edit-error-recovery      | 监听 Edit 工具错误，注入恢复提醒            |
| delegate-task-retry      | 监听 Task 工具错误，注入即时重试指导        |
| question-label-truncator | 自动截断过长的 AskUserQuestion option label |
| windows-notification     | Windows 系统通知，任务完成/出错自动弹窗     |
| ralph-loop               | 自引用开发循环（实验性）                    |

### OpenCode Plugins

| Plugin                      | 描述                                      |
| --------------------------- | ----------------------------------------- |
| user-agent                  | 模拟 KimiCLI 请求头，支持用量翻倍活动     |
| edit-error-recovery         | 监听 Edit 工具错误，注入恢复提醒          |
| comment-checker             | 检测代码中的 AI 风格注释                  |
| compaction-context-injector | session compaction 时注入结构化摘要提示词 |
| delegate-task-retry         | 监听 Task 工具错误，注入即时重试指导      |

### claude-mem 持久化记忆

[claude-mem](https://github.com/thedotmack/claude-mem) 提供跨会话的持久化记忆，让 Claude 拥有"长期记忆"。

```bash
./publish-install-claude-men.sh
```

详细说明见 [claude-mem 官方文档](https://docs.claude-mem.ai)。

---

## MCP

| MCP              | 描述              | 安装说明                                                 |
| ---------------- | ----------------- | -------------------------------------------------------- |
| context7         | 查询技术文档      | [install.md](claudecode/mcp/context7/install.md)         |
| duckduckgo       | 联网搜索          | [install.md](claudecode/mcp/duckduckgo/install.md)       |
| mcp_server_mysql | 连接 MySQL 数据库 | [install.md](claudecode/mcp/mcp_server_mysql/install.md) |

---

## 配置管理

**发布：**

```bash
./publish.sh              # 发布 Claude Code 配置
./publish-opencode.sh     # 发布 OpenCode 配置
```

每次发布会自动备份现有配置到 `backup/<timestamp>/`。

**回滚：**

```bash
./rollback.sh             # 交互式选择备份恢复
./rollback.sh 20250401    # 指定时间戳恢复
./rollback.sh -l          # 列出所有备份
```

OpenCode 同理，使用 `rollback-opencode.sh`。

---

## 模型推荐

- opus 级别: kimi2.6 ≈ deepseek-v4-pro[1m] > glm5.1
- sonnet 级别: deepseek-v4-pro[1m] > glm5.1 > minimax2.7
- haiku 级别: deepseek-v4-flash > minimax2.7-highspeed

---

## 特别感谢

感谢以下项目的启发和贡献：

- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)
- [claude-code-skills-zh](https://github.com/laolaoshiren/claude-code-skills-zh)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [elfgzp/opencode-configs](https://github.com/elfgzp/opencode-configs)

---

## License

MIT
