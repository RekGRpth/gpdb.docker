FROM hub.adsw.io/library/gpdb6_u22:latest

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt update; \
    apt install -y \
        ccache \
        clang-format-11 \
        clang-format-13 \
        elfutils \
        gdb \
        htop \
        lcov \
        liblz4-dev \
        libssh2-1-dev \
        libxml2-utils \
        libyaml-perl \
        mc \
        meson \
        ninja-build \
        parallel \
        pcregrep \
        psmisc \
        sudo \
    ; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    echo done

ENTRYPOINT [ "docker_entrypoint.sh" ]

ADD bin /usr/local/bin

ENV PREFIX=/usr/local

ENV BINDIR="$PREFIX/bin"
ENV GPHOME="$PREFIX"
ENV GROUP=gpadmin
ENV HOME=/home/gpadmin
ENV USER=gpadmin

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    groupadd --system --gid 1000 "$GROUP"; \
    useradd --system --uid 1000 --home "$HOME" --shell /bin/bash --gid "$GROUP" "$USER"; \
    usermod -p '*' "$USER"; \
    chmod +x /usr/local/bin/*.sh; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers; \
    echo '"\e[A": history-search-backward' >>/etc/inputrc; \
    echo '"\e[B": history-search-forward' >>/etc/inputrc; \
    sed -i "/^AcceptEnv/cAcceptEnv LANG LC_* GP* PG* PXF*" /etc/ssh/sshd_config; \
    sed -i "/^#MaxStartups/cMaxStartups 20:30:100" /etc/ssh/sshd_config; \
    wget -q https://go.dev/dl/go1.21.3.linux-amd64.tar.gz; \
    tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz; \
    rm go1.21.3.linux-amd64.tar.gz; \
    mv /usr/local /usr/local.parent; \
    echo done

USER "$USER"
