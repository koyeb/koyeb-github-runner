# This Dockerfile is used to run a self-hosted GitHub runner on Koyeb.

# Unfortunately, docker:dind only exists for alpine, so we can't use it as a
# base image. As a workaround, we first install system dependencies and copy the
# binaries from docker:dind.
FROM ubuntu

RUN apt-get update

RUN apt-get install -y \
    btrfs-progs \
    e2fsprogs \
    iptables \
    openssl \
    xfsprogs \
    xz-utils \
    pigz \
    fuse-overlayfs \
    kmod

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy
RUN update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

COPY --from=docker:dind /etc/subuid /etc/subuid
COPY --from=docker:dind /etc/subgid /etc/subgid

COPY --from=docker:dind /usr/local/bin/ /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/cli-plugins/ /usr/local/libexec/docker/cli-plugins/

# Then, we install various dependencies that might be useful in a runner.
# This list is inspired by the official GitHub runners, see
# https://github.com/actions/runner-images/tree/main
RUN apt-get install -y acl \
    aria2 \
    autoconf \
    automake \
    binutils \
    bison \
    brotli \
    bzip2 \
    coreutils \
    curl \
    dbus \
    dnsutils \
    dpkg \
    dpkg-dev \
    fakeroot \
    file \
    flex \
    fonts-noto-color-emoji \
    ftp \
    g++ \
    gcc \
    gnupg2 \
    haveged \
    imagemagick \
    iproute2 \
    iputils-ping \
    jq

RUN apt-get install -y \
    lib32z1 \
    libc++-dev \
    libc++abi-dev \
    libc6-dev \
    libcurl4 \
    libgbm-dev \
    libgconf-2-4 \
    libgsl-dev \
    libgtk-3-0 \
    libmagic-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libsecret-1-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libunwind8 \
    libxkbfile-dev \
    libxss1 \
    libyaml-dev \
    locales \
    lz4

RUN apt-get install -y \
    m4 \
    make \
    mediainfo \
    mercurial \
    net-tools \
    netcat \
    openssh-client \
    p7zip-full \
    p7zip-rar \
    parallel \
    pass \
    patchelf \
    pigz \
    pkg-config \
    pollinate \
    python-is-python3 \
    rpm \
    rsync \
    shellcheck \
    sphinxsearch \
    sqlite3

RUN apt-get install -y \
    ssh \
    sshpass \
    subversion \
    sudo \
    swig \
    tar \
    telnet \
    texinfo \
    time \
    tk \
    tzdata \
    unzip \
    upx \
    wget \
    xorriso \
    xvfb \
    xz-utils \
    zip \
    zsync

# Other packages that are not in the official GitHub runners but that might be interesting.
RUN apt-get update && apt-get install -y \
    libicu70 \
    ca-certificates \
    sysbench \
    python3-pip \
    libpq-dev \
    golang \
    git \
    docker.io


# Finally, let's install the runner.
RUN groupadd -r runner && useradd -r -g runner runner
RUN mkdir -p /home/runner

WORKDIR /home/runner
RUN chown -R runner:runner /home/runner

# In Oct. 2023, the last RUNNER_VERSION was 2.310.0.
ARG RUNNER_VERSION
RUN test -n "$RUNNER_VERSION"

ADD https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz /home/runner/
RUN tar xzf /home/runner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN rm -f /home/runner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
