#!/bin/sh
# To run local to test configuration
# podman run --name local_github_runner -it -e REPOSITORY=<MY REPOSITORY> -e RUNNER_NAME=<MY POD NAME> -e PAT_GITHUB=<MY GITHUB TOKEN> localhost/github_runner:local

registration_url="https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token"
echo "Requesting registration URL at '${registration_url}'"

payload=$(curl -sX POST -H "Authorization: token ${PAT_GITHUB}" ${registration_url})
export RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)

# Ensure that the runner runs a single job "--once"
./config.sh \
    --name ${RUNNER_NAME} \
    --token ${RUNNER_TOKEN} \
    --url https://github.com/${REPOSITORY} \
    --work ${RUNNER_WORKDIR} \
    --unattended \
    --replace \
    --ephemeral


remove() {
./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!