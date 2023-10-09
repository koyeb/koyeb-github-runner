#!/bin/bash

set -e

# Run docker daemon
/usr/local/bin/dockerd-entrypoint.sh --tls=false >/dev/null 2>&1 &

echo "Waiting for docker daemon to start..."
while true;
do
    test -S /var/run/docker.sock && echo "ok!" && break
    echo -n .
    sleep .5
done

chown runner:runner /var/run/docker.sock

for required_env in \
    REPO_URL \
    GITHUB_TOKEN \
    RUNNER_LABELS \
; do
    if [ -z "${!required_env}" ];
    then
        echo "Variable $required_env is missing, exit" >&2
        exit 1
    fi
done


REPO=$(echo "$REPO_URL" | sed -n -E 's/^(https:\/\/github\.com\/|github\.com\/)?([^/]+)\/([^/]+)$/\2\/\3/p')

if [ -z "$REPO" ];
then
    echo "Unable to parse REPO_URL, should be like https://github.com/<org>/<repo>, exit" >&2
    exit 1
fi

echo ">> Get registration token for $REPO"
# https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28
resp=$(curl -s -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$REPO/actions/runners/registration-token")

RUNNER_TOKEN=$(echo $resp | jq -r .token)

if [ "$RUNNER_TOKEN" = "null" ];
then
    echo "!! Unable to get runner registration token, the GitHub API returned: $resp" >&2
    exit 1
fi

su -c "./config.sh \
    --url '$REPO_URL' \
    --token '$RUNNER_TOKEN' \
    --name 'koyeb-runner-$(hostname)' \
    --runnergroup default \
    --no-default-labels \
    --labels '$RUNNER_LABELS' \
    --work workspace \
    --replace" runner

exec su -c "/usr/local/bin/dockerd-entrypoint.sh ./run.sh" runner
