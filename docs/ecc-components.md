# Everything Claude Code (ECC) 扩展点清单

> 来源：`reference/everything-claude-code/` | 分支：main | 生成日期：2026-04-02

---

## 数量总览

| 类别 | ECC | OMO | ECC/OMO |
|------|-----|-----|---------|
| **Agents** | 71 (36主+32 Kiro+3 Codex) | 11 | **6.5x** |
| **Skills** | 181 (142主+29 .agents+10 .cursor) | 6 | **30x** |
| **Commands** | 105 (68主+34 OpenCode+3 .claude) | 8 | **13x** |
| **Hooks** | 43+ (主27+Cursor 16) | 48 | ~1x |
| **Rules** | 77+ (按语言分类) | 动态注入 | - |
| **MCPs** | 14+ | 3 | **4.7x** |

---

## Agents（36 个主 Agent）

按功能分类：

| 类别 | Agent 列表 |
|------|-----------|
| **架构/规划** | architect, planner, chief-of-staff |
| **代码审查** | code-reviewer, security-reviewer, python/go/rust/kotlin/cpp/typescript/flutter/healthcare-reviewer |
| **构建修复** | build-error-resolver, go/kotlin/java/rust/cpp/pytorch-build-resolver |
| **测试/TDD** | tdd-guide, e2e-runner |
| **数据库** | database-reviewer |
| **文档** | doc-updater, docs-lookup |
| **性能/安全** | performance-optimizer, security-reviewer |
| **GAN/AI** | gan-evaluator, gan-generator, gan-planner |
| **开源** | opensource-forker, opensource-packager, opensource-sanitizer |
| **其他** | loop-operator, harness-optimizer, refactor-cleaner |

**文件位置**: `reference/everything-claude-code/agents/` (36个 .md)

---

## Skills（142 个主 Skill）

按功能分类：

| 类别 | Skill 数量 | 示例 |
|------|-----------|------|
| **编码标准** | 12+ | coding-standards, python-patterns, golang-patterns |
| **测试** | 10+ | tdd-workflow, e2e-testing, python-testing |
| **安全** | 8+ | security-review, security-scan |
| **框架模式** | 25+ | django/laravel/springboot-patterns |
| **移动开发** | 8+ | android-clean-architecture, kotlin-patterns |
| **容器/DevOps** | 5+ | docker-patterns, deployment-patterns |
| **AI/ML** | 6+ | pytorch-patterns, eval-harness |
| **前端** | 8+ | frontend-patterns, frontend-slides |
| **垂直领域** | 20+ | healthcare-*, logistics-*, energy-* |
| **开发工具** | 15+ | claude-api, nanoclaw-repl, pm2 |

**文件位置**: `reference/everything-claude-code/skills/` (142个子目录)

---

## Commands（68 个 Slash 命令）

| 类别 | 命令数 | 示例 |
|------|--------|------|
| **核心工作流** | 7 | /plan, /tdd, /code-review, /build-fix, /verify, /quality-gate, /refactor-clean |
| **测试** | 7 | /test-coverage, /go-test, /kotlin-test, /rust-test, /cpp-test, /e2e |
| **代码审查** | 5 | /python-review, /go-review, /kotlin-review, /rust-review, /cpp-review |
| **构建修复** | 5 | /go-build, /kotlin-build, /rust-build, /cpp-build, /gradle-build |
| **多模型协作** | 6 | /multi-plan, /multi-workflow, /multi-execute, /devfleet |
| **PRD/PR 工作流** | 5 | /prp-plan, /prp-prd, /prp-implement, /prp-commit, /prp-pr |
| **会话管理** | 5 | /save-session, /resume-session, /sessions, /checkpoint, /aside |
| **学习/进化** | 8 | /learn, /learn-eval, /evolve, /promote, /skill-create |
| **循环/自动化** | 4 | /loop-start, /loop-status, /claw, /santa-loop |

**文件位置**: `reference/everything-claude-code/commands/` (68个 .md)

---

## Rules（77 个规则文件）

