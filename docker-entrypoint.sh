#!/usr/bin/env bash
set -euo pipefail

GIT_NAME="${GIT_AUTHOR_NAME:-${GIT_COMMITTER_NAME:-}}"
GIT_EMAIL="${GIT_AUTHOR_EMAIL:-${GIT_COMMITTER_EMAIL:-}}"

if [ -n "$GIT_NAME" ]; then
  git config --global user.name "$GIT_NAME"
fi

if [ -n "$GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
fi

exec "${PI_BIN:-pi}" "$@"
