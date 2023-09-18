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

./config.sh \
    --url "$REPO_URL" \
    --token "$GITHUB_TOKEN" \
    --name "koyeb-runner-$(hostname)" \
    --runnergroup default \
    --no-default-labels \
    --labels "$RUNNER_LABELS" \
    --work workspace \
    --replace

exec ./run.sh
