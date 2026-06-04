# vibe-coding-kit

面向 [Claude Code](https://code.claude.com) 的一站式增强配置包，内置多 Agent 协作、智能 Skill、自动化插件，clone 即用。

---

## 项目亮点

- **多 Agent 协作** — 主 Agent 只读调度，子 Agent 专注执行，上下文不污染
- **丰富的 Skill 生态** — 10+ 个开箱即用的 Skill（代码审查、周报、TDD、README 生成等）
- **一键发布与安全回滚** — publish.sh 发布，自动备份，rollback.sh 一键恢复

---

## 快速开始

```bash
git clone <repo-url> ~/vibe-coding-kit
cd ~/vibe-coding-kit

# 发布 Claude Code 配置到 ~/.claude
./publish.sh
```

发布完成后，启动脚本已安装到 `~/.local/bin`：

```bash
cc    # 启动 Claude Code
```

开始愉快的vibe吧~~

### 安装 MCP 服务（可选）

根据需要安装 MCP 扩展，详细说明见各目录下的 `install.md`：

| MCP              | 描述              | 安装说明                                                 |
| ---------------- | ----------------- | -------------------------------------------------------- |
| context7         | 查询技术文档      | [install.md](claudecode/mcp/context7/install.md)         |
| duckduckgo       | 联网搜索          | [install.md](claudecode/mcp/duckduckgo/install.md)       |
| mcp_server_mysql | 连接 MySQL 数据库 | [install.md](claudecode/mcp/mcp_server_mysql/install.md) |

---

## 架构概览

项目维护 Claude Code 配置源，通过发布脚本同步到对应的目标目录。关键层级如下：

```
vibe-coding-kit/
├── claudecode/          # Claude Code 配置源
│   ├── agents/          # 7 个专业 Agent
│   ├── skills/          # 10+ 个 Skill
│   ├── bin/             # 启动脚本 (cc)
│   ├── mcp/             # MCP 扩展 (context7, duckduckgo, mysql)
│   └── config/          # settings.json
├── docs/                # 开发文档
├── publish.sh           # 发布脚本 (Claude Code)
└── rollback.sh          # 回滚脚本 (Claude Code)
```

---

## Agents

| Agent      | 模型   | 描述                                     | 参考来源                           |
| ---------- | ------ | ---------------------------------------- | ---------------------------------- |
| teamleader | opus   | 主控调度，协调专家 Agent 完成复杂任务    | omo/Sisyphus                       |
| assistant  | haiku  | 执行者，处理非代码任务（配置/文本/文档） | omo/Sisyphus-junior                |
| developer  | sonnet | 执行者，专注代码实现                     | omo/Hephaistus                     |
| explorer   | haiku  | 快速定位代码、理解代码结构               | omo/Explore                        |
| librarian  | sonnet | 知识检索，获取外部知识和技术信息         | omo/Librarian                      |
| oracle     | opus   | 守护监察，架构评审、风险评估、问题诊断   | omo/Oracle                         |
| designer   | opus   | 体验设计，UI/UX 设计和前端实现           | omo/Prometheus + multimodal-looker |

---

## Skills

| Skill                    | 触发                      | 描述                                                                                | 参考来源                                      |
| ------------------------ | ------------------------- | ----------------------------------------------------------------------------------- | --------------------------------------------- |
| agent-browser            | /agent-browser            | 浏览器自动化 CLI，网页交互/数据抓取                                                 | vercel-labs/agent-browser                     |
| ascii-art-diagrams       | /ascii-art-diagrams       | 创建对齐 ASCII 艺术图表的强制工作流（PLAN/DRAW/VERIFY 三阶段）                      | jasnell/opencode-skill-ascii-art-diagrams     |
| caveman                  | /caveman                  | 超压缩通信模式，砍掉填充词保持技术准确度                                            | mattpocock/skills                             |
| chinese-code-review      | /chinese-code-review      | 中文 review 沟通参考——话术模板、分级标注、国内团队常见反模式应对                    | jnMetaCode/superpowers-zh                     |
| chinese-documentation    | /chinese-documentation    | 中文文档排版参考——中英文空格、全半角标点、术语保留、链接格式                        | jnMetaCode/superpowers-zh                     |
| commit                   | /commit                   | 创建符合规范的 git 提交，支持按文件拆分                                             | 自研                                          |
| pull                     | /pull                     | 使用 rebase 方式安全拉取远程更新，自动暂存本地变更并处理冲突                        | 自研                                          |
| push                     | /push                     | 安全推送，只 fast-forward，远端有更新时先 pull --rebase 再等待用户确认              | 自研                                          |
| docx                     | /docx                     | 创建/读取/编辑/操作 Word 文档（.docx），包括报告、备忘录、信件、模板等              | anthropics/skills                             |
| frontend-ascii-previewer | /frontend-ascii-previewer | 修改前端 UI 前先通过 ASCII 原型预览确认视觉需求                                     | kuops                                         |
| frontend-ui-ux           | /frontend-ui-ux           | 无稿设计师型开发者，无设计稿也能创建精美 UI                                         | omo                                           |
| humanizer                | /humanizer                | 将 AI 生成的文本转化为自然流畅的人类语言                                            | op7418/Humanizer-zh                           |
| mermaid-tools            | /mermaid-tools            | 从 Markdown 中提取 Mermaid 图表并生成高质量 PNG 图片                                | daymade/claude-code-skills                    |
| pdf                      | /pdf                      | 读取/提取/合并/拆分/创建/操作 PDF 文件，支持文本、表格、图片、OCR、表单等           | anthropics/skills                             |
| pptx                     | /pptx                     | 创建/读取/编辑/操作 PowerPoint 演示文稿（.pptx），包括幻灯片、deck、presentation 等 | anthropics/skills                             |
| tdd                      | /tdd                      | 测试驱动开发，遵循 red-green-refactor 循环                                          | mattpocock/skills                             |
| to-issues                | /to-issues                | 将计划或 PRD 分解为可独立领取的垂直切片 issue                                       | mattpocock/skills                             |
| to-prd                   | /to-prd                   | 将对话上下文转化为 PRD 并发布到 issue 跟踪器                                        | mattpocock/skills                             |
| weeklog                  | /weeklog                  | 本周工作总结，查询 git 提交记录梳理成果                                             | 自研                                          |
| write-readme             | /write-readme             | 中文 README 生成器，先分析项目类型再选模板                                          | zh-readme @laolaoshiren/claude-code-skills-zh |
| xlsx                     | /xlsx                     | 创建/读取/编辑/操作 Excel 电子表格（.xlsx/.csv/.tsv），包括格式化、图表、数据处理等 | anthropics/skills                             |

---

## Plugins

| Plugin                   | 描述                                        | 参考来源                     |
| ------------------------ | ------------------------------------------- | ---------------------------- |
| comment-checker          | 检测代码中的 AI 风格注释                    | omo/comment-checker          |
| edit-error-recovery      | 监听 Edit 工具错误，注入恢复提醒            | omo/edit-error-recovery      |
| delegate-task-retry      | 监听 Task 工具错误，注入即时重试指导        | omo/delegate-task-retry      |
| question-label-truncator | 自动截断过长的 AskUserQuestion option label | omo/question-label-truncator |
| windows-notification     | Windows 系统通知，任务完成/出错自动弹窗     | 自研                         |
| ralph-loop               | 自引用开发循环（实验性）                    | omo                          |

---

## MCP

| MCP              | 描述              | 参考来源                        | 安装说明                                                 |
| ---------------- | ----------------- | ------------------------------- | -------------------------------------------------------- |
| context7         | 查询技术文档      | upstash/context7                | [install.md](claudecode/mcp/context7/install.md)         |
| duckduckgo       | 联网搜索          | nickclyde/duckduckgo-mcp-server | [install.md](claudecode/mcp/duckduckgo/install.md)       |
| mcp_server_mysql | 连接 MySQL 数据库 | benborla/mcp-server-mysql       | [install.md](claudecode/mcp/mcp_server_mysql/install.md) |

---

## 配置管理

**发布：**

```bash
./publish.sh              # 发布 Claude Code 配置
```

每次发布会自动备份现有配置到 `backup/<timestamp>/`。

**回滚：**

```bash
./rollback.sh             # 交互式选择备份恢复
./rollback.sh 20250401    # 指定时间戳恢复
./rollback.sh -l          # 列出所有备份
```

---

## 模型推荐

- opus 级别: kimi2.6 ≈ deepseek-v4-pro[1m] > glm5.1
- sonnet 级别: deepseek-v4-pro[1m] > glm5.1 > minimax2.7
- haiku 级别: deepseek-v4-flash > minimax2.7-highspeed

---

## 特别感谢

感谢以下项目的启发和贡献：

- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)
- [laolaoshiren/claude-code-skills-zh](https://github.com/laolaoshiren/claude-code-skills-zh)
- [yunshu0909/yunshu_skillshub](https://github.com/yunshu0909/yunshu_skillshub)
- [mattpocock/skills](https://github.com/mattpocock/skills)
- [jnMetaCode/superpowers-zh](https://github.com/jnMetaCode/superpowers-zh)
- [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills)
- [jasnell/opencode-skill-ascii-art-diagrams](https://github.com/jasnell/opencode-skill-ascii-art-diagrams)
- [kuops](https://github.com/kuops)

---

## License

MIT
