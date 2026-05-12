#!/usr/bin/env node

/**
 * Comment Checker for Claude Code
 *
 * 功能：检测 write/edit 工具写入代码中的 AI 风格注释
 * 支持语言：Java / JS / TS / Vue / Shell
 *
 * Claude Code Hook: PostToolUse -> Write / Edit / MultiEdit
 */

const fs = require("fs");

// ============================================================
// 第 1 部分：正则模式
// ============================================================

const AI_MEMO_PATTERNS = [
  [/^[\s#\/*-]*changed?\s+(from|to)\b/i],
  [/^[\s#\/*-]*modified?\s+(from|to)?\b/i],
  [/^[\s#\/*-]*updated?\s+(from|to)?\b/i],
  [/^[\s#\/*-]*refactor(ed|ing)?\b/i],
  [/^[\s#\/*-]*moved?\s+(from|to)\b/i],
  [/^[\s#\/*-]*renamed?\s+(from|to)?\b/i],
  [/^[\s#\/*-]*replaced?\b/i],
  [/^[\s#\/*-]*removed?\b/i],
  [/^[\s#\/*-]*deleted?\b/i],
  [/^[\s#\/*-]*added?\b/i],
  [/^[\s#\/*-]*implemented?\b/i],
  [/^[\s#\/*-]*converted?\s+(from|to)\b/i],
  [/^[\s#\/*-]*migrated?\s+(from|to)?\b/i],
  [/^[\s#\/*-]*switched?\s+(from|to)\b/i],
  [/^[\s#\/*-]*was\s+changed\b/i],
  [/^[\s#\/*-]*implementation\s+(of|note)\b/i],
  [/^[\s#\/*-]*here\s+we\b/i],
  [/^[\s#\/*-]*now\s+(we|this|it)\b/i],
  [/^[\s#\/*-]*previously\b/i],
  [/^[\s#\/*-]*before\s+this\b/i],
  [/^[\s#\/*-]*after\s+this\b/i],
  [/^[\s#\/*-]*this\s+(implements?|adds?|removes?|changes?|fixes?)\b/i],
  [/^[\s#\/*-]*note:\s*\w/i],
  [/^[\s#\/*-]*[a-z]+\s*->\s*[a-z]+/i],
  [/^\s*(\/\/|#|\/\*)\s*TODO/i],
  [/^\s*(\/\/|#|\/\*)\s*FIXME/i],
  [/^\s*(\/\/|#|\/\*)\s*HACK/i],
  [/^\s*(\/\/|#|\/\*)\s*XXX/i],
  [/^\s*(\/\/|#|\/\*)\s*WIP/i],
  [/^\s*(\/\/|#|\/\*)\s*UNFINISHED/i],
  [/^[\s#\/*-]*iterate\s+(through|over)\s+(the\s+)?/i],
  [/^[\s#\/*-]*loop\s+(through|over)\s+(the\s+)?/i],
  [/^[\s#\/*-]*adds?\s+(one|a|1)\s+(to|plus)\s+(one|a|1)/i],
  [/^[\s#\/*-]*subtracts?\s+(one|a|1)\s+(from|minus)\s+(one|a|1)/i],
  [/^[\s#\/*-]*check\s+(if|whether)\s+(the\s+)?/i],
  [/^[\s#\/*-]*validate\s+(the\s+)?/i],
  [/^[\s#\/*-]*get\s+(the\s+)?/i],
  [/^[\s#\/*-]*set\s+(the\s+)?/i],
  [/^[\s#\/*-]*create\s+(a|an|the)?\s*(new)?/i],
  [/^[\s#\/*-]*return\s+(the|true|false|null)/i],
  [/^[\s#\/*-]*returns?\s+(the|true|false|null)/i],
  [/^[\s#\/*-]*this\s+function\s+(returns?|checks?|validates?)/i],
  [/^[\s#\/*-]*this\s+method\s+(returns?|checks?|validates?)/i],
  [/^[\s#\/*-]*this\s+class\s+(represents?|handles?)/i],
  [/^[\s#\/*-]*handles?\s+(the\s+)?/i],
  [/^[\s#\/*-]*processes?\s+(the\s+)?/i],
  [/^[\s#\/*-]*initializes?\s+(the\s+)?/i],
  [/^[\s#\/*-]*called\s+(when|before|after)\s+(the\s+)?/i],
  [/^[\s#\/*-]*used?\s+to\s+(check|get|set|validate)/i],
  [/^[\s#\/*-]*converts?\s+(the|a|an)?\s*(string|number|data|value)/i],
  [/^[\s#\/*-]*parses?\s+(the|a|an)?\s*(json|xml|html|string|data)/i],
  [/^[\s#\/*-]*generates?\s+(a|an|the)?\s*(unique|random)/i],
  [/^[\s#\/*-]*sends?\s+(the|a)?\s*(request|email|notification)/i],
  [/^[\s#\/*-]*receives?\s+(the|a)?\s*(request|data|response)/i],
  [/^[\s#\/*-]*logs?\s+(the|a)?\s*(error|message|info|warning)/i],
  [/^[\s#\/*-]*handles?\s+(the\s+)?error(s)?/i],
  [/^[\s#\/*-]*fetches?\s+(the|a)?\s*(data|from)\b/i],
  [/^[\s#\/*-]*loads?\s+(the|a)?\s*(config|data|file)/i],
  [/^[\s#\/*-]*saves?\s+(the|a)?\s*(data|config|state)/i],
  [/^[\s#\/*-]*updates?\s+(the|a)?\s*(state|data|record)/i],
  [/^[\s#\/*-]*deletes?\s+(the|a)?\s*(record|data|item)/i],
  [/^[\s#\/*-]*inserts?\s+(the|a)?\s*(record|data|item)/i],
  [/^[\s#\/*-]*maps?\s+(the|a)?\s*(items?|data|elements?)\b/i],
  [/^[\s#\/*-]*filters?\s+(the|a)?\s*(items?|data|elements?)\b/i],
  [/^[\s#\/*-]*reduces?\s+(the|a)?\s*(items?|data|array)\b/i],
  [/^[\s#\/*-]*transforms?\s+(the|a)?\s*(data|value|array)\b/i],
  [/^[\s#\/*-]*merges?\s+(the|a)?\s*(data|objects?|arrays?)\b/i],
  [/^[\s#\/*-]*extracts?\s+(the|a)?\s*(data|value|properties?)\b/i],
  [/^[\s#\/*-]*=\s*\w+\s*\(/i],
  [/^[\s#\/*-]*\(\)\s*=>/i],
  [/^[\s#\/*-]*(if|else|for|while|switch)\s*\(/i],
  [/^[\s#\/*-]*try\s*\{/i],
  [/^[\s#\/*-]*catch\s*\(/i],
  [/^[\s#\/*-]*return\s+\w/i],
  [/^[\s#\/*-]*import\s+\w/i],
  [/^[\s#\/*-]*export\s+(default|const|function|class)/i],
  [/^[\s#\/*-]*@?[a-z]+\s*\(\s*['"][^'"]+['"]\s*\)/i],
  [/^[\s#\/*-]*\{[\s\S]*?\}\s*;?\s*$/],
  [/^[\s#\/*-]*<\w+[^>]*>/i],
  [/^[\s#\/*-]*class\s+\w+/i],
  [/^[\s#\/*-]*function\s+\w+/i],
  [/^[\s#\/*-]*const\s+\w+/i],
  [/^[\s#\/*-]*let\s+\w+/i],
  [/^[\s#\/*-]*var\s+\w+/i],
  [/^[\s#\/*-]*public\s+(static\s+)?(final|void|int|string|bool)/i],
  [/^[\s#\/*-]*private\s+(static\s+)?(final\s+)?(void|int|string|bool)/i],
  [/^[\s#\/*-]*protected\s+/i],
  [/^[\s#\/*-]*interface\s+\w+/i],
  [/^[\s#\/*-]*abstract\s+/i],
  [/^[\s#\/*-]*extends\s+\w+/i],
  [/^[\s#\/*-]*implements\s+\w+/i],
  [/^[\s#\/*-]*new\s+\w+/i],
  [/^[\s#\/*-]*async\s+(function|const|let)/i],
  [/^[\s#\/*-]*await\s+\w/i],
  [/^[\s#\/*-]*try\s+/i],
  [/^[\s#\/*-]*finally\s+/i],
];

const BDD_KEYWORDS = new Set([
  "given", "when", "then", "arrange", "act", "assert",
  "when & then", "when&then",
]);

const DIRECTIVE_PREFIXES = [
  "noqa", "type:", "pyright:", "ruff:", "mypy:",
  "pylint:", "flake8:", "pyre:", "pytype:",
  "eslint-disable", "eslint-ignore", "prettier-ignore",
  "ts-ignore", "ts-expect-error", "tsc:",
  "clippy:", "allow:", "deny:", "warn:", "forbid:",
  "@ts-ignore", "@ts-expect-error", "@eslint-disable",
];

// ============================================================
// 第 2 部分：核心检测逻辑
// ============================================================

function stripCommentPrefix(text) {
  text = text.trim();
  for (const prefix of ["//", "#", "/*", "--", "*", "<!--", "-->"]) {
    if (text.startsWith(prefix)) {
      text = text.slice(prefix.length).trim();
    }
  }
  return text;
}

function isAllowedComment(text) {
  const normalized = text.trim().toLowerCase();
  if (normalized.startsWith("#!")) return true;
  const stripped = stripCommentPrefix(text);
  if (BDD_KEYWORDS.has(stripped.toLowerCase())) return true;
  const lower = stripped.toLowerCase();
  for (const directive of DIRECTIVE_PREFIXES) {
    if (lower.startsWith(directive.toLowerCase())) return true;
  }
  return false;
}

function isAIMemoComment(text) {
  const stripped = stripCommentPrefix(text);
  for (const [pattern] of AI_MEMO_PATTERNS) {
    if (pattern.test(stripped)) return true;
  }
  return false;
}

function truncate(str, maxLen) {
  return str.length > maxLen ? str.slice(0, maxLen) + "..." : str;
}

// ============================================================
// 第 3 部分：注释提取
// ============================================================

function extractComments(content, filePath) {
  const ext = filePath.split(".").pop()?.toLowerCase() || "";
  const basename = filePath.split(/[/\\]/).pop()?.toLowerCase() || "";

  const isShell = ["sh", "bash", "zsh", "ksh", "fish", "ps1"].includes(ext) ||
    basename === "dockerfile" || basename === "makefile" || basename === "akefile" ||
    ext === "bashrc" || ext === "zshrc" || ext === "bash_profile";

  const isVue = ext === "vue" || ext === "wpy";
  const isJS = ["js", "jsx", "mjs", "cjs", "ts", "tsx", "mts"].includes(ext);
  const isJava = ["java", "kt", "kts"].includes(ext);

  const comments = [];
  const lines = content.split("\n");

  if (isShell) {
    lines.forEach((line, idx) => {
      const trimmed = line.trim();
      if (trimmed.startsWith("#") && !trimmed.startsWith("#!")) {
        comments.push({ text: line, lineNumber: idx + 1 });
      }
    });
  } else if (isVue) {
    const htmlRegex = /<!--[\s\S]*?-->/g;
    let match;
    while ((match = htmlRegex.exec(content)) !== null) {
      const startLine = content.substring(0, match.index).split("\n").length;
      comments.push({ text: match[0], lineNumber: startLine });
    }
    extractJSComments(content, lines, comments);
  } else if (isJS) {
    extractJSComments(content, lines, comments);
  } else if (isJava) {
    extractJavaComments(content, lines, comments);
  }

  return comments;
}

function extractJSComments(content, lines, comments) {
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();
    if (trimmed.startsWith("//")) {
      comments.push({ text: lines[i], lineNumber: i + 1 });
    }
  }
  const blockRegex = /\/\*[\s\S]*?\*\//g;
  let match;
  while ((match = blockRegex.exec(content)) !== null) {
    const startLine = content.substring(0, match.index).split("\n").length;
    comments.push({ text: match[0], lineNumber: startLine });
  }
}

function extractJavaComments(content, lines, comments) {
  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim();
    if (trimmed.startsWith("//")) {
      comments.push({ text: lines[i], lineNumber: i + 1 });
    }
  }
  const blockRegex = /\*\*[\s\S]*?\*\/|\/\*[\s\S]*?\*\//g;
  let match;
  while ((match = blockRegex.exec(content)) !== null) {
    const startLine = content.substring(0, match.index).split("\n").length;
    comments.push({ text: match[0], lineNumber: startLine });
  }
}

// ============================================================
// 第 4 部分：主检测函数
// ============================================================

function detectAIComments(content, filePath) {
  const comments = extractComments(content, filePath);
  const badComments = [];

  for (const comment of comments) {
    const text = comment.text;
    if (isAllowedComment(text)) continue;
    const stripped = stripCommentPrefix(text).trim();
    if (!stripped || stripped === "*" || stripped === "*/") continue;
    if (isAIMemoComment(text)) {
      badComments.push({ lineNumber: comment.lineNumber, text: comment.text.trim() });
    }
  }
  return badComments;
}

function buildWarningMessage(badComments) {
  const lines = badComments.map((c) => `  line ${c.lineNumber}: ${truncate(c.text, 80)}`);
  return (
    `\n[AI COMMENT DETECTED]\n` +
    `Found ${badComments.length} AI-style comment(s) in this file:\n` +
    lines.join("\n") +
    `\n\nConsider removing these comments or replacing them with meaningful documentation.`
  );
}

// ============================================================
// 第 5 部分：Hook 入口
// ============================================================

let raw = "";
process.stdin.on("data", (chunk) => (raw += chunk));
process.stdin.on("end", () => {
  const input = JSON.parse(raw);
  const tool = input?.tool_name?.toLowerCase();

  if (tool !== "write" && tool !== "edit" && tool !== "multiedit") {
    process.stdout.write(raw);
    return;
  }

  const toolInput = input?.tool_input || {};
  const filePath = toolInput?.file_path;

  if (!filePath) {
    process.stdout.write(raw);
    return;
  }

  let content;
  if (tool === "write") {
    content = toolInput?.content;
  } else {
    try {
      content = fs.readFileSync(filePath, "utf8");
    } catch {
      process.stdout.write(raw);
      return;
    }
  }

  if (!content) {
    process.stdout.write(raw);
    return;
  }

  const bad = detectAIComments(content, filePath);
  if (bad.length > 0) {
    process.stderr.write(buildWarningMessage(bad) + "\n");
  }

  process.stdout.write(raw);
});
