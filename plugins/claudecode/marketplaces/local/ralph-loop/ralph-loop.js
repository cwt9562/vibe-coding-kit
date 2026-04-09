#!/usr/bin/env node

/**
 * Ralph Loop for Claude Code
 *
 * 功能：通过 Stop hook 阻止 Agent 停止，实现自引用开发循环
 *
 * 核心机制：
 * 1. Stop hook 在 Agent 准备停止时触发
 * 2. 检测输出中是否包含 <ralph>DONE</ralph> 完成信号
 * 3. 如果没有完成，返回 {decision: "block"} 阻止停止，让 Agent 继续工作
 *
 * Claude Code Hook: Stop
 */

const fs = require("fs");
const path = require("path");

// 完成信号
const COMPLETION_SIGNAL = "DONE";

// 状态文件（由 getStateFile() 函数使用）

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
function detectCompletion(output) {
  if (!output) return false;
  const pattern = new RegExp(`<ralph>\\s*${COMPLETION_SIGNAL}\\s*</ralph>`, "i");
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

// Start Ralph Loop
function startLoop(prompt, options = {}) {
  const state = {
    active: true,
    iteration: 0,
    maxIterations: options.maxIterations || 100,
    prompt: prompt,
  };
  writeState(state);
  console.error(`[ralph-loop] Loop started: "${prompt.slice(0, 50)}..."`);
}

// Cancel Ralph Loop
function cancelLoop() {
  clearState();
  console.error("[ralph-loop] Loop cancelled");
}

// 主逻辑
let raw = "";
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    // 非 JSON 输入，原样输出
    process.stdout.write(raw);
    return;
  }

  // 检查是否是 /ralph-loop 命令（通过 prompt 字段）
  const prompt = input?.prompt || "";
  if (prompt.includes("/ralph-loop")) {
    // 从命令中提取 task
    const taskMatch = prompt.match(/\/ralph-loop\s+(.+)/);
    if (taskMatch) {
      startLoop(taskMatch[1].trim());
    } else {
      startLoop("Continue working");
    }
    // 继续处理，不要停止
    process.stdout.write(raw);
    return;
  }

  if (prompt.includes("/cancel-ralph")) {
    cancelLoop();
    process.stdout.write(raw);
    return;
  }

  // 检查 loop 状态
  const state = readState();
  if (!state || !state.active) {
    // 没有 active loop，允许停止
    process.stdout.write(raw);
    return;
  }

  // 获取最后一条消息
  const lastMessage = input?.last_assistant_message || "";

  // 检测完成信号
  if (detectCompletion(lastMessage)) {
    console.error("[ralph-loop] Completion detected! Stopping loop.");
    clearState();
    process.stdout.write(raw);
    return;
  }

  // 检查是否达到最大迭代次数
  if (state.iteration >= state.maxIterations) {
    console.error(`[ralph-loop] Max iterations reached. Stopping.`);
    clearState();
    process.stdout.write(raw);
    return;
  }

  // 检查是否已经在 stop hook 中（防止无限循环）
  if (input?.stop_hook_active) {
    console.error("[ralph-loop] Already in stop hook, allowing stop to prevent infinite loop.");
    clearState();
    process.stdout.write(raw);
    return;
  }

  // 检查是否是用户主动取消（通过判断 lastMessage 是否为空或特定取消标记）
  const isUserCancelled = !lastMessage || lastMessage === "" || input?.cancelled === true;
  if (isUserCancelled) {
    console.error("[ralph-loop] User cancelled, stopping loop.");
    clearState();
    process.stdout.write(raw);
    return;
  }

  // 没有完成，阻止停止，继续循环
  state.iteration += 1;
  writeState(state);

  const continuation = buildContinuationPrompt(state);
  console.error(`[ralph-loop] Iteration ${state.iteration}/${state.maxIterations} - continuing...`);

  // 输出阻止停止的响应
  const response = {
    decision: "block",
    reason: continuation,
  };

  console.log(JSON.stringify(response));
});
