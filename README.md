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

It also forwards your Git author/committer identity so commits made from inside the container keep the expected name and email.

## Repository layout

- `Dockerfile` – builds the `picapsule` image
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

## Notes

- Do not run the wrapper from `/` or from your home directory `~`.
- The current working directory is mounted as `/workspace` inside the container.
- The container entrypoint is the Pi CLI installed in the image.
