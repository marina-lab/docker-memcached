FROM centos:7.0.1406
MAINTAINER sprin
# Inspired by docker-library/memcached

RUN groupadd -r memcache && useradd -r -g memcache memcache

# Disable fastermirror plugin - not using it is actually faster.
RUN sed -ri 's/^enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

ENV MEMCACHED_VERSION 1.4.22
ENV MEMCACHED_SHA1 5968d357d504a1f52622f9f8a3e85c29558acaa5

# Install Python deps
RUN yum install -y \
    tar \
    gcc \
    make \
    libevent-devel \
    perl \
    && yum clean all

# You may want to verify the download with gpg: https://www.python.org/download
RUN set -x \
    && mkdir -p /usr/src/memcached \
    && curl -Sl "http://memcached.org/files/memcached-$MEMCACHED_VERSION.tar.gz" \
        | tar -xzC /usr/src/memcached --strip-components=1 \
    && cd /usr/src/memcached \
    && ./configure \
    && make  -j$(nproc) \
    && make install \
    && rm -rf /usr/src/memcached

EXPOSE 11211

USER memcache
CMD ["memcached"]
