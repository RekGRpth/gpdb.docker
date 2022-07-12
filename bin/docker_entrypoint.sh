#!/bin/sh -ex

service ssh start
if [ "$(id -u)" = '0' ]; then
    if [ -n "$GROUP" ] && [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
        test -n "$USER" && usermod --home /tmp "$USER"
        groupmod --gid "$GROUP_ID" "$GROUP"
        chgrp "$GROUP_ID" "$HOME"
        test -n "$USER" && usermod --home "$HOME" "$USER"
    fi
    if [ -n "$USER" ] && [ -n "$USER_ID" ] && [ "$USER_ID" != "$(id -u "$USER")" ]; then
        usermod --home /tmp "$USER"
        usermod --uid "$USER_ID" "$USER"
        chown "$USER_ID" "$HOME"
        usermod --home "$HOME" "$USER"
    fi
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        install -d -m 0700 -o "$USER" -g "$GROUP" "$HOME/.ssh"
        gosu "$USER" ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"; \
        cat "$HOME/.ssh/id_rsa.pub" > "$HOME/.ssh/authorized_keys"; \
        chmod 0600 "$HOME/.ssh/authorized_keys"; \
    fi
    { gosu "$USER" ssh-keyscan localhost; gosu "$USER" ssh-keyscan "$(hostname)"; gosu "$USER" ssh-keyscan 0.0.0.0; } > "$HOME/.ssh/known_hosts"; \
    chown -R "$USER":"$GROUP" "$HOME/.ssh"; \
fi
service ssh stop
exec "$@"
