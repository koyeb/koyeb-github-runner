# koyeb-github-runner

The **koyeb-github-runner** repository contains the source code for the Docker image [koyeb/github-runner](https://hub.docker.com/r/koyeb/github-runner/), which allows you to set up a GitHub runner on the Koyeb platform.

## Usage

To manually start a GitHub runner on Koyeb, follow these steps:

### Using the [control panel](https://app.koyeb.com/)

1. Create a new Docker project.
2. Use the image `koyeb/github-runner`
3. Select the "Worker" service type
4. Set the "privileged" flag
5. Set the following environment variables:

| Variable name | Value |
|---------------|-------|
| **REPO_URL** |  The URL of your GitHub repository (`https://github.com/<org>/<repo>`).
| **GITHUB_TOKEN** | Your GitHub token that will be used to create a registration token for the runner. To generate it, go to [Developer Settings](https://github.com/settings/tokens?type=beta) > [Generate new token](https://github.com/settings/personal-access-tokens/new) and under "Permissions" select "Read & Write" for "Administration". *Prefer using a secret over a plain text value to store your token.*
| **RUNNER_LABELS** | A comma-separated list of labels that trigger the runner. Be sure to set the same label in the `runs-on` setting of your job file.

**Note the default free and nano instances have 256MB of memory, which is not enough to run the runner. We recommend using at least a small instance.**

### Using the [Koyeb CLI](https://github.com/koyeb/koyeb-cli)

```bash
$> koyeb app create github-runner
$> koyeb service create \
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

## 🎉 That's all! 🎉

Once you've configured the environment variables and set up the runner, it will be ready to process jobs in your GitHub project.

For more information on how to use GitHub runners, refer to the [GitHub Actions documentation](https://docs.github.com/en/actions).

## Advanced usage

### Runner for the entire organization

If you want to configure the runner for your entire organization:

* when creating the token, set the permission Organization permissions > Self-hosted runners > Read & Write
* set the `REPO_URL` variable to `https://github.com/<org>`

### Disable docker daemon

By default, the runner starts a docker daemon. If you don't need it, you can disable it by setting the `DISABLE_DOCKER_DAEMON` environment variable to `true`.
If you use small instances, this will save you some memory.

### Start runners on-demand

To start GitHub runners on-demand, consider using [koyeb-github-runner-scheduler](https://github.com/koyeb/koyeb-github-runner-scheduler).
