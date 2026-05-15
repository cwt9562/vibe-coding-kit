#!/usr/bin/env node

/**
 * Captain Agent PreToolUse Hook
 *
 * Intercepts calls to forbidden tools (Bash, Edit, WebFetch, WebSearch, Write,
 * and designated MCP tools) and outputs delegation hints via stderr.
 * The original JSON passes through stdout unchanged.
 */

const FORBIDDEN_TOOLS = ['Bash', 'Edit', 'WebFetch', 'WebSearch', 'Write'];

const DELEGATION_HINTS = {
  Bash: {
    task: '执行终端命令',
    target: '@developer（代码类）或 @assistant（配置/文档类）'
  },
  Edit: {
    task: '文件编辑',
    target: '@developer（代码修改）或 @assistant（配置/文档修改）'
  },
  Write: {
    task: '文件写入',
    target: '@developer（代码写入）或 @assistant（配置/文档写入）'
  },
  WebFetch: {
    task: '网页获取',
    target: '@librarian'
  },
  WebSearch: {
    task: '网络搜索',
    target: '@librarian'
  }
};

const MCP_DELEGATION_HINTS = {
  'mcp__ddg-search': {
    task: 'DuckDuckGo 搜索',
    target: '@librarian'
  },
  'mcp__context7': {
    task: 'Context7 技术文档查询',
    target: '@oracle'
  },
  'mcp__mcp_server_mysql': {
    task: 'MySQL 数据库查询',
    target: '@assistant'
  }
};

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => {
  input += chunk;
});
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name;

    let hint = null;

    // Check built-in forbidden tools (exact match)
    if (FORBIDDEN_TOOLS.includes(toolName)) {
      hint = DELEGATION_HINTS[toolName];
    }

    // Check MCP tool prefixes (prefix match)
    if (!hint) {
      for (const [prefix, mcpHint] of Object.entries(MCP_DELEGATION_HINTS)) {
        if (toolName.startsWith(prefix + '__')) {
          hint = mcpHint;
          break;
        }
      }
    }

    // Pass through if tool is not forbidden
    if (!hint) {
      console.log(input);
      return;
    }

    // Output delegation hint to stderr
    process.stderr.write(`\n【策略提醒】你正在尝试调用被禁用的 ${toolName} 工具。作为 captain，你的职责是主控调度。请立即使用 Agent/Task 工具将 ${hint.task} 任务委派给 ${hint.target}。\n\n`);

    // Always pass through the original JSON
    console.log(input);
  } catch {
    // Invalid JSON, just pass through
    console.log(input);
  }
});
