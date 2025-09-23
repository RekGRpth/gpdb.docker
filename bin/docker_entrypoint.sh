#!/bin/sh -ex

if [ -n "$GROUP" ] && [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
    test -n "$USER" && sudo usermod --home /tmp "$USER"
    sudo groupmod --gid "$GROUP_ID" "$GROUP"
    sudo chgrp "$GROUP_ID" "$HOME"
    test -n "$USER" && sudo usermod --home "$HOME" "$USER"
fi
if [ -n "$USER" ] && [ -n "$USER_ID" ] && [ "$USER_ID" != "$(id -u "$USER")" ]; then
    sudo usermod --home /tmp "$USER"
    sudo usermod --uid "$USER_ID" "$USER"
    sudo chown "$USER_ID" "$HOME"
    sudo usermod --home "$HOME" "$USER"
fi
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    install -d -m 0700 -o "$USER" -g "$GROUP" "$HOME/.ssh"
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
    cat "$HOME/.ssh/id_rsa.pub" > "$HOME/.ssh/authorized_keys"
    chmod 0600 "$HOME/.ssh/authorized_keys"
    echo "SendEnv GP* PG* PXF*" > "$HOME/.ssh/config"
    echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config"
    echo "Host *" >> "$HOME/.ssh/config"
    echo "  UseRoaming no" >> "$HOME/.ssh/config"
fi
if [ -d /opt/adb6-python3.9 ]; then
    sudo chown -R "$USER":"$GROUP" /opt/adb6-python3.9
fi
sudo cp -r /usr/local.parent/* /usr/local/
sudo chown -R "$USER":"$GROUP" /usr/local
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
exec "$@"
