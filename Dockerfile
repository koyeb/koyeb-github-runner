FROM ubuntu

RUN apt-get update && apt-get install -y \
    libicu70 \
    ca-certificates \
    curl \
    jq

# Install various dependencies that might be useful in a runner
RUN apt-get update && apt-get install -y \
    sysbench \
    python3 \
    python3-pip \
    libpq-dev

RUN pip install poetry

RUN groupadd -r runner && useradd -r -g runner runner
RUN mkdir -p /home/runner

WORKDIR /home/runner
RUN chown -R runner:runner /home/runner

ADD https://github.com/actions/runner/releases/download/v2.309.0/actions-runner-linux-x64-2.309.0.tar.gz /home/runner/
RUN tar xzf /home/runner/actions-runner-linux-x64-2.309.0.tar.gz
RUN rm -f /home/runner/actions-runner-linux-x64-2.309.0.tar.gz

USER runner

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]