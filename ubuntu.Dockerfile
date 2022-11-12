FROM ubuntu
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
    addgroup --system --gid 1000 "$GROUP"; \
    adduser --system --uid 1000 --home "$HOME" --shell /bin/bash --ingroup "$GROUP" "$USER"; \
    apt-get update; \
    apt-get install -y --no-install-recommends apt-utils software-properties-common; \
    add-apt-repository -y universe; \
    echo "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -cs)-proposed restricted main multiverse universe" >>/etc/apt/sources.list.d/proposed-repositories.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bison \
        bpfcc-tools \
        build-essential \
        ccache \
        cmake \
        curl \
        default-jdk \
        flex \
        g++ \
        gcc \
        gcc-bpf \
        gdb \
        gdb-bpf \
        git-core \
        golang \
        htop \
        inetutils-ping \
        iproute2 \
        krb5-admin-server \
        krb5-kdc \
        less \
        libapr1-dev \
        libbz2-dev \
        libcurl4-gnutls-dev \
        libevent-dev \
        libkrb5-dev \
        libpam-dev \
        libperl-dev \
        libreadline-dev \
        libssl-dev \
        libxml2-dev \
        libyaml-dev \
        libzstd-dev \
        linux-generic \
        linux-headers-generic \
        locales \
        make \
        net-tools \
        ninja-build \
        openssh-client \
        openssh-server \
        openssl \
        pkg-config \
        python2 \
        python2-dev \
        python3 \
        python3-dev \
        python3-pip \
        python3-psutil \
        python3-pygresql \
        python3-yaml \
        systemtap-sdt-dev \
        zlib1g-dev \
    ; \
    curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o get-pip.py; \
    python2 get-pip.py --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local; \
    pip2 install --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local \
        psutil \
    ; \
    export savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get full-upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    cd /; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | grep -v -e gdal -e geos -e perl -e python -e tcl | sort -u | xargs -r apt-mark manual; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | grep -v -e gdal -e geos -e perl -e python -e tcl | sort -u | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gosu \
        locales \
        ssh \
        tzdata \
    ; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8; \
    localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8; \
    locale-gen --lang en_US.UTF-8; \
    locale-gen --lang ru_RU.UTF-8; \
    dpkg-reconfigure locales; \
    rm -rf /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo '"\e[A": history-search-backward' >>/etc/inputrc; \
    echo '"\e[B": history-search-forward' >>/etc/inputrc; \
    sed -i "/^#PermitUserEnvironment/cPermitUserEnvironment yes" "/etc/ssh/sshd_config"; \
    sed -i "/^AcceptEnv/cAcceptEnv LANG LC_* GP* PG* PXF*" "/etc/ssh/sshd_config"; \
    echo done
