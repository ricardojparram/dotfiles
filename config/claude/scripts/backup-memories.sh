#!/usr/bin/env bash
# Backup local de memorias de Claude (engram + memoria nativa file-based).
# Genera un tarball en ~/Backups/claude-memories/ para llevar a otro PC.
#
#   Uso:      ./backup-memories.sh
#   Restaurar: ./backup-memories.sh restore <archivo.tar.gz>
set -euo pipefail

DEST="$HOME/Backups/claude-memories"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ "${1:-}" == "restore" ]]; then
  ARCHIVE="${2:?Falta ruta del tarball: ./backup-memories.sh restore <archivo>}"
  echo ">> Cerrá Claude Code antes de restaurar engram."
  read -rp ">> Restaurar desde $ARCHIVE a \$HOME? [y/N] " ok
  [[ "$ok" == "y" || "$ok" == "Y" ]] || { echo "Cancelado."; exit 1; }
  # engram: borrar wal/shm viejos para evitar corrupción al mezclar
  rm -f "$HOME/.engram/engram.db-wal" "$HOME/.engram/engram.db-shm"
  tar -xzf "$ARCHIVE" -C "$HOME"
  echo ">> Restaurado. Memorias engram + nativas en su lugar."
  exit 0
fi

# --- Backup ---
mkdir -p "$DEST"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 1. Engram (solo .db — consistente sin wal pendiente)
if [[ -f "$HOME/.engram/engram.db" ]]; then
  mkdir -p "$TMP/.engram"
  cp "$HOME/.engram/engram.db" "$TMP/.engram/engram.db"
fi

# 2. Memoria nativa file-based: ~/.claude/projects/*/memory/
#    Se preservan rutas relativas a $HOME para restore directo.
while IFS= read -r dir; do
  rel="${dir#"$HOME"/}"
  mkdir -p "$TMP/$(dirname "$rel")"
  cp -r "$dir" "$TMP/$(dirname "$rel")/"
done < <(find "$HOME/.claude/projects" -type d -name memory 2>/dev/null)

ARCHIVE="$DEST/claude-memories-$STAMP.tar.gz"
tar -czf "$ARCHIVE" -C "$TMP" .
echo ">> Backup creado: $ARCHIVE"
echo ">> Contenido:"
tar -tzf "$ARCHIVE" | sed 's/^/   /' | head -40
echo ">> Pasá ese .tar.gz al PC nuevo y corré:"
echo "   ./backup-memories.sh restore $ARCHIVE"
