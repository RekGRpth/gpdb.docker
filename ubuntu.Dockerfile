FROM ubuntu
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
    addgroup --system --gid 1000 "$GROUP"; \
    adduser --system --uid 1000 --home "$HOME" --shell /bin/bash --ingroup "$GROUP" "$USER"; \
    apt-get update; \
    apt-get install -y --no-install-recommends apt-utils software-properties-common; \
    add-apt-repository -y universe; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        python2 \
    ; \
    curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o get-pip.py; \
    python2 get-pip.py --no-python-version-warning --no-cache-dir --ignore-installed --prefix /usr/local; \
    update-alternatives --install /usr/bin/python python /usr/bin/python2 2; \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1; \
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
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo done
