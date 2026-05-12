#!/bin/sh
#安装特定版本HEXO
if [ ! $HEXO_VERSION = 'latest' ]; then
    echo "Installing HEXO@${HEXO_VERSION}"
    npm install hexo-cli@$HEXO_VERSION -g
fi
#安装特定版本SB
if [ ! $SB_VERSION = 'latest' ]; then
    echo "Installing SB@${SB_VERSION}"
    curl -L https://github.com/silverbulletmd/silverbullet/releases/download/${SB_VERSION}/silverbullet.js -o /silverbullet.js
fi
#安装特定版本VSCODE
if [ ! $VSCODE_VERSION = 'latest' ]; then
    echo "Installing VSCODE@${VSCODE_VERSION}"
    curl -o \
      /tmp/code-server.tar.gz -L \
      "https://github.com/coder/code-server/releases/download/v${VSCODE_VERSION}/code-server-${VSCODE_VERSION}-linux-amd64.tar.gz" && \
    tar xf /tmp/code-server.tar.gz -C \
      /app/code-server --strip-components=1 && \
    rm /tmp/code-server.tar.gz
fi
#升级HEXO
[ ! -z ${AUTO_UPGRADE_HEXO} ] && \
echo "*** install latest hexo ***" && \
npm install hexo-cli@latest -g
#升级VSCODE
[ ! -z ${AUTO_UPGRADE_VSCODE} ] && \
echo "*** install latest code-server ***" && \
mkdir -p /app/code-server && \
CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
| awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||') \
&& curl -o /tmp/code-server.tar.gz -L \
"https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
tar xf /tmp/code-server.tar.gz -C /app/code-server --strip-components=1
#升级SB
[ ! -z ${AUTO_UPGRADE_SB} ] && \
echo "*** install latest silverbullet ***" && \
#deno install -f --name silverbullet --root /usr/local  --unstable-kv --unstable-worker-options -A https://get.silverbullet.md -g && \
SILVERBULLET_RELEASE=$(curl -sX GET https://api.github.com/repos/silverbulletmd/silverbullet/releases/latest \
	      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||') \
	            && curl -L https://github.com/silverbulletmd/silverbullet/releases/download/${SILVERBULLET_RELEASE}/silverbullet.js -o /silverbullet.js
#设置git用户名邮箱
chsh -s /bin/bash
[ ! -z ${GIT_USER} ] && git config --global user.name ${GIT_USER}
[ ! -z ${GIT_EMAIL} ] && git config --global user.email ${GIT_EMAIL}

#设置用户 - 支持USE_ROOT直接以root运行
if [ ! -z ${USE_ROOT} ]; then
    echo "Running as root (USE_ROOT is enabled)"
    USERNAME=root
    # 确保目录权限正确
    chown -R 0:0 $SB_FOLDER 2>/dev/null
    chown -R 0:0 $HOME 2>/dev/null
elif [ ! -z $PUID ] && [ ! -z $PGID ]; then
    # 跳过 PUID=0 PGID=0 的情况，因为已经是root
    if [ "$PUID" = "0" ] && [ "$PGID" = "0" ]; then
        echo "Running as root (PUID=0 PGID=0)"
        USERNAME=root
        chown -R 0:0 $SB_FOLDER
    else
        groupadd -g $PGID vsh 2>/dev/null || true
        useradd -u $PUID -g $PGID vsh 2>/dev/null || true
        chown -R $PUID:$PGID $SB_FOLDER
        args="$@"
        USERNAME=vsh
        chsh -s /bin/bash $USERNAME
        [ -f $HOME/.gitconfig ] && mkdir -p /home/$USERNAME && cp $HOME/.gitconfig /home/$USERNAME/
        mkdir -p /home/$USERNAME && chown -R $PUID:$PGID /home/$USERNAME
        echo "Running  as $USERNAME (configured as PUID $PUID and PGID $PGID)"
    fi
else
    echo "Running as root (no PUID/PGID specified)"
    USERNAME=root
fi


#克隆博客源码
[ ! "$(ls -A ${SOURCE_ROOT})" ] && [ ! -z ${GIT_SOURCE} ] && [ ! -z ${GIT_DEPLOY} ] && git clone ${GIT_SOURCE} ${SOURCE_ROOT} && git clone ${GIT_DEPLOY} ${SOURCE_ROOT}/.deploy_git && chown -R $PUID:$PGID $SOURCE_ROOT

#设置目录权限（根据运行用户）
if [ "$USERNAME" = "root" ]; then
    chown -R 0:0 $HOME $DEFAULT_WORKSPACE 2>/dev/null
else
    chown -R $PUID:$PGID $HOME $DEFAULT_WORKSPACE
fi

#启动markdown网页编辑器
if [ -z "$DISABLE_SILVERBULLET" ]; then
  if [ "$USERNAME" = "root" ]; then
    deno run -A --unstable-kv --unstable-worker-options /silverbullet.js $args &
  else
    gosu $USERNAME deno run -A --unstable-kv --unstable-worker-options /silverbullet.js $args &
  fi
fi

#启动vscode server
if [ -n "${PASSWORD}" ] || [ -n "${HASHED_PASSWORD}" ]; then
    AUTH="password"
else
    AUTH="none"
    echo "starting with no password"
fi

if [ -z ${PROXY_DOMAIN+x} ]; then
    PROXY_DOMAIN_ARG=""
else
    PROXY_DOMAIN_ARG="--proxy-domain=${PROXY_DOMAIN}"
fi


if [ -z ${ENABLE_WORKSPACE_TRUST+x} ]; then
    DISABLE_WORKSPACE_TRUST_ARG=""
else
    DISABLE_WORKSPACE_TRUST_ARG="--disable-workspace-trust"
fi

chown -R $PUID:$PGID $HOME $DEFAULT_WORKSPACE

if [ "$USERNAME" = "root" ]; then
  env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-ceintl.vscode-language-pack-zh-hans &
else
  gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-ceintl.vscode-language-pack-zh-hans &
fi

if [ ! -z ${CODE_PLUGIN} ] ; then
  if [ "$USERNAME" = "root" ]; then
    env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ${CODE_PLUGIN} &
  else
    gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ${CODE_PLUGIN} &
  fi
fi

if [ "$USERNAME" = "root" ]; then
  exec env HOME=$HOME /app/code-server/bin/code-server \
                --bind-addr 0.0.0.0:${VS_PORT:-9000} \
                --user-data-dir ${HOME:-/config}/data \
                --extensions-dir ${HOME:-/config}/extensions \
                --disable-telemetry \
                --auth ${AUTH} \
                ${PROXY_DOMAIN_ARG} \
                ${DISABLE_WORKSPACE_TRUST_ARG} \
                ${DEFAULT_WORKSPACE:-/config/}
else
  exec gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server \
                --bind-addr 0.0.0.0:${VS_PORT:-9000} \
                --user-data-dir ${HOME:-/config}/data \
                --extensions-dir ${HOME:-/config}/extensions \
                --disable-telemetry \
                --auth ${AUTH} \
                ${PROXY_DOMAIN_ARG} \
                ${DISABLE_WORKSPACE_TRUST_ARG} \
                ${DEFAULT_WORKSPACE:-/config/}
fi

exec "$@"