按语言分类，每个语言 5 个规则（coding-style/hooks/patterns/security/testing）：

| 语言 | 文件数 | 特殊规则 |
|------|--------|---------|
| common/ | 10 | 通用编码规范 |
| typescript/ | 5 | - |
| python/ | 5 | - |
| golang/ | 5 | - |
| rust/ | 5 | - |
| java/ | 5 | - |
| kotlin/ | 5 | - |
| swift/ | 5 | - |
| cpp/ | 5 | - |
| csharp/ | 5 | - |
| php/ | 5 | - |
| perl/ | 5 | - |
| zh/ | 5 | 中文规则 |

**文件位置**: `reference/everything-claude-code/rules/` (77个 .md)

---

## Hooks（27+ 个）

分为 PreToolUse / PostToolUse / Lifecycle 三类：

| 类别 | Hook 数量 | 示例 |
|------|-----------|------|
| **PreToolUse** | 7 | Dev server blocker, Tmux reminder, Git push reminder |
| **PostToolUse** | 6 | PR logger, Build analysis, Quality gate |
| **Lifecycle** | 8 | Session start, Pre-compact, Cost tracker |

**文件位置**: `reference/everything-claude-code/hooks/hooks.json`

---

## MCP Servers（14+ 个）

| MCP 服务器 | 用途 |
|----------|------|
| github | GitHub PR/issues |
| firecrawl | 网页爬取 |
| supabase | 数据库操作 |
| memory / omega-memory | 跨会话记忆 |
| sequential-thinking | 链式推理 |
| vercel / railway | 部署 |
| cloudflare-* | 边缘计算/文档 |
| clickhouse | 分析查询 |
| exa-web-search | 网络搜索 |

**文件位置**: `reference/everything-claude-code/mcp-configs/mcp-servers.json`

---

## 其他集成

### Kiro AI（32 个 Agent）
- `reference/everything-claude-code/.kiro/agents/` - JSON+MD 格式的 Agent 配置

### OpenAI Codex（3 个 Agent）
- `reference/everything-claude-code/.codex/agents/` - TOML 格式的 Agent 配置

### Cursor IDE 集成
- `reference/everything-claude-code/.cursor/hooks/` (16 个 Hook)
- `reference/everything-claude-code/.cursor/rules/` (39 个规则)
- `reference/everything-claude-code/.cursor/skills/` (10 个 Skill)

### OpenCode 集成
- `reference/everything-claude-code/.opencode/commands/` (34 个命令)

---

## ECC 独有功能（OMO 没有）

| 功能类别 | 具体功能 |
|---------|---------|
| **多语言全栈覆盖** | 10+ 编程语言的专用规则和 Agent |
| **TDD 完整工作流** | /tdd 命令 + tdd-guide Agent + 多语言测试 Skill |
| **垂直领域扩展** | Healthcare, Logistics, Energy 等专业领域 |
| **多模型编排** | /multi-* 命令支持多 Agent 并行协作 |
| **PRD/PR 工作流** | 从需求到代码的完整流程 |
| **持续学习系统** | Instinct 系统自动提取和进化模式 |
| **Harness 优化** | 代理配置调优和成本追踪 |
| **构建修复专家** | Go/Rust/Kotlin/Java/C++ 专用构建错误修复 |
| **开源分叉工具链** | Fork/Package/Sanitize 三剑客 |

---

## 两者共有功能对比

| 功能 | ECC 实现 | OMO 实现 |
|------|---------|---------|
| 会话管理 | /save-session, /sessions | session-recovery, task-resume-info |
| 代码审查 | code-reviewer Agent | oracle Agent |
| 任务规划 | planner Agent, /plan | sisyphus Agent |
| 代码实现 | hephaestus-like Agent | hephaestus Agent |
| 知识检索 | docs-lookup Agent | librarian Agent |
| 上下文压缩 | Strategic compact hook | preemptive-compaction |
| 循环执行 | loop-operator, /loop-start | ralph-loop |
| 规则注入 | rules-injector | rules-injector |
