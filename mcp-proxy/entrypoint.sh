#!/bin/bash

# Set default values if not provided
MCP_SERVER=${MCP_SERVER:-""}
SSE_PORT=${SSE_PORT:-8000}
SSE_HOST=${SSE_HOST:-0.0.0.0}


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
if [ "$command" != "uvx" ]; then
    echo "错误: command必须是uvx" >&2
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

mcp-proxy \
    --sse-port "$SSE_PORT" \
    --sse-host "$SSE_HOST" \
    --allow-origin '*' \
    --pass-environment \
    -- $finalCmd
