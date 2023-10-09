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
    fuse-overlayfs

COPY --from=docker:dind /etc/subuid /etc/subuid
COPY --from=docker:dind /etc/subgid /etc/subgid

COPY --from=docker:dind /usr/local/bin/ /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/cli-plugins/ /usr/local/libexec/docker/cli-plugins/

# Then, we install various dependencies that might be useful in a runner.
# This is minimalist and we might want to extend this list. See
# https://github.com/actions/runner-images/tree/main to check what is installed
# on GitHub runners by default.
RUN apt-get update && apt-get install -y \
    libicu70 \
    ca-certificates \
    curl \
    jq \
    sysbench \
    python3 \
    python-is-python3 \
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

#ENV RUNNER_ALLOW_RUNASROOT=1

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
