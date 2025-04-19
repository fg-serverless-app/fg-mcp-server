#!/bin/bash
cd /app

if [ -z "$CONFIG" ]; then
    echo "Error: CONFIG environment variable must be set"
    exit 1
fi

# 解析CONFIG
command=$(echo "$CONFIG" | jq -r '.mcpServers | to_entries[0].value | .command')
args=$(echo "$CONFIG" | jq -r '.mcpServers | to_entries[0].value | .args | join(" ")')
# 输出结果
echo "command: $command"
echo "args: $args"

finalCmd="$command $args"

echo "final command: $finalCmd"

# 如果command不是npx则报错退出
if [ "$command" != "npx" ]; then
    echo "错误: command必须是npx" >&2
    exit 1
fi

# 提取第一个服务器配置的环境变量
env_entries=$(echo "$CONFIG" | jq -r '.mcpServers | to_entries[0].value.env // empty | to_entries[] | "\(.key)=\(.value)"')

echo "Setting environment variables:"
while IFS= read -r line; do
  key=$(echo "$line" | cut -d= -f1)
  value=$(echo "$line" | cut -d= -f2-)
  export "$line" && echo "$line"
done <<< "$env_entries"

# 执行命令
npx --loglevel=verbose -y supergateway \
    --stdio "$finalCmd" \
    --port 8000 \
    --ssePath /sse \
    --messagePath /message \
    --cors
