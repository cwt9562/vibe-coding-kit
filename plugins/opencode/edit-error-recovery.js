/**
 * Edit Error Recovery Plugin for OpenCode
 *
 * 功能：监听 Edit 工具执行结果，检测常见 AI 错误模式，注入恢复提醒
 *
 * 检测的错误模式：
 * - oldString and newString must be different
 * - oldString not found (文件实际内容与 AI 假设不符)
 * - oldString found multiple times (匹配歧义，需要更多上下文)
 *
 * 触发时机：tool.execute.after (仅 edit 工具)
 */

const EDIT_ERROR_PATTERNS = [
  "oldString and newString must be different",
  "oldString not found",
  "oldString found multiple times",
];

const EDIT_ERROR_REMINDER = `
[EDIT ERROR - IMMEDIATE ACTION REQUIRED]

You made an Edit mistake. STOP and do this NOW:

1. READ the file immediately to see its ACTUAL current state
2. VERIFY what the content really looks like (your assumption was wrong)
3. APOLOGIZE briefly to the user for the error
4. CONTINUE with corrected action based on the real file content

DO NOT attempt another edit until you've read and verified the file state.
`;

export const EditErrorRecoveryPlugin = async () => {
  return {
    "tool.execute.after": async (input, output) => {
      if (input.tool?.toLowerCase() !== "edit") return;
      if (typeof output.output !== "string") return;

      const outputLower = output.output.toLowerCase();
      const hasError = EDIT_ERROR_PATTERNS.some((pattern) =>
        outputLower.includes(pattern.toLowerCase())
      );

      if (hasError) {
        output.output += `\n${EDIT_ERROR_REMINDER}`;
      }
    },
  };
};
