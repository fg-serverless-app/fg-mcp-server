FROM python:3.13-slim

ENV PATH=$PATH:/home/appuser/.local/bin
ENV UV_NO_CACHE=0
ENV MCP_SERVER=""
ENV SSE_PORT=8000
ENV SSE_HOST=0.0.0.0

RUN addgroup --gid 1003 appuser && \
    adduser --uid 1003 --gid 1003 appuser

RUN apt-get update && apt-get install -y jq && apt-get clean && rm -rf /var/lib/apt/lists/*

USER appuser

RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip install uv tzdata --no-cache-dir

ENV UV_INDEX_URL=https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

RUN uv tool install mcp-proxy

WORKDIR /home/appuser
COPY --chown=appuser:appuser entrypoint.sh ./
RUN chmod +x entrypoint.sh

CMD ["/home/appuser/entrypoint.sh"]
