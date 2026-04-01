#!/usr/bin/env node

/**
 * Question Label Truncator for Claude Code
 *
 * 功能：在 AskUserQuestion 工具执行前，自动截断过长的 option label（>30 字符）
 *
 * Claude Code Hook: PreToolUse -> AskUserQuestion
 *
 * 参考来源：omo/question-label-truncator
 */

let raw = "";
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  const input = JSON.parse(raw);

  const tool = input?.tool_name?.toLowerCase();
  if (tool !== "askuserquestion") {
    process.stdout.write(raw);
    return;
  }

  const MAX_LABEL_LENGTH = 30;

  function truncateLabel(label) {
    if (label.length <= MAX_LABEL_LENGTH) {
      return label;
    }
    return label.substring(0, MAX_LABEL_LENGTH - 3) + "...";
  }

  const toolInput = input?.tool_input || {};
  const questions = toolInput?.questions;

  if (!questions || !Array.isArray(questions)) {
    process.stdout.write(raw);
    return;
  }

  const updatedQuestions = questions.map((question) => ({
    ...question,
    options:
      question.options?.map((option) => ({
        ...option,
        label: truncateLabel(option.label),
      })) ?? [],
  }));

  const output = {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      updatedInput: {
        ...toolInput,
        questions: updatedQuestions,
      },
    },
  };

  process.stdout.write(JSON.stringify(output));
});
