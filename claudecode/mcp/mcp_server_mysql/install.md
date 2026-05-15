# mcp-server-mysql

连接mysql数据库的mcp

来自开源项目
`https://github.com/benborla/mcp-server-mysql`

执行以下命令安装
```
npm install -g @benborla29/mcp-server-mysql
```
再配置到claudecode里，记得替换实际地址和账号
```
claude mcp add --scope user mcp_server_mysql \
  -e MYSQL_HOST="127.0.0.1" \
  -e MYSQL_PORT="3306" \
  -e MYSQL_USER="root" \
  -e MYSQL_PASS="your_password" \
  -e MYSQL_DB="your_database" \
```

用`claude mcp list`测试
```
$ claude mcp list
mcp_server_mysql: npx @benborla29/mcp-server-mysql - ✓ Connected
```