/**
 * Question Label Truncator Plugin for OpenCode
 *
 * 功能：在 AskUserQuestion 工具执行前，自动截断过长的 option label（>30 字符）
 *
 * 触发时机：tool.execute.before（仅 AskUserQuestion 工具）
 *
 * 参考来源：omo/question-label-truncator
 */

const MAX_LABEL_LENGTH = 30;

function truncateLabel(label) {
  if (label.length <= MAX_LABEL_LENGTH) {
    return label;
  }
  return label.substring(0, MAX_LABEL_LENGTH - 3) + "...";
}

function truncateQuestionLabels(args) {
  if (!args.questions || !Array.isArray(args.questions)) {
    return args;
  }

  return {
    ...args,
    questions: args.questions.map((question) => ({
      ...question,
      options:
        question.options?.map((option) => ({
          ...option,
          label: truncateLabel(option.label),
        })) ?? [],
    })),
  };
}

export const QuestionLabelTruncatorPlugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      const toolName = input.tool?.toLowerCase();

      if (toolName !== "question") {
        return;
      }

      const args = output.args;
      if (args?.questions) {
        const truncatedArgs = truncateQuestionLabels(args);
        Object.assign(output.args, truncatedArgs);
      }
    },
  };
};
