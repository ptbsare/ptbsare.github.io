#!/bin/sh
#安装版本HEXO
if [ ! $HEXO_VERSION=='latest' ]; then
    npm install hexo-cli@$HEXO_VERSION -g
fi
#设置git用户名邮箱
chsh -s /bin/bash
[ ! -z ${GIT_USER} ] && git config --global user.name ${GIT_USER}
[ ! -z ${GIT_EMAIL} ] && git config --global user.email ${GIT_EMAIL}
#设置用户
if [ ! -z $PUID ] && [ ! -z $PGID ]; then
    groupadd -g $PGID vsh
    useradd -u $PUID -g $PGID vsh
    chown -R $PUID:$PGID $SB_FOLDER
    args="$@"
    USERNAME=vsh
    chsh -s /bin/bash $USERNAME
    [ -f $HOME/.gitconfig ] && mkdir -p /home/$USERNAME && cp $HOME/.gitconfig /home/$USERNAME/
    echo "Running  as $USERNAME (configured as PUID $PUID and PGID $PGID)"
fi


#克隆博客源码
[ ! "$(ls -A ${SOURCE_ROOT})" ] && [ ! -z ${GIT_SOURCE} ] && [ ! -z ${GIT_DEPLOY} ] && git clone ${GIT_SOURCE} ${SOURCE_ROOT} && git clone ${GIT_DEPLOY} ${SOURCE_ROOT}/.deploy_git && chown -R $PUID:$PGID $SOURCE_ROOT


if [ -z "$DISABLE_SILVERBULLET" ]; then
  gosu $USERNAME deno run -A --unstable-kv --unstable-worker-options /silverbullet.js $args &
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


chown -R $PUID:$PGID $HOME $DEFAULT_WORKSPACE

gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension ms-ceintl.vscode-language-pack-zh-hans &

if [ ! -z ${CODE_PLUGIN} ] ; then
gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server --extensions-dir /config/extensions --install-extension  ${CODE_PLUGIN} &
fi

exec gosu $USERNAME env HOME=$HOME /app/code-server/bin/code-server \
                --bind-addr 0.0.0.0:${VS_PORT:-9000} \
                --user-data-dir /config/data \
                --extensions-dir /config/extensions \
                --disable-telemetry \
                --auth ${AUTH} \
                ${PROXY_DOMAIN_ARG} \
                ${DEFAULT_WORKSPACE:-/config/}

exec "$@"
