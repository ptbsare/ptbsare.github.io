FROM node:latest
LABEL maintainer="ptbsare"
WORKDIR /space
ARG DEBIAN_FRONTEND="noninteractive"
ARG HEXO_BUILD_VERSION='latest'
ARG SB_BUILD_VERSION='latest'
ARG VSCODE_BUILD_VERSION='latest'
ENV LANG=C.UTF-8
ENV PUID=1001
ENV PGID=100
ENV HOME="/config"
ENV SB_HOSTNAME=0.0.0.0
ENV SB_KV_DB="${HOME}/silverbullet.db"
ENV SB_FOLDER="/space"
ENV SB_PORT=3000
ENV HEXO_PORT=6000
ENV VS_PORT=9000
ENV ENABLE_WORKSPACE_TRUST=''
ENV DEFAULT_WORKSPACE="/space"
ENV SOURCE_ROOT="/space"
ENV GIT_USERNAME=user
ENV GIT_EMAIL=user@mail.com
ENV GIT_SOURCE=''
ENV GIT_DEPLOY=''
ENV HEXO_VERSION='latest'
ENV SB_VERSION='latest'
ENV VSCODE_VERSION='latest'
ENV AUTO_UPGRADE_HEXO=''
ENV AUTO_UPGRADE_VSCODE=''
ENV AUTO_UPGRADE_SB=''
RUN \
    echo "*** install nodejs hexo and runtime dependencies ***" && \
    apt update && apt install -y \
    psmisc \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat-traditional \
    sudo  \
    curl \
    gosu \
    vim \
    git \
    tar \
    && npm install hexo-cli@${HEXO_BUILD_VERSION} -g 
RUN echo "*** install code-server ***"
RUN  VSCODE_RELEASE=$([ "$VSCODE_BUILD_VERSION" = latest ] && curl -fsS https://api.github.com/repos/coder/code-server/releases/latest | grep -Po '"tag_name": "\K[^"]+' | sed 's/^v//' || echo "$VSCODE_BUILD_VERSION") && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${VSCODE_RELEASE}/code-server-${VSCODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /usr/share/man
RUN \
  echo "*** install deno ***" && \
  curl -fsSL https://deno.land/x/install/install.sh | sh && mv $HOME/.deno/bin/deno /usr/local/bin/deno 
#Optional
#ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 /usr/bin/tini
RUN \
  echo "*** install silverbullet ***"
#RUN  deno install -f --name silverbullet --root /usr/local  --unstable-kv --unstable-worker-options -A https://get.silverbullet.md -g
RUN SILVERBULLET_RELEASE=$([ "$SB_BUILD_VERSION" = latest ] && curl -fsS https://api.github.com/repos/silverbulletmd/silverbullet/releases/latest | grep -Po '"tag_name": "\K[^"]+' | sed 's/^v//' || echo "$SB_BUILD_VERSION") && \
  curl -L https://github.com/silverbulletmd/silverbullet/releases/download/${SILVERBULLET_RELEASE}/silverbullet.js -o /silverbullet.js
VOLUME /space
VOLUME ${HOME}
EXPOSE ${SB_PORT} ${VS_PORT} ${HEXO_PORT}
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
