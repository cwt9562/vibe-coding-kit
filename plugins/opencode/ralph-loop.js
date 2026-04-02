/**
 * Ralph Loop Plugin for OpenCode
 *
 * 功能：自引用开发循环，直到 Agent 输出完成信号才停止
 *
 * 核心机制：
 * 1. 监听 session.idle 事件（Agent 空闲时触发）
 * 2. 检测输出中是否包含 <ralph>DONE</ralph> 完成信号
 * 3. 如果没有，注入 continuation prompt 让 Agent 继续工作
 *
 * 触发时机：session.idle
 */

// 完成信号，默认 <ralph>DONE</ralph>
const DEFAULT_COMPLETION_SIGNAL = "DONE";

// 状态存储
let loopState = {
  active: false,
  iteration: 0,
  maxIterations: 100,
  prompt: "",
  completionSignal: DEFAULT_COMPLETION_SIGNAL,
};

// 状态文件路径
const STATE_FILE = ".vibe/ralph-loop.state.json";

const fs = require("fs");
const path = require("path");

function getStateDir() {
  return ".vibe";
}

function getStateFile() {
  return path.join(getStateDir(), "ralph-loop.state.json");
}

function readState() {
  try {
    const stateFile = getStateFile();
    if (fs.existsSync(stateFile)) {
      return JSON.parse(fs.readFileSync(stateFile, "utf-8"));
    }
  } catch {}
  return null;
}

function writeState(state) {
  try {
    const stateDir = getStateDir();
    if (!fs.existsSync(stateDir)) {
      fs.mkdirSync(stateDir, { recursive: true });
    }
    fs.writeFileSync(getStateFile(), JSON.stringify(state, null, 2));
  } catch (e) {
    console.error("[ralph-loop] Failed to write state:", e);
  }
}

function clearState() {
  try {
    const stateFile = getStateFile();
    if (fs.existsSync(stateFile)) {
      fs.unlinkSync(stateFile);
    }
  } catch {}
}

// 检测输出中是否包含完成信号
function detectCompletion(output, signal) {
  if (!output) return false;
  const pattern = new RegExp(`<ralph>\\s*${signal}\\s*</ralph>`, "i");
  return pattern.test(output);
}

// 构建 continuation prompt
function buildContinuationPrompt(state) {
  return `[RALPH LOOP ${state.iteration}/${state.maxIterations}]

Your previous response did not include the completion signal <ralph>DONE</ralph>.
Continue working on the task.

IMPORTANT:
- Review your progress so far
- Continue from where you left off
- When FULLY complete, output: <ralph>DONE</ralph>
- Do NOT stop until the task is truly done

Original task:
${state.prompt}`;
}

// 注入 continuation prompt
async function injectContinuation(ctx, sessionID, prompt) {
  try {
    await ctx.client.session.promptAsync({
      path: { id: sessionID },
      body: {
        parts: [{ type: "text", text: prompt }],
      },
    });
    console.log(`[ralph-loop] Continuation injected to session ${sessionID}`);
  } catch (e) {
    console.error("[ralph-loop] Failed to inject continuation:", e);
  }
}

// Start Ralph Loop
function startLoop(prompt, options = {}) {
  loopState = {
    active: true,
    iteration: 0,
    maxIterations: options.maxIterations || 100,
    prompt: prompt,
    completionSignal: options.completionSignal || DEFAULT_COMPLETION_SIGNAL,
  };
  writeState(loopState);
  console.log(`[ralph-loop] Loop started with prompt: "${prompt.slice(0, 50)}..."`);
}

// Cancel Ralph Loop
function cancelLoop() {
  loopState.active = false;
  clearState();
  console.log("[ralph-loop] Loop cancelled");
}

// 插件主函数
export const RalphLoopPlugin = async () => {
  return {
    // Agent 空闲时触发
    "session.idle": async (event) => {
      const props = event?.properties || {};
      const sessionID = props?.sessionID;
      if (!sessionID) return;

      // 检查 loop 状态
      const state = readState();
      if (!state || !state.active) return;

      // 获取 session 输出
      const output = props?.lastMessage || "";

      // 检测完成信号
      if (detectCompletion(output, state.completionSignal)) {
        console.log(`[ralph-loop] Completion detected! Stopping loop.`);
        cancelLoop();
        return;
      }

      // 检查是否达到最大迭代次数
      if (state.iteration >= state.maxIterations) {
        console.log(`[ralph-loop] Max iterations (${state.maxIterations}) reached. Stopping.`);
        cancelLoop();
        return;
      }

      // 继续循环
      state.iteration += 1;
      writeState(state);

      const continuationPrompt = buildContinuationPrompt(state);
      await injectContinuation(ctx, sessionID, continuationPrompt);
    },

    // Session 删除时清理状态
    "session.deleted": async (event) => {
      const props = event?.properties || {};
      const sessionID = props?.sessionID;
      if (!sessionID) return;

      const state = readState();
      if (state && state.sessionID === sessionID) {
        cancelLoop();
      }
    },

    // 手动启动 loop 的 command
    "command.executed": async (command, args) => {
      if (command === "/ralph-loop" || command === "ralph-loop") {
        const prompt = args?.[0] || "Continue working";
        const options = {};
        startLoop(prompt, options);
        return { content: `Ralph Loop started: "${prompt}"` };
      }

      if (command === "/cancel-ralph" || command === "cancel-ralph") {
        cancelLoop();
        return { content: "Ralph Loop cancelled" };
      }
    },
  };
};

// 导出 start/cancel 函数供外部调用
export { startLoop, cancelLoop };
