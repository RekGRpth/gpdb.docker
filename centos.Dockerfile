FROM centos:7
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV GROUP=postgres \
    HOME=/home \
    USER=postgres
MAINTAINER RekGRpth
WORKDIR "$HOME"
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    chmod +x /usr/local/bin/*.sh; \
    groupadd --system --gid 1000 "$GROUP"; \
    useradd --system --uid 1000 --home "$HOME" --shell /bin/bash --gid "$GROUP" "$USER"; \
    yum makecache; \
    yum install -y \
        centos-release-openstack-train \
        centos-release-scl \
        centos-release-scl-rh \
        epel-release \
    ; \
    echo -e "\
[llvmtoolset-build] \n\
name            = LLVM Toolset 11.0 - Build \n\
baseurl         = https://buildlogs.centos.org/c7-llvm-toolset-11.0.x86_64/ \n\
enabled         = 1 \n\
gpgcheck        = 0\
" > /etc/yum.repos.d/llvmtoolset-build.repo; \
    rpm -Uvh http://repo.openfusion.net/centos7-x86_64/openfusion-release-0.7-1.of.el7.noarch.rpm; \
    yum install -y --skip-broken \
        ant-junit \
        apache-ivy \
        apr-devel \
        apr-util-devel \
        autoconf \
        bison \
#        bzip2-debuginfo \
        bzip2-devel \
        ccache \
        cmake3 \
        cpan \
#        CUnit \
#        CUnit-devel \
#        curl-debuginfo \
#        cyrus-sasl-debuginfo \
        devtoolset-11-toolchain \
#        e2fsprogs-debuginfo \
        expat \
        expat-devel \
        flex \
#        gcc \
        gcc-c++ \
#        gcc-debuginfo \
        gdal-devel \
#        gdb \
        geos-devel \
        git \
#        glibc-debuginfo \
        golang \
        gperf \
        htop \
        indent \
        iproute \
        java-1.8.0-openjdk-devel \
        jq \
        json-c-devel \
#        keyutils-debuginfo \
#        krb5-debuginfo \
#        krb5-devel \
#        krb5-server \
#        krb5-workstation \
        libcgroup-tools \
        libcurl-devel \
        libdb-debuginfo \
        libevent-devel \
#        libevent-devel \
        libicu \
#        libidn-debuginfo \
        libkadm5 \
#        libselinux-debuginfo \
#        libsepol-debuginfo \
#        libssh2-debuginfo \
        libtool \
        libuuid-devel \
        libuv-devel \
#        libverto-debuginfo \
#        libxml2-debuginfo \
        libxml2-devel \
        libxslt-devel \
        libyaml-devel \
        libzstd-devel \
        libzstd-static \
        lldb \
        llvm-toolset-11.0-clang \
        llvm-toolset-11.0-clang-tools-extra \
#        make \
        netcat \
        net-tools \
        ninja-build \
#        nspr-debuginfo \
#        nss-debuginfo \
#        nss-softokn-debuginfo \
#        nss-util-debuginfo \
#        openldap-debuginfo \
        openssh-server \
#        openssl-debuginfo \
        openssl-devel \
        pam-devel \
        parallel \
#        pcre-debuginfo \
        perl-Env \
        perl-ExtUtils-Embed \
        perl-IPC-Run \
        perl-JSON \
        perl-Test-Base \
        proj-devel \
        protobuf-compiler \
        PyGreSQL \
#        python2-behave \
        python2-devel \
        python2-pip \
        python2-psutil \
#        python2-setuptools \
        python3-devel \
        python3-pip \
        python3-psutil \
        python3-psycopg2 \
#        python3-setuptools \
        python-lockfile \
        python-paramiko \
#        python-pip \
        python-protobuf \
#        python-psycopg2 \
        python-yaml \
        readline-devel \
        rh-git227-git \
        rsync \
#        snappy-devel \
        sudo \
        time \
        ucspi-tcp \
        unzip \
        wget \
        which \
        xerces-c-devel \
#        xz-debuginfo \
#        yum-plugin-auto-update-debug-info \
#        zlib-debuginfo \
        zlib-devel \
#        zstd-debuginfo \
    ; \
    pip install --no-cache-dir --ignore-installed \
        "pip<21.0" \
    ; \
    pip install --no-cache-dir \
        allure-behave==2.4.0 \
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
    echo /usr/local/lib >> /etc/ld.so.conf; \
    echo /usr/local/lib64 >> /etc/ld.so.conf; \
#    echo "$HOME/.local5/lib" >>/etc/ld.so.conf; \
#    echo "$HOME/.local6/lib" >>/etc/ld.so.conf; \
#    echo "$HOME/.local7/lib" >>/etc/ld.so.conf; \
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers; \
    ldconfig; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    echo done
USER "$USER"
