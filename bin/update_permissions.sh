#!/bin/sh

exec 2>&1
set -ex
if [ -n "$GROUP" ] && [ -n "$GROUP_ID" ]; then
    find "$HOME" ! -group "$GROUP" -exec sudo chgrp "$GROUP_ID" {} \;
fi
if [ -n "$USER" ] && [ -n "$USER_ID" ]; then
    find "$HOME" ! -user "$USER" -exec sudo chown "$USER_ID" {} \;
fi
