# picapsule

Inspired by [`pi-less-yolo`](https://github.com/cjermain/pi-less-yolo), then adjusted to better fit my personal zero-trust paranoia.

A small Docker-based wrapper around the `pi` coding agent.

This repository provides:

- a container image with the tools needed to run `pi`
- a local wrapper script at `scripts/pi`
- a simple `Makefile` for build and test commands
- a test that verifies the wrapper forwards Git identity correctly

## What it does

The wrapper runs `pi` inside a hardened container and mounts:

- your current project into `/workspace`
- your local `~/.pi` directory into the container
- your environment file from `~/.config/picapsule/.env`

It also forwards your Git author/committer identity, and the container entrypoint maps it to Git `user.name` / `user.email` so commits made from inside the container keep the expected name and email.

If `PI_AGENT_SETTINGS_FILE` is defined in `~/.config/picapsule/.env`, the entrypoint also ensures that `~/.pi/agent/settings.json` is a symlink to `~/.pi/agent/config/$PI_AGENT_SETTINGS_FILE` inside the container.

## Repository layout

- `Dockerfile` – builds the `picapsule` image
- `docker-entrypoint.sh` – initializes Git identity, ensures the Pi agent settings symlink, then launches `pi`
- `scripts/pi` – wrapper used to launch `pi` in Docker
- `Makefile` – helper commands
- `tests/scripts_pi_test.sh` – wrapper test

## Prerequisites

- Docker
- Bash
- a local Pi configuration in `~/.pi`
- an env file at `~/.config/picapsule/.env`

## Build the image

```bash
make build
```

## Run tests

```bash
make test
```

## Use the wrapper

You can run the wrapper directly:

```bash
./scripts/pi
```

Or add the repository `scripts` directory to your shell `PATH` so you can call `pi` directly.

### Bash

Add this line to your `~/.bashrc`:

```bash
export PATH="/path/to/this/repo/scripts:$PATH"
```

Then reload your shell:

```bash
source ~/.bashrc
```

### Zsh

Add this line to your `~/.zshrc`:

```zsh
export PATH="/path/to/this/repo/scripts:$PATH"
```

Then reload your shell:

```zsh
source ~/.zshrc
```

After that, you can launch:

```bash
pi
```

## Environment configuration

You can configure the Pi agent settings profile from `~/.config/picapsule/.env`:

```bash
PI_AGENT_SETTINGS_FILE=settings.work.json
```

With this value, the container creates or refreshes:

```bash
~/.pi/agent/settings.json -> ~/.pi/agent/config/settings.work.json
```

The target file must already exist in your local `~/.pi` directory.

## Notes

- Do not run the wrapper from `/` or from your home directory `~`.
- The current working directory is mounted as `/workspace` inside the container.
- The container entrypoint is the Pi CLI installed in the image.
