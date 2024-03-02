ARG GP_MAJOR=5
FROM hub.adsw.io/library/gpdb${GP_MAJOR}_regress:latest

RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    yum makecache; \
    yum install -y --skip-broken \
        gdb \
        golang \
        htop \
        libxslt-devel \
        mc \
        psmisc \
        python-lockfile \
        python-paramiko \
    ; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    yum clean all; \
    echo done

ENTRYPOINT [ "docker_entrypoint.sh" ]

ADD bin /usr/local/bin

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
    rpm -i https://ci.arenadata.io/artifactory/ADB/6.7.1_arenadata4/centos/7/community/x86_64/sigar-1.6.5-163.el7.x86_64.rpm; \
    rpm -i https://ci.arenadata.io/artifactory/ADB/6.7.1_arenadata4/centos/7/community/x86_64/sigar-headers-1.6.5-163.el7.x86_64.rpm; \
    echo done

USER "$USER"
