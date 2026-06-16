#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SCRIPT="$REPO_ROOT/scripts/pi"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME_DIR="$TMP_DIR/home"
WORK_DIR="$TMP_DIR/workspace/project"
BIN_DIR="$TMP_DIR/bin"
mkdir -p "$HOME_DIR/.pi" "$HOME_DIR/.config/picapsule" "$WORK_DIR" "$BIN_DIR"
: > "$HOME_DIR/.config/picapsule/.env"

cat > "$BIN_DIR/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$TMP_DIR/docker-args.txt"
EOF
chmod +x "$BIN_DIR/docker"

git config --file "$HOME_DIR/.gitconfig" user.name 'Test User'
git config --file "$HOME_DIR/.gitconfig" user.email 'test@example.com'

(
  unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
  export HOME="$HOME_DIR"
  export PATH="$BIN_DIR:$PATH"
  export TMP_DIR
  cd "$WORK_DIR"
  "$SCRIPT" help
)

assert_contains() {
  if ! grep -Fqx -- "$1" "$TMP_DIR/docker-args.txt"; then
    echo "Expected docker args to contain: $1" >&2
    cat "$TMP_DIR/docker-args.txt" >&2
    exit 1
  fi
}

assert_contains "-e"
assert_contains "GIT_AUTHOR_NAME=Test User"
assert_contains "GIT_AUTHOR_EMAIL=test@example.com"
assert_contains "GIT_COMMITTER_NAME=Test User"
assert_contains "GIT_COMMITTER_EMAIL=test@example.com"

echo "scripts/pi forwards git identity"
