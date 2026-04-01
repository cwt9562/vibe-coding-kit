# oh-my-opencode (omo) 组件清单

> 来源：`reference/oh-my-openagent/` | 分支：dev | 提交：7fe44024 | 生成日期：2026-04-01

---

## Agents（11 个）

| 名称 | 描述 | 源码位置 |
|------|------|----------|
| **sisyphus** | 主控调度 Agent。收到复杂任务后，会分析需求、拆分步骤、决定调用哪个专家 Agent，并协调它们完成工作。相当于项目经理+技术负责人。 | `src/agents/sisyphus/` |
| **hephaestus** | 快速实现专家。接到明确任务后直接写代码，不做过多的计划和分析。适合执行已经拆分好的具体开发任务。 | `src/agents/hephaestus/` |
| **oracle** | 守护监察 Agent。负责架构评审、风险评估、代码审查，在提交前帮你把关质量。 | `src/agents/oracle.ts` |
| **librarian** | 知识检索 Agent。专门查询外部文档、技术资料、API 文档，并把结果整理后反馈给其他 Agent。 | `src/agents/librarian.ts` |
| **explore** | 代码探索 Agent。快速理解项目结构、定位关键文件、梳理代码逻辑，适合接手新项目时做前期调研。 | `src/agents/explore.ts` |
| **atlas** | 知识库管理 Agent。维护项目的 `AGENTS.md` 等知识资产，确保项目文档和代码一起成长。 | `src/agents/atlas/` |
| **prometheus** | 体验设计 Agent。负责 UI/UX 设计、前端实现指导，能在没有设计稿的情况下给出美观的界面方案。 | `src/agents/prometheus/` |
| **metis** | 工具元数据管理。跟踪各个工具的使用情况和效果，帮助系统优化工具调用策略。 | `src/agents/metis.ts` |
| **momus** | 会话管理 Agent。监控会话生命周期和状态变化，做一些会话层面的协调工作。 | `src/agents/momus.ts` |
| **multimodal-looker** | 多模态图像查看 Agent。专门处理图片、截图等视觉内容的理解和分析。 | `src/agents/multimodal-looker.ts` |
| **sisyphus-junior** | Sisyphus 的轻量子代理。处理相对简单的调度任务，减少主 Sisyphus 的负载。 | `src/agents/sisyphus-junior/` |

---

## Skills（6 个）

Skill 是 Agent 可以调用的"专业技能包"，每个 Skill 包含一套完整的提示词模板和对应的工具权限。

| 名称 | 描述 |
|------|------|
| **playwright** | 通过 Playwright MCP 驱动浏览器。适合网页自动化、截图、数据抓取、表单填写、端到端测试等任何需要操作浏览器的任务。 |
| **agent-browser** | 通过 `agent-browser` CLI 驱动浏览器。是 playwright 的替代方案，提供带标注截图（@e1 等 ref 标记）、页面 diff、状态持久化、iOS 模拟器等功能，更适合复杂交互场景。 |
| **playwright-cli** | 通过 `playwright-cli` 命令行驱动浏览器。token 效率更高的轻量版浏览器自动化方案，功能和 playwright 类似但走 CLI 而不是 MCP。 |
| **frontend-ui-ux** | 前端设计 Skill。让 Agent 像一个"会写代码的设计师"，在没有设计稿的情况下也能做出视觉上美观、有明确风格倾向的界面。 |
| **git-master** | Git 专家 Skill。提供提交规范检测、原子提交拆分、rebase/squash 指导、历史搜索（git blame/bisect）等高级 Git 操作能力。 |
| **dev-browser** | 开发者浏览器 Skill。基于本地 Node 服务器维护持久化页面状态，适合本地开发时的浏览器自动化调试，支持直接连接用户的 Chrome 扩展。 |

**配置说明**：`browserProvider` 可以切换默认浏览器 Skill： `"playwright"` 用 MCP 方案；`"agent-browser"` 用 agent-browser CLI；`"playwright-cli"` 用 playwright-cli。

---

## Hooks（48 个）

Hook 是 omo 的核心增强机制，在 OpenCode 的生命周期事件（如发送消息、执行工具、会话创建等）中插入自定义逻辑。可以理解为"生命周期拦截器"或"自动化的机器人保姆"。

### Session Hooks（会话层，23 个）

这类 Hook 主要围绕**会话的创建、运行、异常恢复**等阶段工作。

