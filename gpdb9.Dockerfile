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
        golang-1.22 \
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
        openjdk-17-jdk \
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

ADD bin /usr/bin

ENV PREFIX=/usr/local

ENV BINDIR="$PREFIX/bin"
ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV CONFIGURE_FLAGS=
ENV GOPATH="$PREFIX/go"
ENV GPHOME="$PREFIX/greenplum-db-devel"
ENV GP_MAJOR=9
ENV GROUP=gpadmin
ENV HOME=/home/gpadmin
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV LANG=en_US.UTF-8
ENV NUM_PRIMARY_MIRROR_PAIRS=3
ENV PATH="/usr/lib/ccache:$PATH:$GOPATH/bin:/usr/lib/go-1.22/bin:$PREFIX/pxf/bin:$PREFIX/madlib/bin"
ENV PGPORT="${GP_MAJOR}000"
ENV PORT_BASE="$PGPORT"
ENV PXF_BASE="$PREFIX/pxf"
ENV PXF_HOME="$PXF_BASE"
ENV USER=gpadmin
ENV WITH_MIRRORS=true
ENV WITH_STANDBY=true

ENV DATADIRS="$HOME/data/$GP_MAJOR"

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    source gpdb_src/concourse/scripts/common.bash; \
    install_gpdb; \
    groupadd --system --gid 1000 "$GROUP"; \
    useradd --system --uid 1000 --home "$HOME" --shell /bin/bash --gid "$GROUP" "$USER"; \
    usermod -p '*' "$USER"; \
    chmod +x /usr/bin/*.sh; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers; \
    echo '"\e[A": history-search-backward' >>/etc/inputrc; \
    echo '"\e[B": history-search-forward' >>/etc/inputrc; \
    echo 'PS1="\u@gpdb$GP_MAJOR.\h:\w\$ "' >>/etc/bash.bashrc; \
    echo 'test -f "$GPHOME/greengage_path.sh" && source "$GPHOME/greengage_path.sh"' >>/etc/bash.bashrc; \
    echo 'test -f "$GPHOME/greenplum_path.sh" && source "$GPHOME/greenplum_path.sh"' >>/etc/bash.bashrc; \
    echo '* hard nofile 65535' >>/etc/security/limits.conf; \
    echo '* soft nofile 65535' >>/etc/security/limits.conf; \
    sed -i "/^AcceptEnv/cAcceptEnv LANG LC_* GP* PG* PXF* SUSPEND_PG_REWIND" /etc/ssh/sshd_config; \
    sed -i "/^#MaxStartups/cMaxStartups 20:30:100" /etc/ssh/sshd_config; \
    mv /usr/local /usr/local.parent; \
    echo done

USER "$USER"
