#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SCRIPT="$REPO_ROOT/docker-entrypoint.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME_DIR="$TMP_DIR/home"
BIN_DIR="$TMP_DIR/bin"
LOG_FILE="$TMP_DIR/pi-call.txt"
mkdir -p "$HOME_DIR" "$BIN_DIR"

cat > "$BIN_DIR/pi" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$LOG_FILE"
EOF
chmod +x "$BIN_DIR/pi"

(
  export HOME="$HOME_DIR"
  export PATH="$BIN_DIR:$PATH"
  export LOG_FILE
  export GIT_AUTHOR_NAME='Test User'
  export GIT_AUTHOR_EMAIL='test@example.com'
  unset GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
  bash "$SCRIPT" help
)

assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="$3"
  if [ "$expected" != "$actual" ]; then
    echo "$message: expected '$expected', got '$actual'" >&2
    exit 1
  fi
}

assert_equals 'Test User' "$(git config --file "$HOME_DIR/.gitconfig" --get user.name)" 'git user.name'
assert_equals 'test@example.com' "$(git config --file "$HOME_DIR/.gitconfig" --get user.email)" 'git user.email'
assert_equals 'help' "$(cat "$LOG_FILE")" 'pi args'

echo "docker entrypoint initializes git identity" 
