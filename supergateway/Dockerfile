# 构建阶段
FROM node:23.11.0-slim as build

ENV npm_config_registry=https://registry.npmmirror.com

# 创建用户和组并设置工作目录权限
RUN groupadd -g 1003 appuser && \
    useradd -u 1003 -g appuser -m appuser && \
    mkdir -p /app && \
    chown -R 1003:1003 /app

WORKDIR /app

# 以1003用户身份执行npm操作
USER 1003

# 设置npm缓存到用户目录
ENV NPM_CONFIG_CACHE=/home/appuser/.npm \
    NPM_CONFIG_PREFIX=/home/appuser/.npm

RUN npm init -y && \
    npm install supergateway

# 运行阶段
FROM node:23.11.0-slim as runner

ENV npm_config_registry=https://registry.npmmirror.com

# 创建相同的用户和组
RUN groupadd -g 1003 appuser && \
    useradd -u 1003 -g appuser -m appuser

# 设置npm缓存目录
RUN apt-get update && apt-get install -y jq && apt-get clean && rm -rf /var/lib/apt/lists/*
USER 1003
ENV NPM_CONFIG_CACHE=/home/appuser/.npm \
    NPM_CONFIG_PREFIX=/home/appuser/.npm

# 复制文件并设置权限
COPY --chown=1003:1003 --from=build /app /app
COPY --chown=1003:1003 bootstrap.sh /app/bootstrap.sh

WORKDIR /app

# 确保脚本可执行
RUN chmod +x /app/bootstrap.sh

# 以1003用户身份运行
USER 1003

CMD [ "bash", "/app/bootstrap.sh" ]
