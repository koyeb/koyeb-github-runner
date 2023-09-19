FROM ubuntu

ARG RUNNER_VERSION
RUN test -n "$RUNNER_VERSION"

# Install various dependencies that might be useful in a runner
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
    git

RUN pip install poetry

RUN groupadd -r runner && useradd -r -g runner runner
RUN mkdir -p /home/runner

WORKDIR /home/runner
RUN chown -R runner:runner /home/runner

ADD https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz /home/runner/
RUN tar xzf /home/runner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN rm -f /home/runner/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

USER runner

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
