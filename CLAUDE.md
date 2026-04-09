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

| 名称        | 参考来源           | 模型               | 描述                                                           |
| ----------- | ------------------ | ------------------ | -------------------------------------------------------------- |
| captain     | omo/Sisyphus       | Kimi               | 主控调度，协调专家Agent完成复杂任务；验证执行者输出             |
| assistant   | omo/Sisyphus-junior   | M2.7-highspeed     | 执行者，处理所有非代码任务（配置/文本/格式/文档）              |
| developer   | omo/Hephaistus     | M2.7               | 执行者，专注代码实现，处理所有代码任务                          |
| explorer    | omo/Explore        | M2.7-highspeed     | 快速定位代码、理解代码结构                                     |
| librarian   | omo/Librarian      | M2.7-highspeed     | 知识检索，获取外部知识和技术信息                               |
| oracle      | omo/Oracle         | Kimi               | 守护监察，架构评审、风险评估、问题诊断                         |
| designer    | omo/Prometheus + multimodal-looker | Kimi               | 体验设计，UI/UX、图像分析和前端实现                           |

## Commands

| 名称    | 描述                                          |
| ------- | --------------------------------------------- |
| commit  | 创建符合内部规范的 git 提交                   |
| weeklog | 本周工作总结：查询 git 提交记录，梳理本周工作 |

## Skills

| 名称            | 描述                                                     |
| --------------- | -------------------------------------------------------- |
| agent-browser   | 浏览器自动化 CLI，用于网页交互、表单填写、数据抓取等任务 |
| frontend-ui-ux  | 无稿设计师型开发者，即使没有设计稿也能创建精美 UI/UX    |

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
