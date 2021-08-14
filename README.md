# Sleep Diary Internal Tools

As part of the [Sleep Diary Project](https://sleepdiary.github.io/), this manages the build environment used by other repositories.

See [the getting started guide](https://github.com/sleepdiary/docs/blob/main/development/getting-started.md) if you would like to run the internal tools on your computer.  Tools are rebuilt automatically every 30 days, so you should only need to use this repository directly if you're maintaining the Sleep Diary Project itself.

## Developing the tools themselves

This procedure should only be necessary if you need to e.g. improve the error messages printed by the build process.  If you're developing individual repositories, [the getting started guide](https://github.com/sleepdiary/docs/blob/main/development/getting-started.md) has everything you need.

To build the tools locally, do:

```bash
/path/to/sleepdiary/internal-tools/bin/run.sh build-local
```

This command builds local copies of the `sleepdiaryproject/*` containers, so it's not designed run inside a container itself.  As well as installing Docker (or an equivalent), you will need to install some common development packages like `curl` and `git`.

Once you've tested your changes locally, create a pull request in the normal way.  If and when your PR is accepted, [`main.yml`](.github/workflows/main.yml) will publish your changes to the `pre-release` tags in [our GitHub Packages repository](https://github.com/sleepdiary/internal-tools/pkgs/container/builder).  Other repositories use the `latest` tag, so this will not affect them.

Containers are configured a bit differently on GitHub's servers than when run locally.  For example, actions can use a different working directory than we expect.  Once your pre-release has been published, configure your local forks to test the new tag:

```bash
cd /path/to/sleepdiary/repo
# update the tag:
sed -i -e "s/builder:latest/builder:pre-release/g" .github/workflows/*.yml
# commit your changes:
git commit .github/workflows/*.yml \
  -m 's/builder:latest/builder:pre-release/g' \
  -m "Actual command:" \
  -m $'\tsed -i -e "s/builder:latest/builder:pre-release/g" .github/workflows/*.yml'
# push to your local fork:
git push safe-personal
```

Once you have pushed all the changes, do manual test runs of all the workflows in each of your forked repositories.  If everything works, reset all your repositories:

```bash
cd /path/to/sleepdiary/repo
git reset --hard unsafe-canonical/main
git push --force safe-personal unsafe-canonical/main:main
```

Once you have confirmed the new tag won't break anything, [create a new planned maintenance issue](https://github.com/sleepdiary/internal-tools/issues/new?assignees=&labels=planned-maintenance&template=planned-maintenance.md&title=%5BPlanned+maintenance%5D%3A+Update+the+builder) and [create a PR to pull `latest` 🠔 `main`](https://github.com/sleepdiary/internal-tools/compare/latest...main?expand=1).  The steps to take during maintenance should be something like:

1. Accept the PR
2. Publish Docker images
   1. Go to [the autobuild action](https://github.com/sleepdiary/internal-tools/actions/workflows/autobuild.yml)
   2. click the grey *Run workflow* button
   3. click the green *Run workflow* button
3. Run a test build for every repository

## See Also

- [Getting started](https://github.com/sleepdiary/docs/blob/main/development/getting-started.md)
- [Maintainer environment recommendations](https://github.com/sleepdiary/docs/blob/main/development/maintainer-environment-recommendations.md)
- [Minimising planned maintenance](https://github.com/sleepdiary/docs/blob/main/development/minimising-planned-maintenance.md)
