# CI/CD Pipeline

This document provides a rough explanation of our [CI/CD](https://en.wikipedia.org/wiki/CI/CD) pipeline.  That is, the scripts that Continuously Integrate changes, Continuously Deliver packages for stable repositories, and Continuously Deploy updates for other repositories.  The process is likely to change over time, so this document may be out of date.  After reading this, you should know enough to start exploring how our pipelines work in practice.

# Process

[GitHub Actions](https://github.com/features/actions) runs "workflows" (scripts) on GitHub's own servers when certain events happen - usually when changes are pushed to `main`, but a wide range of events are supported.  For example, this repository's pipeline uses a cron-like [scheduled event](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events) that rebuilds the container once a month so it always has the latest dependencies.

Most workflows pull changes from the `main` branch into the `built` branch, then compile and run the unit tests.  Many repositories also push those changes back to the `built` branch and publish them for people to use.

## Detailed description

All configuration files for a repository's CI/CD pipelines live in the repository's [`.github`](../.github) directory.

Most repositories have a [`dependabot.yml`](../.github/dependabot.yml) file.  [Dependabot](https://dependabot.com/) is a GitHub feature that generates pull requests whenever it sees you using an outdated version of a package.

Most repositories have a [`main.yml`](../.github/workflows/main.yml) file.  This contains the workflow for handling pushes to the `main` branch - usually configuring an appropriate environment and running our container.  [`example-main.yml`](../example-main.yml) shows what this should look like, but make sure to compare it with other examples before use, as it may not be regularly updated.  Some repositories can also have files defining other workflows.  For example, this repository's [`autobuild.yml`](../.github/workflows/autobuild.yml) runs the cron-like pipeline discussed above.

Workflows that run our container call [/entrypoint.sh](../root/entrypoint.sh) as the `Dockerfile`'s [ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint).  That does some sanity checks before passing over to the repo-specific entrypoint script in `"$PWD/bin/entrypoint.sh"`.

In principle, `"$PWD/bin/entrypoint.sh"` could run anything.  In practice, it should define relevant functions before passing control back to [`root/build-sleepdiary.sh`](../root/build-sleepdiary.sh).  That script provides a common interface across all repositories, like responding usefully to `--help` or safely merging changes.

Note that this repository uses a file called [`run.sh`](../run.sh) instead of `bin/entrypoint.sh`.  It serves a similar function, but it's best not to run a script from inside the container it creates.  The name `run.sh` was chosen because it's reasonably obvious, but clearly different to `entrypoint`.

You can see the logs produced by recent workflows in the repository's "Actions" tab.  For example, see [this repository's actions](https://github.com/sleepdiary/builder/actions).

## Why use a container?

In general, we use GitHub Actions to configure an environment, but do most real work in a container.  This is for several reasons:

* containers help support [reproducible builds](https://en.wikipedia.org/wiki/Reproducible_builds) - people can download our container and run the scripts manually to prove that our source code generates the binary we published
* containers can be useful for testing pipelines - running a script in a local container provides a reasonable guarantee of how it will behave in the real world
* containers can be useful during development - building files in a container reduces problems caused by e.g. different software versions or installed packages
* containers reduce vendor lock-in - if we should need to leave GitHub for any reason, anything implemented in a workflow will have to be rewritten

# Release Policies

Workflows that release code are just implementations of a policy.  At present, we have two such policies:

* Continuous repositories publish changes without human intervention.  Workflows for these repositories should build and release everything whenever new changes are pushed
* Stable repositories need human intervention to release new versions.  Workflows for these repositories should build everything the human needs, prompt them to do their bit, then publish the changes

## Continuous repository workflow

In general, the `main.yml` for a continuous repository should run any automated tests and immediately publish the new version.  For repositories published using [GitHub Pages](https://pages.github.com/), that just means merging `main` into `built` and pushing the result.

## Stable repository workflow

Workflows for a stable repository are somewhat complex.

`main.yml` runs some tests (e.g. making sure the unit tests pass), but doesn't commit or push anything.

`release.yml` runs when changes are pushed to the `release` branch.  This re-runs the tests then publishes to a testing location (usually [GitHub Packages](https://github.com/features/packages)).  This can then be used by projects with only moderate stability guarantees - for example, the dashboard uses npm packages from our testing repository.

Finally, `release-tag.yml` runs when a new tag is created that matches the pattern `^v[0-9]+\.[0-9]+\.[0-9]+$` and is reachable from the tip of the `release` branch.  The package is then published with the tag name as a version string and the commit message as a changelog.

# Gotchas

Continuous Integration is great once you've got it working, but developing a workflow is fraught with problems.  This section discusses some common problems and workarounds.

GitHub Pages updates existing files within seconds, but takes about 10 minutes to publish new files.  So when you push out an update that references a new filename, you'll serve a broken link for almost 10 minutes, with no way of confirming you haven't e.g. misnamed the file.  When adding or moving a file, it's best to commit an initial blank file, wait for it to appear, then push the changes that actually use that file.

GitHub Pages can only serve files from a branch's root directory or from `/docs`.  If the program that generates your code can't be configured to output to `/docs`, the easiest solution is just to rename the directory after it finishes.

GitHub Actions sometimes fail in ways that are hard to predict.  For example, an action might reject a configuration file the documentation says should work.  Where possible, you should create a throwaway repository to test changes, push empty commits with `git commit --allow-empty` to trigger commit-based workflows, then paste the working result back into your main repo.  But this can be hard for workflows that rely on secrets (e.g. those that publish changes), and there doesn't seem to be a general way to avoid having to add a messy series of test commits to a public branch.

It's sometimes necessary to permanently manage differences between branches.  For example, the `.gitignore` file in the `main` branch should ignore compiled files, but the whole point of the `built` branch is to commit those changes.  Where possible, use the following procedure:

1. add a comment to the file in one branch, saying to add branch-specific changes below the line in one branch, and above the line in the other
2. add all the lines for both branches, even those that *shouldn't* appear in that branch
3. merge the changes into the other branch
4. add a commit to each branch that deletes everything that shouldn't be there
5. git should now be able to resolve most merge conflicts automatically

# See Also

* [Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
