#!/usr/bin/env bash
# Instalador de dotfiles de Ricardo.
#
# Uso remoto (PC nueva, repo aun no clonado):
#   curl -fsSL https://raw.githubusercontent.com/ricardojparram/dotfiles/main/install.sh | bash
#
# Uso local (ya dentro del repo):
#   ./install.sh
#
# Idempotente: re-correrlo solo re-aplica symlinks. Backups *.bak.STAMP
# de cualquier archivo real que pise.
set -euo pipefail

REPO_URL="https://github.com/ricardojparram/dotfiles.git"
DEFAULT_DIR="$HOME/Escritorio/git/dotfiles"
STAMP="$(date +%Y%m%d-%H%M%S)"

# --- helpers ----------------------------------------------------------------
c_blue=$'\033[1;34m'; c_grn=$'\033[1;32m'; c_yel=$'\033[1;33m'; c_red=$'\033[1;31m'; c_off=$'\033[0m'
info()  { printf '%s>>%s %s\n' "$c_blue" "$c_off" "$*"; }
ok()    { printf '%s ✓%s %s\n' "$c_grn"  "$c_off" "$*"; }
warn()  { printf '%s !%s %s\n' "$c_yel"  "$c_off" "$*"; }
err()   { printf '%s ✗%s %s\n' "$c_red"  "$c_off" "$*" >&2; }

ask() { # ask "pregunta" default  -> stdout respuesta
  local q="$1" def="${2:-}" ans
  if [[ -n "$def" ]]; then read -rp "$q [$def]: " ans; echo "${ans:-$def}"
  else read -rp "$q: " ans; echo "$ans"; fi
}
confirm() { # confirm "pregunta" -> 0 si y
  local ans; read -rp "$1 [y/N] " ans; [[ "$ans" == y || "$ans" == Y ]]; }

# Crea symlink src->dst. Respalda dst si es archivo/dir real (no symlink).
link() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || { warn "No existe en repo, salto: $src"; return; }
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    mv "$dst" "$dst.bak.$STAMP"
    warn "Respaldado $dst -> $dst.bak.$STAMP"
  fi
  ln -sfn "$src" "$dst"
  ok "$dst -> $src"
}

# --- 0. asegurar repo clonado ----------------------------------------------
SELF="${BASH_SOURCE[0]:-}"
SRC_DIR=""
[[ -f "$SELF" ]] && SRC_DIR="$(cd "$(dirname "$SELF")" && pwd)"

if [[ -n "$SRC_DIR" && -d "$SRC_DIR/config/claude" ]]; then
  REPO="$SRC_DIR"
  info "Repo detectado en $REPO"
else
  command -v git >/dev/null || { err "git no instalado."; exit 1; }
  REPO="$(ask "Dónde clonar dotfiles" "$DEFAULT_DIR")"
  if [[ -d "$REPO/.git" ]]; then
    info "Ya clonado, git pull…"; git -C "$REPO" pull --ff-only
  else
    info "Clonando $REPO_URL -> $REPO"; mkdir -p "$(dirname "$REPO")"
    git clone "$REPO_URL" "$REPO"
  fi
fi
cd "$REPO"

# --- 1. symlinks ------------------------------------------------------------
info "Aplicando symlinks…"
link "$REPO/.zshrc"                            "$HOME/.zshrc"
link "$REPO/config/kitty"                      "$HOME/.config/kitty"
link "$REPO/config/nvim"                       "$HOME/.config/nvim"
link "$REPO/config/fastfetch"                  "$HOME/.config/fastfetch"
link "$REPO/config/claude/CLAUDE.md"           "$HOME/.claude/CLAUDE.md"
link "$REPO/config/claude/settings.json"       "$HOME/.claude/settings.json"
link "$REPO/config/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link "$REPO/config/agents-skills"              "$HOME/.agents/skills"

# Firefox userChrome (opcional, perfil con nombre aleatorio por PC)
if [[ -f "$REPO/userChrome.css" ]] && confirm "Symlinkear userChrome.css a un perfil de Firefox?"; then
  prof="$(find "$HOME/.mozilla/firefox" -maxdepth 1 -name '*.default-release' -type d 2>/dev/null | head -1)"
  [[ -z "$prof" ]] && prof="$(find "$HOME/.mozilla/firefox" -maxdepth 1 -name '*.default*' -type d 2>/dev/null | head -1)"
  if [[ -n "$prof" ]]; then
    link "$REPO/userChrome.css" "$prof/chrome/userChrome.css"
    warn "Activá toolkit.legacyUserProfileCustomizations.stylesheets=true en about:config"
  else
    warn "No encontré perfil de Firefox; salto userChrome."
  fi
fi

# --- 2. secrets (~/.zshrc.local) -------------------------------------------
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  info "Secrets: el .zshrc fuente carga ~/.zshrc.local (fuera del repo)."
  key="$(ask "GEMINI_API_KEY (enter para saltar)" "")"
  if [[ -n "$key" ]]; then
    umask 077
    printf 'export GEMINI_API_KEY="%s"\n' "$key" > "$HOME/.zshrc.local"
    chmod 600 "$HOME/.zshrc.local"
    ok "~/.zshrc.local creado (chmod 600)"
  else
    warn "Saltado. Creá ~/.zshrc.local manual si necesitás la key."
  fi
else
  ok "~/.zshrc.local ya existe, no lo toco."
fi

# --- 3. MCP servers (merge en ~/.claude.json) ------------------------------
MCP_SNAP="$REPO/config/claude/mcp-servers.json"
if [[ -f "$MCP_SNAP" ]] && confirm "Mergear MCP servers en ~/.claude.json?"; then
  if command -v jq >/dev/null; then
    CJ="$HOME/.claude.json"
    [[ -f "$CJ" ]] || echo '{}' > "$CJ"
    cp "$CJ" "$CJ.bak.$STAMP"
    tmp="$(mktemp)"
    jq -s '.[0] * {mcpServers: ((.[0].mcpServers // {}) * .[1].mcpServers)}' "$CJ" "$MCP_SNAP" > "$tmp" && mv "$tmp" "$CJ"
    ok "MCP mergeados (backup $CJ.bak.$STAMP)"
    warn "Revisá ruta de 'pencil' (versión de extensión VSCode cambia por PC)."
  else
    warn "jq no instalado; mergeá $MCP_SNAP en ~/.claude.json a mano."
  fi
fi

echo
ok "Instalación terminada."
info "Pendiente manual: rotar la GEMINI_API_KEY si la reusaste; abrir nvim para que LazyVim instale plugins."
info "Reiniciá la shell:  exec zsh"
