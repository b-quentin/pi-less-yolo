FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    git \
    make \
    xz-utils \
    fd-find \
    ripgrep \
    && ln -s /usr/bin/fdfind /usr/bin/fd \
    && rm -rf /var/lib/apt/lists/*

ARG BUN_VERSION=1.3.14
ARG TARGETARCH
RUN ARCH=$([ "$TARGETARCH" = "arm64" ] && echo "aarch64" || echo "x64") && \
    curl -Lo /tmp/bun.zip \
    "https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-${ARCH}.zip" \
    && unzip /tmp/bun.zip -d /tmp \
    && mv /tmp/bun-linux-${ARCH}/bun /usr/local/bin/bun \
    && chmod +x /usr/local/bin/bun \
    && rm -rf /tmp/bun*

ARG USER_UID=1000
ARG USER_GID=1000
RUN if ! getent group ${USER_GID} > /dev/null 2>&1; then \
        groupadd -g ${USER_GID} piuser; \
    fi \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash piuser \
    && mkdir -p /workspace \
    && chown ${USER_UID}:${USER_GID} /workspace

COPY --chown=piuser:piuser docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER piuser
ENV HOME=/home/piuser
ARG NODE_VERSION=24
ENV PATH="/home/piuser/.local/bin:/home/piuser/.local/share/mise/shims:/home/piuser/.bun/bin:${PATH}"

RUN curl https://mise.run | sh
RUN mise use -g node@${NODE_VERSION}

RUN bun add -g --ignore-scripts @earendil-works/pi-coding-agent

RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
