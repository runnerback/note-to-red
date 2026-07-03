#!/usr/bin/env bash
# Deploy locally-built plugin artifacts into an Obsidian vault.
# Copies ONLY manifest.json / main.js / styles.css. Never touches data.json
# (your WeChat accounts / settings live there and must be preserved).
#
# Paths are resolved relative to this script, so it keeps working after being
# moved. Override the vault via env var if your vault lives elsewhere:
#   OBSIDIAN_VAULT="/path/to/vault" ./deploy-to-vault.sh all
#
# Usage:
#   ./deploy-to-vault.sh            # deploy both plugins
#   ./deploy-to-vault.sh note-to-red
#   ./deploy-to-vault.sh wechat
set -euo pipefail

# This script lives at <obsidian-plugin>/note-to-red/docs/deploy-to-vault.sh
# so the repo root that contains both plugin repos is two levels up.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${PLUGIN_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# Real Obsidian vault (override with OBSIDIAN_VAULT=... if it moves).
VAULT="${OBSIDIAN_VAULT:-/Users/zhangjianbo/Documents/SynologyDrive/COMMON/12 notes/Obsidian-repository}"
PLUGINS_DIR="$VAULT/.obsidian/plugins"

# repo_dir  ->  vault_plugin_id
deploy_one() {
  local repo_dir="$1" plugin_id="$2"
  local src="$REPO_ROOT/$repo_dir"
  local dst="$PLUGINS_DIR/$plugin_id"

  echo "==> Deploying $repo_dir  ->  .obsidian/plugins/$plugin_id"
  if [[ ! -f "$src/main.js" ]]; then
    echo "    ERROR: $src/main.js not found. Run 'npm run build' in $repo_dir first." >&2
    return 1
  fi
  if [[ ! -d "$PLUGINS_DIR" ]]; then
    echo "    ERROR: vault plugins dir not found: $PLUGINS_DIR" >&2
    echo "    Set OBSIDIAN_VAULT=/path/to/vault and retry." >&2
    return 1
  fi
  mkdir -p "$dst"
  cp -f "$src/manifest.json" "$dst/manifest.json"
  cp -f "$src/main.js"       "$dst/main.js"
  [[ -f "$src/styles.css" ]] && cp -f "$src/styles.css" "$dst/styles.css"
  echo "    done (data.json left untouched)"
}

target="${1:-all}"
case "$target" in
  note-to-red) deploy_one "note-to-red" "note-to-red" ;;
  wechat)      deploy_one "obsidian-wechat-converter" "wechat-converter" ;;
  all)
    deploy_one "note-to-red" "note-to-red"
    deploy_one "obsidian-wechat-converter" "wechat-converter"
    ;;
  *) echo "Unknown target: $target (use: note-to-red | wechat | all)" >&2; exit 1 ;;
esac

echo "All done. In Obsidian: reload the plugin (or Cmd+P -> 'Reload app without saving')."
