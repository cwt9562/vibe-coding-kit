/**
 * Compaction Context Injector Plugin for OpenCode
 *
 * 功能：在 session compaction 时注入结构化摘要提示词，确保压缩后的上下文
 * 保留用户请求、工作目标、已完成工作、待办事项、活跃文件、约束条件等
 * 关键连续性信息。
 *
 * 触发时机：experimental.session.compacting
 *
 * 参考来源：omo/compaction-context-injector
 * 注：此版本仅实现 prompt 注入，不包含 agent/model/tools 恢复逻辑。
 */

const COMPACTION_CONTEXT_PROMPT = `When summarizing this session, you MUST include the following sections in your summary:

## 1. User Requests (As-Is)
- List all original user requests exactly as they were stated
- Preserve the user's exact wording and intent

## 2. Final Goal
- What the user ultimately wanted to achieve
- The end result or deliverable expected

## 3. Work Completed
- What has been done so far
- Files created/modified
- Features implemented
- Problems solved

## 4. Remaining Tasks
- What still needs to be done
- Pending items from the original request
- Follow-up tasks identified during the work

## 5. Active Working Context (For Seamless Continuation)
- **Files**: Paths of files currently being edited or frequently referenced
- **Code in Progress**: Key code snippets, function signatures, or data structures under active development
- **External References**: Documentation URLs, library APIs, or external resources being consulted
- **State & Variables**: Important variable names, configuration values, or runtime state relevant to ongoing work

## 6. Explicit Constraints (Verbatim Only)
- Include ONLY constraints explicitly stated by the user or in existing AGENTS.md context
- Quote constraints verbatim (do not paraphrase)
- Do NOT invent, add, or modify constraints
- If no explicit constraints exist, write "None"

## 7. Agent Verification State (Critical for Reviewers)
- **Current Agent**: What agent is running (momus, oracle, etc.)
- **Verification Progress**: Files already verified/validated
- **Pending Verifications**: Files still needing verification
- **Previous Rejections**: If reviewer agent, what was rejected and why
- **Acceptance Status**: Current state of review process

This section is CRITICAL for reviewer agents to maintain continuity.

## 8. Delegated Agent Sessions
- List ALL background agent tasks spawned during this session
- For each: agent name, category, status, description, and **session_id**
- **RESUME, DON'T RESTART.** Each listed session retains full context. After compaction, use \`session_id\` to continue existing agent sessions instead of spawning new ones. This saves tokens, preserves learned context, and prevents duplicate work.

This context is critical for maintaining continuity after compaction.`;

export const CompactionContextInjectorPlugin = async () => {
  return {
    "experimental.session.compacting": async (_input, output) => {
      if (output && typeof output === "object") {
        output.prompt = COMPACTION_CONTEXT_PROMPT;
      }
    },
  };
};
