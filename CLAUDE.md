# vibe-coding-kit

这是vibe-coding的拓展集合，主要面向 claudecode 进行拓展，增强用户使用体验，主要包含各式专业的 command、skill、subagent、rule、mcp

## 脚本工具

| 名称                 | 描述                                            |
| -------------------- | ----------------------------------------------- |
| publish.sh           | 发布脚本：将本地配置同步到 `~/.claude`          |
| rollback.sh          | 回滚脚本：从备份恢复 Claude Code 配置           |

## 目录结构

```
vibe-coding-kit/
├── claudecode/          # Claude Code 配置
│   ├── agents/          # SubAgent 定义（专业角色）
│   ├── bin/             # 启动脚本
│   ├── config/          # Claude Code 设置
│   ├── mcp/             # MCP (Model Context Protocol) 扩展
│   ├── plugins/         # 插件扩展
│   ├── rules/           # 代码规则与约束
│   └── skills/          # Skill 定义（扩展 AI 能力）
├── docs/                # 文档
├── CLAUDE.md
├── CLAUDE.local.md
├── publish.sh
└── rollback.sh
```

## Agents

| 名称      | 参考来源                           | 模型   | 描述                                                |
| --------- | ---------------------------------- | ------ | --------------------------------------------------- |
| teamleader | omo/Sisyphus                       | opus   | 主控调度，协调专家Agent完成复杂任务；验证执行者输出 |
| assistant | omo/Sisyphus-junior                | haiku  | 执行者，处理所有非代码任务（配置/文本/格式/文档）   |
| developer | omo/Hephaistus                     | sonnet | 执行者，专注代码实现，处理所有代码任务              |
| explorer  | omo/Explore                        | haiku  | 快速定位代码、理解代码结构                          |
| librarian | omo/Librarian                      | sonnet | 知识检索，获取外部知识和技术信息                    |
| oracle    | omo/Oracle                         | opus   | 守护监察，架构评审、风险评估、问题诊断              |
| designer  | omo/Prometheus + multimodal-looker | opus   | 体验设计，UI/UX、图像分析和前端实现                 |

## Skills

| 名称           | 描述                                                     |
| -------------- | -------------------------------------------------------- |
| agent-browser  | 浏览器自动化 CLI，用于网页交互、表单填写、数据抓取等任务 |
| frontend-ui-ux | 无稿设计师型开发者，即使没有设计稿也能创建精美 UI/UX     |
| commit         | 创建符合内部规范的 git 提交                              |
| weeklog        | 本周工作总结：查询 git 仓库提交记录，梳理本周工作成果    |
| code-review    | 中文代码审查专家，多维度全面评估代码质量                 |
| write-readme   | 中文 README 生成器，先分析项目类型再选择对应模板生成     |
| caveman        | 超压缩通信模式，砍掉填充词和客套话，保持完整技术准确度   |
| tdd            | 测试驱动开发，遵循 red-green-refactor 循环               |
| to-prd         | 将当前对话上下文转化为 PRD 并发布到项目 issue 跟踪器     |
| to-issues      | 将计划或 PRD 分解为可独立领取的垂直切片问题              |

## Plugins

| 名称                        | 参考来源                        | 描述                                                        |
| --------------------------- | ------------------------------- | ----------------------------------------------------------- |
| edit-error-recovery         | omo/edit-error-recovery         | 监听 Edit 工具错误，注入恢复提醒                            |
| comment-checker             | omo/comment-checker             | 检测 Java/Vue/Shell 代码中的 AI 风格注释，纯 JS 重写        |
| delegate-task-retry         | omo/delegate-task-retry         | 监听 Task 工具错误，注入即时重试指导                        |
| ralph-loop                  | omo                             | 自引用开发循环，让 Agent 自动继续工作（实验性）             |
| windows-notification        | 本地开发                        | 在事件触发时弹出 Windows 系统通知                           |
| question-label-truncator    | omo/question-label-truncator    | 在 AskUserQuestion 执行前自动截断过长的 option label        |

### Plugins 开发

详见 [docs/plugin-development.md](docs/plugin-development.md)

## MCP

| 名称            | 参考来源                           | 描述                                          |
| --------------- | ---------------------------------- | --------------------------------------------- |
| context7        | upstash/context7                   | 连接 Context7 查询技术文档标准的 MCP           |
| duckduckgo      | nickclyde/duckduckgo-mcp-server    | 连接 DuckDuckGo 搜索引擎的 MCP                 |
| mcp_server_mysql | benborla/mcp-server-mysql        | 连接 MySQL 数据库的 MCP                        |
