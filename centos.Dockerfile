FROM centos:7
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV GROUP=gpdb \
    HOME=/home \
    USER=gpdb
MAINTAINER RekGRpth
WORKDIR "$HOME"
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /usr/local/bin/*.sh; \
    groupadd --system --gid 1000 "$GROUP"; \
    useradd --system --uid 1000 --home "$HOME" --shell /bin/bash --gid "$GROUP" "$USER"; \
    yum makecache; \
    yum install -y \
        centos-release-scl \
        epel-release \
    ; \
    yum install -y \
        ant-junit \
        apache-ivy \
        apr-devel \
        apr-util-devel \
        autoconf \
        bison \
        bzip2-debuginfo \
        bzip2-devel \
        ccache \
        cmake3 \
        CUnit \
        CUnit-devel \
        curl-debuginfo \
        cyrus-sasl-debuginfo \
        devtoolset-7-toolchain \
        e2fsprogs-debuginfo \
        expat \
        expat-devel \
        flex \
        gcc \
        gcc-c++ \
        gcc-debuginfo \
        gdal-devel \
        gdb \
        geos-devel \
        git \
        glibc-debuginfo \
        golang \
        gperf \
        htop \
        indent \
        iproute \
        java-1.8.0-openjdk-devel \
        jq \
        json-c-devel \
        keyutils-debuginfo \
#        krb5-debuginfo \
#        krb5-devel \
#        krb5-server \
#        krb5-workstation \
        libcurl-devel \
        libdb-debuginfo \
        libevent-devel \
        libicu \
        libidn-debuginfo \
        libkadm5 \
        libselinux-debuginfo \
        libsepol-debuginfo \
        libssh2-debuginfo \
        libtool \
        libuuid-devel \
        libuv-devel \
        libverto-debuginfo \
        libxml2-debuginfo \
        libxml2-devel \
        libxslt-devel \
        libyaml-devel \
        libzstd-devel \
        make \
        net-tools \
        nspr-debuginfo \
        nss-debuginfo \
        nss-softokn-debuginfo \
        nss-util-debuginfo \
        openldap-debuginfo \
        openssh-server \
        openssl-debuginfo \
        openssl-devel \
        pam-devel \
        pcre-debuginfo \
        perl-Env \
        perl-ExtUtils-Embed \
        perl-IPC-Run \
        perl-JSON \
        perl-Test-Base \
        proj-devel \
        python2-pip \
        python3-pip \
        python-devel \
        python-pip \
        python-psutil \
        python-setuptools \
        readline-devel \
        rsync \
        snappy-devel \
        sudo \
        time \
        unzip \
        wget \
        which \
        xz-debuginfo \
#        yum-plugin-auto-update-debug-info \
        zlib-debuginfo \
        zlib-devel \
        zstd-debuginfo \
    ; \
    ln -s cmake3 /usr/bin/cmake; \
    ln -s ctest3 /usr/bin/ctest; \
    yum clean all; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo '"\e[A": history-search-backward' >>/etc/inputrc; \
    echo '"\e[B": history-search-forward' >>/etc/inputrc; \
    ssh-keygen -f /etc/ssh/ssh_host_key -N '' -t rsa1; \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa; \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa; \
    sed -i "/^AcceptEnv/cAcceptEnv LANG LC_* GP* PG* PXF*" /etc/ssh/sshd_config; \
    sed -ie "s|Defaults    requiretty|#Defaults    requiretty|" /etc/sudoers; \
    sed -i "/^#PermitUserEnvironment/cPermitUserEnvironment yes" /etc/ssh/sshd_config; \
    sed -ir "s@^HostKey /etc/ssh/ssh_host_ecdsa_key\$@#&@;s@^HostKey /etc/ssh/ssh_host_ed25519_key\$@#&@" /etc/ssh/sshd_config; \
    echo done
