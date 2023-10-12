#!/bin/bash

set -e

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

if [[ -z ${DISABLE_DOCKER_DAEMON+x} ]]; then
    # Run docker daemon
    /usr/local/bin/dockerd-entrypoint.sh --tls=false > /tmp/docker.log 2>&1 &

    echo "Waiting for docker daemon to start..." >&2
    i=0
    while true;
    do
        test -S /var/run/docker.sock && echo "ok!" >&2 && break
        echo ... >&2
        sleep .5
        i=$((i+1))

        if [ $i -gt 60 ];
        then
        echo === Unable to start docker daemon === >&2
        cat /tmp/docker.log >&2
        echo "====================================" >&2
        echo "Unable to start docker daemon. Make sure your service has the privileged flag set." >&2
        exit 1
        fi
    done

    # Allow runner to start Docker containers
    chown runner:runner /var/run/docker.sock
else
    echo "DISABLE_DOCKER_DAEMON is set, skip docker daemon start" >&2
fi


ORG_REPO=$(echo "$REPO_URL" | sed -n -E "s#(https://)?(www\.)?(github\.com/)?([^/]+)/?([^/#?]+)?.*#\4/\5#p")
ORGANIZATION=$(echo "$ORG_REPO" | awk -F/ '{print $1}')
REPO=$(echo "$ORG_REPO" | awk -F/ '{print $2}')

if [ -z "$ORGANIZATION" ];
then
    echo "Unable to parse REPO_URL, should be like <org>/<repo> or <org>, exit" >&2
    exit 1
fi

if [ -z "$REPO" ];
then
    echo ">> Get registration token for organization $ORGANIZATION"
    # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization
    resp=$(curl -s -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/$ORGANIZATION/actions/runners/registration-token")
else
    echo ">> Get registration token for repository $ORGANIZATION/$REPO"
    # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository
    resp=$(curl -s -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$ORGANIZATION/$REPO/actions/runners/registration-token")
fi

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
