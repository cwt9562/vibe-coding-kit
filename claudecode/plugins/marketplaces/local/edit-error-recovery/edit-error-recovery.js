#!/usr/bin/env node

/**
 * Edit Error Recovery for Claude Code
 *
 * 功能：监听 Edit 工具执行结果，检测常见 AI 错误模式，通过 stderr 发出警告
 *
 * Claude Code Hook: PostToolUse -> Edit
 */

let raw = "";
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  const input = JSON.parse(raw);

  const tool = input?.tool_name?.toLowerCase();
  if (tool !== "edit") {
    process.stdout.write(raw);
    return;
  }

  const EDIT_ERROR_PATTERNS = [
    "oldstring and newstring must be different",
    "oldstring not found",
    "oldstring found multiple times",
  ];

  const EDIT_ERROR_REMINDER = `[EDIT ERROR - IMMEDIATE ACTION REQUIRED]

You made an Edit mistake. STOP and do this NOW:

1. READ the file immediately to see its ACTUAL current state
2. VERIFY what the content really looks like (your assumption was wrong)
3. APOLOGIZE briefly to the user for the error
4. CONTINUE with corrected action based on the real file content

DO NOT attempt another edit until you've read and verified the file state.`;

  const output = input?.tool_response?.output || "";
  const outputLower = output.toLowerCase();
  const hasError = EDIT_ERROR_PATTERNS.some((pattern) => outputLower.includes(pattern));

  if (hasError) {
    process.stderr.write(`\n${EDIT_ERROR_REMINDER}\n`);
  }

  process.stdout.write(raw);
});
