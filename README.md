# Sleep Diary Internal Tools

As part of the [Sleep Diary Project](https://sleepdiary.github.io/), this manages the build environment used by other repositories.

This repository is automatically built by [our GitHub Actions script](.github/workflows/main.yml) once every 30 days.  You should not need to download or edit this unless you're working on the build system itself.

# Running the build system in a project

Typically, a project is run as:

    docker run --rm -it -v /path/to/repo:/app sleepdiaryproject/builder [ --force ] [ command ]

This will the repository's `bin/entrypoint.sh` command, which in turn runs [`bin/sleepdiary-entrypoint.sh`](bin/sleepdiary-entrypoint.sh).

# Running the build system itself

The [`run.sh`](run.sh) script in this directory is the equivalent of `bin/entrypoint.sh` in your project, but is designed to be runnable outside of a container.  Your system will need to have `docker` and `curl` installed.

# Using the builder in a new project

1. copy [`example-entrypoint.sh`](example-entrypoint.sh) to `bin/entrypoint.sh` in your project, then edit it as appropriate
2. copy [`example-main.yml`](example-main.yml) to `.github/workflows/main.yml` in your project - you shouldn't need to edit it