| Hook 名称 | 作用说明 |
|-----------|----------|
| `context-window-monitor` | 监控当前会话的 token 使用量。当输入 token 超过上下文窗口的 70% 时，在工具输出结尾自动追加提醒，告诉 Agent "你还有空间，不要着急跳过任务"。 |
| `preemptive-compaction` | **实验性功能**。在上下文快要满之前，主动触发压缩，把历史对话摘要化，避免达到模型的硬性上限导致报错。 |
| `session-recovery` | 当会话因为网络、模型错误等原因中断时，自动尝试恢复会话状态，让 Agent 能从断点继续工作而不是从头开始。 |
| `session-notification` | 当 Agent 在后台长时间运行时，通过系统通知（声音+Toast）提醒你。比如 Deep Research 跑完了会弹窗通知。 |
| `think-mode` | 自动切换 Claude 的 Think 模式。在需要深度推理的场景下自动启用 thinking，不需要手动设置。 |
| `model-fallback` | 当某个模型报错（如限流、上下文超限、服务不可用）时，自动把会话切换到备用模型继续对话，并给用户一个 Toast 提示。 |
| `anthropic-context-window-limit-recovery` | Anthropic 模型特有的上下文超限恢复。当 Claude 因为上下文限制报错时，自动尝试清理或压缩历史消息来恢复对话。 |
| `auto-update-checker` | 每次启动时检查 omo 插件是否有新版本，如果有就提示用户更新。 |
| `agent-usage-reminder` | 在会话中适时提醒用户有哪些 Agent 可用，以及如何召唤它们，防止用户不知道某些专家 Agent 的存在。 |
| `non-interactive-env` | 检测当前是否运行在 CI、Docker 等非交互环境中。如果是，自动调整一些需要用户确认的行为（比如跳过交互式提示）。 |
| `interactive-bash-session` | 增强 Bash 工具的交互式会话支持，让需要连续输入的命令（如 `git rebase -i`、`npm init`）能更好地运行。 |
| `ralph-loop` | Ralph 自引用开发循环。启动后 Agent 会自检自己的工作结果，发现没做完就继续迭代，直到目标达成为止。相当于给 Agent 装了一个"自动补完"循环。 |
| `edit-error-recovery` | 监听 Edit 工具（如修改文件）的失败报错。当 Edit 因为格式问题、行号不对等原因失败时，自动注入修复建议，提高重试成功率。 |
| `delegate-task-retry` | 当 `delegate-task` 工具（委派子 Agent 执行任务）失败时，自动分析错误原因并给出重试指导，减少人工干预。 |
| `start-work` | 配合 `/start-work` 命令使用。从 Prometheus 生成的计划中提取任务清单，自动创建结构化的工作会话。 |
| `prometheus-md-only` | 限制 Prometheus Agent 只输出 Markdown 格式的设计文档/计划，不直接写代码，确保设计和实现职责分离。 |
| `sisyphus-junior-notepad` | 为 Sisyphus-Junior 子代理提供笔记本功能，让它在执行任务时能记录中间状态和发现，增强多步任务的记忆能力。 |
| `no-sisyphus-gpt` | 强制 Sisyphus 主代理不使用 GPT 模型。有些用户认为 GPT 在调度任务上表现不佳，这个 Hook 会拦截并切换模型。 |
| `no-hephaestus-non-gpt` | 强制 Hephaestus 开发代理只能使用 GPT 模型（或其指定模型）。确保写代码的 Agent 用上最适合它的模型。 |
| `question-label-truncator` | 截断过长的用户问题标签/标题。防止某些模型或工具因为输入标签太长而报错。 |
| `task-resume-info` | 当会话恢复时，自动注入之前未完成的任务状态，让 Agent 知道"你之前做到哪了"。 |
| `anthropic-effort` | 自动调整 Anthropic 模型的 `effort` 参数（thinking 的努力程度），在高复杂度任务时自动提高，简单任务时降低以节省 token。 |
| `runtime-fallback` | 比 `model-fallback` 更底层的运行时回退。当模型在推理过程中突然不可用时，快速降级到本地或备用推理源。 |

### Tool Guard Hooks（工具守卫层，12 个）

这类 Hook 在**工具执行前后**工作，负责安全防护、输出优化、信息增强。

