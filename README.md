# koyeb-github-runner

The **koyeb-github-runner** repository contains the source code for the Docker image [koyeb/github-runner](https://hub.docker.com/r/koyeb/github-runner/), which allows you to set up a GitHub runner on the Koyeb platform.

## Overview

By default, GitHub actions are run by shared runners hosted on GitHub. These runners are free, but due do their shared nature, they can be slower and have limited resources. To overcome these limitations, we've created a GitHub runner that can be deployed on Koyeb.

### Repository or Organization Runner?

GitHub offers two options to register a runner: for a specific repository or for an entire organization. If you want to setup a runner for more than one repository, first [create a new organization](https://github.com/organizations/plan) and move your repositories to it. Then, follow the instructions below to register a runner for your organization.

 *Note it is not possible to register a runner for your personal organization.*

### Runner labels

The directive `runs-on` of your job file allows you to specify the label of the runner that will execute the job. For example in the following workflow file:

```yaml
on:
  push:
    branches:
      - '*'

jobs:
  docker:
    runs-on: koyeb-runner
    container: alpine
    steps:
      - name: Say hello
        run: |
          echo "Hello world!"
```

The action will be executed by a runner with the label `koyeb-runner`. You will have to match your `runs-on` with the `RUNNER_LABELS` environment variable of your runner. See below for more information.

### Requirements

To use the runner, you will need:
- A Koyeb account
- Optionally, use the [Koyeb CLI](https://www.koyeb.com/docs/build-and-deploy/cli/installation). Make sure you have the latest version installed. 

## Usage

### Create a GitHub token

#### For a repository

If you want to register a runner for a specific repository, go to [Developer Settings](https://github.com/settings/tokens?type=beta) > [Generate new token](https://github.com/settings/personal-access-tokens/new) and under "Permissions" select "Read & Write" for "Administration".


<img src="./docs/developer-settings.png" width="300" />
<img src="./docs/fine-grained-tokens.png" width="300" />
<img src="./docs/generate-new-token.png" width="500" />
<img src="./docs/token-create.png" width="500" />
<img src="./docs/token-set-perms-repository.png" width="500" />

#### For an organization

Instead, if you want to register a runner for your organization, go to [Developer Settings](https://github.com/settings/tokens?type=beta) > [Generate new token](https://github.com/settings/personal-access-tokens/new). Select your organization and under "Organization Permissions" select "Read & Write" for "Self-hosted runners".

<img src="./docs/token-create-orga.png" width="500" />
<img src="./docs/token-set-perms-organization.png" width="500" />


### Create the Koyeb application and service

#### With the koyeb CLI

If your favorite way to interact with Koyeb is the CLI, follow these steps.

First, create a new application:

```sh
koyeb app create github-runner
```

Then, create a new service:

```sh
koyeb service create \
   --type worker \
   --docker koyeb/github-runner \
   --env REPO_URL=https://github.com/owner/repo \
   --env GITHUB_TOKEN=xxx \
   --env RUNNER_LABELS=koyeb-runner \
   --region par \
   --instance-type medium \
   --privileged \
   --app github-runner \
   runner
```

Make sure to replace the following values:

| Variable name | Value |
|---------------|-------|
| **REPO_URL** | the URL of your repository (`https://github.com/<org>/<repo>`) or the URL of your organization (`https://github.com/<org>`)
| **GITHUB_TOKEN** | the token you created in the previous step
| **RUNNER_LABELS** | must match the `runs-on` directive of your job file

If you don't need to start a Docker daemon, you can disable it by setting `--env DISABLE_DOCKER_DAEMON=true` and remove the `--privileged` flag.

#### With the control panel

If instead you prefer to use the control panel, follow these steps:

1. Create a new Docker project.
2. Use the image `koyeb/github-runner`
3. Select the "Worker" service type
4. Set the "privileged" flag
5. Set the following environment variables:

| Variable name | Value |
|---------------|-------|
| **REPO_URL** | the URL of your repository (`https://github.com/<org>/<repo>`) or the URL of your organization (`https://github.com/<org>`)
| **GITHUB_TOKEN** | the token you created in the previous step
| **RUNNER_LABELS** | must match the `runs-on` directive of your job file

If you don't need to start a Docker daemon, you can disable it by setting `DISABLE_DOCKER_DAEMON` to `true`. In this case, you can also remove the "privileged" flag.

## Advanced usage

### koyeb-github-runner-scheduler

To start GitHub runners on-demand, consider using [koyeb-github-runner-scheduler](https://github.com/koyeb/koyeb-github-runner-scheduler). This project allows you to start GitHub runners on a schedule, and stop them when they are not needed, saving you money.

## Contributing

The image is inspired by the default GitHub runner images available at [GitHub Actions runner-images](https://github.com/actions/runner-images).

We are actively working on this project so if you have feedback, whether this project is working for you or not, we would **love** to hear from you on our [Slack channel](https://slack.koyeb.com/)