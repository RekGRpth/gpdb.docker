FROM hub.adsw.io/library/gpdb7_u22:latest

SHELL [ "/bin/bash", "-c" ]

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt update; \
    apt install -y \
        autoconf \
        ccache \
        clang-format-11 \
        clang-format-13 \
        elfutils \
        gdb \
        golang-1.21 \
        htop \
        lcov \
        liblz4-dev \
        libssh2-1-dev \
        libtool \
        libxml2-utils \
        libxslt-dev \
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
    which pip3 || curl https://bootstrap.pypa.io/pip/get-pip.py | python3; \
    echo done

ENTRYPOINT [ "docker_entrypoint.sh" ]

ADD bin /usr/local/bin

ENV PREFIX=/usr/local

ENV BINDIR="$PREFIX/bin"
ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV CONFIGURE_FLAGS=
ENV GOPATH="$PREFIX/go"
ENV GPHOME="$PREFIX/greenplum-db-devel"
ENV GROUP=gpadmin
ENV HOME=/home/gpadmin
ENV PATH="/usr/lib/ccache:$PATH:$GOPATH/bin:/usr/lib/go-1.21/bin:$PREFIX/madlib/bin"
ENV USER=gpadmin

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    source gpdb_src/concourse/scripts/common.bash; \
    install_gpdb; \
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
    chown -R "$USER":"$GROUP" /usr/local; \
    echo done

USER "$USER"
