#!/usr/bin/env bash
set -euo pipefail

ensure_pi_agent_settings_symlink() {
  local settings_file="${PI_AGENT_SETTINGS_FILE:-}"
  local pi_home="${PI_HOME:-$HOME/.pi}"
  local agent_dir="$pi_home/agent"
  local link_path="$agent_dir/settings.json"
  local target_path="$agent_dir/config/$settings_file"

  if [ -z "$settings_file" ]; then
    return
  fi

  if [ ! -f "$target_path" ]; then
    echo "Erreur: fichier de configuration Pi introuvable: $target_path (PI_AGENT_SETTINGS_FILE=$settings_file)" >&2
    exit 1
  fi

  mkdir -p "$agent_dir"

  if [ -L "$link_path" ]; then
    local current_target
    current_target="$(readlink "$link_path")"
    if [ "$current_target" = "config/$settings_file" ] || [ "$current_target" = "$target_path" ]; then
      return
    fi
    rm -f "$link_path"
  elif [ -e "$link_path" ]; then
    if [ -d "$link_path" ]; then
      echo "Erreur: $link_path doit être un lien symbolique, pas un dossier" >&2
      exit 1
    fi
    rm -f "$link_path"
  fi

  ln -s "config/$settings_file" "$link_path"
}

GIT_NAME="${GIT_AUTHOR_NAME:-${GIT_COMMITTER_NAME:-}}"
GIT_EMAIL="${GIT_AUTHOR_EMAIL:-${GIT_COMMITTER_EMAIL:-}}"

# Only configure Pi if we're actually running it
if [ "$1" != "bash" ] && [ "$1" != "sh" ] && [ "$1" != "node" ]; then
  ensure_pi_agent_settings_symlink

  if [ -n "$GIT_NAME" ]; then
    git config --global user.name "$GIT_NAME"
  fi

  if [ -n "$GIT_EMAIL" ]; then
    git config --global user.email "$GIT_EMAIL"
  fi

  exec "${PI_BIN:-pi}" "$@"
else
  # Pass through to requested shell/node
  exec "$@"
fi
