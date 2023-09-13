# koyeb-github-runner

The **koyeb-github-runner** repository contains the source code for the Docker image [koyeb/github-runner](https://hub.docker.com/r/koyeb/github-runner/), which allows you to set up a GitHub runner on the Koyeb platform.

## Usage

To manually start a GitHub runner on Koyeb, follow these steps:

### Using the [control panel](https://app.koyeb.com/)

1. Create a new Docker project.
2. Use the image `koyeb/github-runner`
3. Select the "Worker" service type
4. Set the following environment variables:
   - **REPO_URL:** The URL of your GitHub repository.
   - **GITHUB_TOKEN:** Your GitHub token, which can be found in your project's Settings > Actions > Runners > New self-hosted runner section. Prefer using a secret over a plain text environment variable.
   - **RUNNER_LABELS:** A comma-separated list of labels that trigger the runner. Be sure to set the same label in the `runs-on` setting of your job file.

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
   --instance-type nano \
   --app github-runner \
   runner
```

## 🎉 That's all! 🎉

Once you've configured the environment variables and set up the runner, it will be ready to process jobs in your GitHub project.

For more information on how to use GitHub runners, refer to the [GitHub Actions documentation](https://docs.github.com/en/actions).

## Advanced usage

To start GitHub runners on-demand, consider using [koyeb-github-runner-executor](https://github.com/koyeb/koyeb-github-runner-executor).
