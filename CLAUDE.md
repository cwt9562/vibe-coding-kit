# vibe-coding-kit

这是vibe-coding的拓展集合，主要面向claudecode和opencode进行拓展，增强用户使用体验，主要包含各式专业的 command、skill、subagent、rule、mcp

## 脚本工具

| 名称        | 描述                                                           |
| ----------- | -------------------------------------------------------------- |
| publish.sh  | 发布脚本：将本地配置同步到 `~/.claude` 和 `~/.config/opencode` |
| rollback.sh | 回滚脚本：从备份恢复 Claude Code 和 OpenCode 配置              |

## 目录结构

```
vibe-coding-kit/
├── agents/       # SubAgent 定义（专业角色）
├── commands/     # Command 定义（CLI 增强）
├── config/       # 工具配置（区分 claudecode / opencode）
├── mcp/          # MCP (Model Context Protocol) 扩展
├── plugins/      # 插件扩展（区分 claudecode / opencode）
├── rules/        # 代码规则与约束
└── skills/       # Skill 定义（扩展 AI 能力）
```

## Agents

| 名称      | 参考来源       | 描述                                   |
| --------- | -------------- | -------------------------------------- |
| captain   | omo/Sisyphus   | 主控调度，协调专家Agent完成复杂任务    |
| developer | omo/Hephaestus | 快速实现专家，执行明确的任务规格       |
| explorer  | omo/Explore    | 快速定位代码、理解代码结构             |
| oracle    | omo/Oracle     | 守护监察，架构评审、风险评估、问题诊断 |
| librarian | omo/Librarian  | 知识检索，获取外部知识和技术信息       |
| designer  | omo/Prometheus | 体验设计，UI/UX设计和前端实现指导      |

## Commands

| 名称    | 描述                                          |
| ------- | --------------------------------------------- |
| commit  | 创建符合内部规范的 git 提交                   |
| weeklog | 本周工作总结：查询 git 提交记录，梳理本周工作 |

## Skills

| 名称          | 描述                                                     |
| ------------- | -------------------------------------------------------- |
| agent-browser | 浏览器自动化 CLI，用于网页交互、表单填写、数据抓取等任务 |

## Plugins

| 名称                        | 参考来源                        | 描述                                                        |
| --------------------------- | ------------------------------- | ----------------------------------------------------------- |
| user-agent                  | elfgzp/opencode-configs         | 开源的 OpenCode 插件，模拟 KimiCLI 请求头以支持用量翻倍活动 |
| edit-error-recovery         | omo/edit-error-recovery         | 监听 Edit 工具错误，注入恢复提醒                            |
| comment-checker             | omo/comment-checker             | 检测 Java/Vue/Shell 代码中的 AI 风格注释，纯 JS 重写        |
| compaction-context-injector | omo/compaction-context-injector | 在 OpenCode 的 session compaction 时注入结构化摘要提示词    |
| delegate-task-retry         | omo/delegate-task-retry         | 监听 Task 工具错误，注入即时重试指导                        |
| question-label-truncator    | omo/question-label-truncator    | 在 AskUserQuestion 执行前自动截断过长的 option label        |

### Plugins 开发

详见 [docs/plugin-development.md](docs/plugin-development.md)
