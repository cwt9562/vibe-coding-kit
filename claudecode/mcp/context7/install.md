# context7

连接context7查技术标准的mcp

来自开源项目
`https://github.com/upstash/context7`

需要先申请 api key：

1. 访问官网：在浏览器中打开 context7.com/dashboard。
2. 登录/注册：使用你的 GitHub 或 Google 账户免费登录并授权，这可以为你生成 API Key。
3. 创建 Key：登录成功后，在仪表盘页面找到 “Create API Key” 按钮并点击即可生成。妥善保管并复制生成的 Key。

再执行以下命令安装，记得替换 YOUR_API_KEY
```
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

用`claude mcp list`测试
```
$ claude mcp list
context7: cmd /c npx -y @upstash/context7-mcp --api-key YOUR_API_KEY - ✓ Connected
```