| Hook 名称 | 作用说明 |
|-----------|----------|
| `comment-checker` | 检测 Agent 生成的代码中是否包含典型的"AI 风格注释"（如过度解释、空泛描述、中文注释混入英文项目等），并在提交前提醒修改。 |
| `tool-output-truncator` | 当工具返回值过长时，按模型上下文限制自动截断输出，防止一个工具的返回就把上下文塞爆。 |
| `directory-agents-injector` | 读取当前目录下的 Agent 配置文件，把它们自动注入到当前会话的系统提示词中。已在新版 OpenCode 中原生化，旧版靠这个 Hook 弥补。 |
| `directory-readme-injector` | 读取当前目录的 README 或相关文档，把项目背景信息自动注入到 Agent 的上下文中，减少重复介绍项目。 |
| `empty-task-response-detector` | 检测 Agent 是否给出了"空响应"（比如只说"我知道了"但没有实际行动），发现后自动追问让它继续执行任务。 |
| `rules-injector` | 扫描项目中的 `.sisyphus/rules/` 等规则文件，把项目的编码规范、架构约束自动注入给 Agent。 |
| `tasks-todowrite-disabler` | 在特定场景下禁用 `TodoWrite` 工具。有些 Agent 或工作流不需要显式的 todo 列表，这个 Hook 可以避免 todo 泛滥。 |
| `write-existing-file-guard` | 当 Agent 尝试用 Write 工具覆盖一个已存在的文件时进行拦截或提醒，防止意外覆盖重要代码。 |
| `hashline-read-enhancer` | 增强 `hashline_edit` 工具的读取能力。在允许的情况下，让 Edit 工具能看到更精确的文件片段，减少修改出错。 |
| `json-error-recovery` | 当 Agent 输出错误的 JSON（比如工具参数格式不对）时，自动识别常见错误模式并给出修复提示。 |
| `read-image-resizer` | 当 Agent 读取大尺寸图片时，自动缩放图片再传入模型，避免视觉模型因为图片太大而报错或消耗过多 token。 |
| `todo-description-override` | 覆盖 TodoWrite 中 todo 项的默认描述文案，让 todo 的措辞更符合项目规范或更具体。 |

### Transform Hooks（消息转换层，4 个）

这类 Hook 在**消息发送给模型之前**修改消息内容，做上下文增强和格式校验。

| Hook 名称 | 作用说明 |
|-----------|----------|
| `claude-code-hooks` | 代理 Claude Code 原生的 Hook 行为。让 omo 能在 OpenCode 环境中复现一些 Claude Code 特有的上下文注入逻辑。 |
| `keyword-detector` | 检测用户消息中的特定关键词（如 "@sisyphus"、"@oracle" 等），触发对应的 Agent 召唤或特殊行为。 |
| `context-injector-messages-transform` | 把外部收集到的上下文（如 GIT 状态、最近修改的文件、项目规则）注入到真正传给模型的消息列表中。 |
| `thinking-block-validator` | 验证模型返回的 thinking block 格式是否正确。如果格式异常，会进行修正或清理，避免下游解析出错。 |

### Continuation Hooks（任务延续层，7 个）

这类 Hook 负责**长任务的自动延续**，比如压缩上下文后不丢失任务进度、后台任务的通知、Agent 超时后的清理等。

| Hook 名称 | 作用说明 |
|-----------|----------|
| `stop-continuation-guard` | 提供一个"紧急停止按钮"。当用户说停止循环时，所有自动延续机制（ralph loop、boulder、todo continuation）都会被这个守卫终止。 |
| `compaction-context-injector` | 当 OpenCode 触发上下文压缩（compaction）后，这个 Hook 会把压缩丢失的关键上下文重新注入，确保 Agent 不会"失忆"。 |
| `compaction-todo-preserver` | 上下文压缩时，特别保护当前的 todo 列表信息不被压缩掉，防止 Agent 忘记自己还有哪些任务没做完。 |
| `todo-continuation-enforcer` | 当还有未完成的 todo 项时，在 Agent 回复结束后自动追加提示或直接继续执行，推动 Agent 把任务做完。 |
| `unstable-agent-babysitter` | "保姆"Hook。监控子 Agent 的执行状态，发现超时、卡死、异常退出的任务时自动清理，防止后台残留僵尸进程。 |
| `background-notification` | 后台任务完成或失败时，给前端发送系统级通知，让用户不用守着终端等结果。 |
| `atlas` | Atlas Agent 的延续支持。在长时间的知识库整理任务中，保持工作流不中断，并协调 Atlas 和其他 Agent 的交接。 |

