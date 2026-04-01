### 开发 Plugin

#### OpenCode Plugin

1. **创建文件**：在 `plugins/opencode/<plugin-name>.js` 中编写插件逻辑。
2. **导出插件**：导出一个异步工厂函数，返回需要监听的事件处理器。

   ```js
   export const MyPlugin = async () => {
     return {
       "tool.execute.after": async (input, output) => {
         // input.tool / output.output
       },
     };
   };
   ```

3. **注册插件**：在 `config/opencode/opencode.json` 的 `plugin` 数组中加入文件路径：

   ```json
   "plugin": [
     "./plugins/my-plugin.js"
   ]
   ```

4. **发布**：运行 `./publish.sh`，脚本会自动将插件文件复制到 `~/.config/opencode/plugins/`。

#### Claude Code Plugin（Marketplace 形式）

1. **创建目录结构**：

   ```
   plugins/claudecode/marketplaces/local/<plugin-name>/
   ├── <plugin-name>.js              # Hook 脚本（Node.js，需 shebang）
   ├── hooks/
   │   └── hooks.json                # 关联 Hook 事件与脚本
   └── .claude-plugin/
       └── plugin.json               # 插件元数据
   ```

2. **编写脚本**：脚本需以 `#!/usr/bin/env node` 开头，从 `stdin` 读取 JSON 输入，通过 `stdout` 透传原始数据，`stderr` 输出警告/提示。

3. **配置 hooks**：`hooks/hooks.json` 示例：

   ```json
   {
     "hooks": {
       "PostToolUse": [
         {
           "matcher": "Edit",
           "hooks": [
             {
               "type": "command",
               "command": "${CLAUDE_PLUGIN_ROOT}/my-plugin.js"
             }
           ]
         }
       ]
     }
   }
   ```

4. **注册到 marketplace**：在 `plugins/claudecode/marketplaces/local/.claude-plugin/marketplace.json` 中添加：

   ```json
   {
     "name": "my-plugin",
     "source": "./my-plugin",
     "description": "插件描述"
   }
   ```

5. **更新发布脚本**：在 `publish.sh` 的 Claude Code 发布段添加安装命令：

   ```bash
   claude plugin install my-plugin@local 2>/dev/null || true
   ```

6. **发布**：运行 `./publish.sh`，脚本会自动注册 marketplace 并执行 `claude plugin install`。
