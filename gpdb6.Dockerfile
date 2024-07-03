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
    curl https://repos.baslab.org/rhel/7/bpftools/bpftools.repo --output /etc/yum.repos.d/bpftools.repo; \
    yum install -y https://packages.endpointdev.com/rhel/7/main/x86_64/endpoint-repo.x86_64.rpm; \
    yum install -y \
        centos-release-openstack-train \
    ; \
    yum install -y --enablerepo=base-debuginfo,epel-debuginfo \
        atop \
        audit-debuginfo \
        bcc-tools \
        bpftrace \
        bzip2-debuginfo \
        ccache \
        cracklib-debuginfo \
        curl-debuginfo \
        cyrus-sasl-debuginfo \
        cyrus-sasl-gssapi \
        dwarves \
        e2fsprogs-debuginfo \
        elfutils-libelf-devel \
        gcc-debuginfo \
        gdb \
        git \
        glibc-debuginfo \
        gmp-devel \
        golang \
        graphviz \
        htop \
        keyutils-debuginfo \
        krb5-debuginfo \
        libcap-ng-debuginfo \
        libcsv-devel \
        libdb-debuginfo \
        libidn-debuginfo \
#        librdkafka-devel \
        libselinux-debuginfo \
        libsepol-debuginfo \
        libssh2-debuginfo \
        libuv-debuginfo \
        libverto-debuginfo \
        libxml2-debuginfo \
        llvm-toolset-11.0 \
        llvm-toolset-11.0-clang \
        llvm-toolset-11.0-clang-tools-extra \
        mc \
        ninja-build \
        nspr-debuginfo \
        nss-debuginfo \
        nss-softokn-debuginfo \
        nss-util-debuginfo \
        openldap-debuginfo \
        openssl-debuginfo \
        pam-debuginfo \
        parallel \
        pcre-debuginfo \
        protobuf-compiler \
        psmisc \
        python-protobuf \
        python-yaml \
        xerces-c-debuginfo \
        xz-debuginfo \
        yum-plugin-auto-update-debug-info \
        zlib-debuginfo \
    ; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    yum clean all; \
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
    wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.sh; \
    sh cmake-*-linux-x86_64.sh --skip-license --prefix=/usr/local; \
    rm cmake-*-linux-x86_64.sh; \
    wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz; \
#    rm -rf /usr/local/go; \
    tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz; \
    rm go1.21.3.linux-amd64.tar.gz; \
    mv /usr/local /usr/local.parent; \
    echo done

USER "$USER"