### Skill Hooks（Skill 增强层，2 个）

| Hook 名称 | 作用说明 |
|-----------|----------|
| `category-skill-reminder` | 根据当前任务分类，自动提醒 Agent 有哪些相关的 Skill 可以用。防止 Agent 忘记调用合适的 Skill。 |
| `auto-slash-command` | 自动识别用户的输入意图，并推荐合适的斜杠命令（如 `/refactor`、`/start-work`），提升命令发现效率。 |

---

## Commands（8 个）

Command 是用户可以通过斜杠直接调用的指令。

| 名称 | 作用说明 |
|------|----------|
| **init-deep** | 初始化层级化的 `AGENTS.md` 知识库。扫描项目结构，在每个关键目录下生成对应的 Agent 知识文档。 |
| **ralph-loop** | 启动 Ralph 自引用开发循环。Agent 会不断地检查任务进度、执行下一步、再检查，直到任务完成为止。 |
| **ulw-loop** | Ultrawork 循环。和 ralph-loop 类似，但以更高强度持续运行，适合必须在限时内完成的紧急任务。 |
| **cancel-ralph** | 取消当前活跃的 Ralph 循环。当你想让 Agent 停下来回答新问题时使用。 |
| **refactor** | 智能重构指令。自动调用 LSP、AST-grep、架构分析、代码地图、测试验证等工具链，安全地执行重构。 |
| **start-work** | 从 Prometheus 生成的设计计划中提取任务，启动一个结构化的 Sisyphus 工作会话。 |
| **stop-continuation** | 一键停止所有自动延续机制（ralph loop、todo continuation、boulder）。相当于紧急制动。 |
| **handoff** | 生成当前会话的详细上下文摘要，方便你在新会话中无缝接力继续工作。 |

---

## Tools（26 个）

Tool 是 Agent 可以直接调用的具体工具。

| 工具 | 作用说明 |
|------|----------|
| `lsp_goto_definition` | LSP 跳转到定义 |
| `lsp_find_references` | LSP 查找引用 |
| `lsp_symbols` | LSP 获取文件符号表 |
| `lsp_diagnostics` | LSP 获取诊断错误 |
| `lsp_prepare_rename` | LSP 预检查重命名 |
| `lsp_rename` | LSP 执行重命名 |
| `ast_grep` | 基于 AST 的模式匹配搜索 |
| `grep` | 文本搜索 |
| `glob` | 文件路径模式匹配 |
| `skill` | 调用已加载的 Skill |
| `skill_mcp` | 调用 Skill 内嵌的 MCP 服务 |
| `session_manager` | 管理会话状态 |
| `interactive_bash` | 交互式 Bash 会话 |
| `background_output` | 获取后台任务的输出 |
| `background_cancel` | 取消后台任务 |
| `call_omo_agent` | 调用 OMO 内置 Agent |
| `look_at` | 让 Agent 查看指定文件/目录 |
| `delegate_task` | 委派子任务给其他 Agent（核心工具，支持同步/异步/后台三种模式） |
| `hashline_edit` | 基于 hashline 定位的精确文件编辑 |
| `task_create` / `task_get` / `task_list` / `task_update` | 任务系统的 CRUD 操作 |

---

## Rules（规则）

| 规则 | 作用说明 |
|------|----------|
| `modular-code-enforcement` | 模块化代码执行规范。定义了代码应该如何模块化组织，Oracle/Sisyphus 在进行架构评审时会参考这套规则。存储在 `.sisyphus/rules/` 下。 |

**动态规则注入**：`rules-injector` Hook 会自动扫描项目中的规则文件（如 `.claude/rules/`、`.sisyphus/rules/` 等），在每次会话时把规则发给 Agent，确保 Agent 遵守项目的代码规范。

---

## MCP（3 个内置远程 MCP）

MCP（Model Context Protocol）是连接外部服务的协议。omo 内置了 3 个远程 MCP：

| 名称 | 作用说明 |
|------|----------|
| **websearch** | 网络搜索（支持 Exa / Tavily 等提供商） |
| **context7** | 技术文档检索（Context7 文档库） |
| **grep_app** | Grep App 代码搜索服务 |

---

## 数量汇总

| 类别 | 数量 |
|------|------|
| Agents | 11 |
| Hooks | 48 |
| Skills | 6 |
| Commands | 8 |
| Tools | 26 |
| Rules | 动态注入 |
| MCPs | 3 |
