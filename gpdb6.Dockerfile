ARG GP_MAJOR=6
FROM "hub.adsw.io/library/gpdb${GP_MAJOR}_regress:latest"

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    echo -e "\
[llvmtoolset-build] \n\
name            = LLVM Toolset 11.0 - Build \n\
baseurl         = https://buildlogs.centos.org/c7-llvm-toolset-11.0.x86_64/ \n\
enabled         = 1 \n\
gpgcheck        = 0\
" > /etc/yum.repos.d/llvmtoolset-build.repo; \
    yum install -y https://packages.endpointdev.com/rhel/7/main/x86_64/endpoint-repo.x86_64.rpm; \
    yum install -y \
        ccache \
        gdb \
        git \
        golang \
        htop \
        llvm-toolset-11.0-clang \
        llvm-toolset-11.0-clang-tools-extra \
        mc \
        parallel \
        psmisc \
    ; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    yum clean all; \
    echo done

ENTRYPOINT [ "docker_entrypoint.sh" ]

ADD bin /usr/local/bin

ENV PREFIX=/usr/local

ENV BINDIR="$PREFIX/bin"
ENV GPHOME="$PREFIX/greenplum-db-devel"
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
    echo done

USER "$USER"
