#!/usr/bin/env bash
# Install dotfiles by symlinking shared/* and <platform>/* into $HOME.
# Detects WSL vs macOS automatically; override with: ./install.sh <mac|wsl>

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$REPO/shared"

# --- detect platform ---
if [[ $# -ge 1 ]]; then
  PLATFORM="$1"
else
  case "$(uname -s)" in
    Darwin) PLATFORM="mac" ;;
    Linux)  PLATFORM="wsl" ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
fi

PLATFORM_DIR="$REPO/$PLATFORM"
if [[ ! -d "$PLATFORM_DIR" ]]; then
  echo "No config directory for platform '$PLATFORM' at $PLATFORM_DIR" >&2
  exit 1
fi

echo "Installing dotfiles for platform: $PLATFORM"
echo "Repo: $REPO"
echo

# link $1 (abs) -> $HOME/$2, backing up any existing file/link
link() {
  local src="$1"
  local rel="$2"
  local dest="$HOME/$rel"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$(readlink "$dest" 2>/dev/null || true)" == "$src" ]]; then
      return 0
    fi
    mv "$dest" "$dest.bak.$(date +%s)"
  fi
  ln -s "$src" "$dest"
  echo "  $rel -> $src"
}

# Apply a source dir to $HOME:
#   - .ssh/* is merged (each file is linked individually)
#   - bin, .vim are linked as whole directories
#   - everything else is linked by its top-level name
apply() {
  local base="$1"
  [[ -d "$base" ]] || return 0

  for entry in "$base"/.[!.]* "$base"/*; do
    [[ -e "$entry" ]] || continue
    local name="$(basename "$entry")"
    case "$name" in
      .ssh)
        # merge contents
        for sshfile in "$entry"/.[!.]* "$entry"/*; do
          [[ -e "$sshfile" ]] || continue
          link "$sshfile" ".ssh/$(basename "$sshfile")"
        done
        ;;
      terminfo-24bit.src)
        # handled below via tic, not symlinked
        ;;
      *)
        link "$entry" "$name"
        ;;
    esac
  done
}

# shared first, platform second (platform wins on collisions since link() backs up + replaces)
apply "$SHARED"
apply "$PLATFORM_DIR"

# --- antidote (zsh plugin manager) ---
ANTIDOTE_DIRS=(
  /opt/homebrew/opt/antidote/share/antidote
  /usr/share/zsh-antidote
  /usr/share/zsh/plugins/antidote
  "$HOME/.antidote"
)
antidote_found=false
for d in "${ANTIDOTE_DIRS[@]}"; do
  [[ -f "$d/antidote.zsh" ]] && antidote_found=true && break
done
if ! $antidote_found; then
  echo
  echo "Installing antidote (zsh plugin manager)..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

# --- terminfo ---
if [[ -f "$SHARED/terminfo-24bit.src" ]]; then
  echo
  echo "Compiling terminfo (needs sudo)..."
  sudo tic -x -o "$HOME/.terminfo" "$SHARED/terminfo-24bit.src"
fi

# --- platform post-install ---
case "$PLATFORM" in
  wsl)
    mkdir -p "$HOME/.1password"
    if [[ ! -x /mnt/c/tools/npiperelay.exe ]]; then
      echo
      echo "WARNING: /mnt/c/tools/npiperelay.exe not found."
      echo "  Install it from https://github.com/jstarks/npiperelay/releases"
    fi
    ;;
esac

echo
echo "Done. Open a new shell to pick up changes."
