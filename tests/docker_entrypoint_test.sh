#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SCRIPT="$REPO_ROOT/docker-entrypoint.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME_DIR="$TMP_DIR/home"
BIN_DIR="$TMP_DIR/bin"
LOG_FILE="$TMP_DIR/pi-call.txt"
mkdir -p "$HOME_DIR/.pi/agent/config" "$BIN_DIR"
printf '{"profile":"work"}\n' > "$HOME_DIR/.pi/agent/config/settings.work.json"

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
  export PI_AGENT_SETTINGS_FILE='settings.work.json'
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
assert_equals 'config/settings.work.json' "$(readlink "$HOME_DIR/.pi/agent/settings.json")" 'pi agent settings symlink'
assert_equals 'help' "$(cat "$LOG_FILE")" 'pi args'

MISSING_HOME_DIR="$TMP_DIR/missing-home"
mkdir -p "$MISSING_HOME_DIR" "$TMP_DIR/missing-bin"
ln -s "$BIN_DIR/pi" "$TMP_DIR/missing-bin/pi"
if (
  export HOME="$MISSING_HOME_DIR"
  export PATH="$TMP_DIR/missing-bin:$PATH"
  export LOG_FILE="$TMP_DIR/missing-pi-call.txt"
  export PI_AGENT_SETTINGS_FILE='missing.json'
  bash "$SCRIPT" help
) >"$TMP_DIR/missing.stdout" 2>"$TMP_DIR/missing.stderr"; then
  echo "Expected docker-entrypoint.sh to fail when PI_AGENT_SETTINGS_FILE target is missing" >&2
  exit 1
fi

if ! grep -Fq 'fichier de configuration Pi introuvable' "$TMP_DIR/missing.stderr"; then
  echo 'Expected missing settings error message' >&2
  cat "$TMP_DIR/missing.stderr" >&2
  exit 1
fi

echo "docker entrypoint initializes git identity and Pi settings symlink"
