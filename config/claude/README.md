# Claude AI config backup

Backup de configuración de Claude Code, MCPs y skills generales.

## Contenido

| Archivo/dir | Origen (symlink) | Nota |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Instrucciones globales |
| `settings.json` | `~/.claude/settings.json` | Permisos, plugins, statusline, tema |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Statusline custom |
| `mcp-servers.json` | snapshot de `~/.claude.json` | MCPs globales (NO symlink) |
| `../agents-skills/` | `~/.agents/skills` | Skills generales |

> Skills de proyecto (autofuturo) **no** se respaldan: van por proyecto, no global.

## Restaurar en PC nuevo

```sh
DOT=~/Escritorio/git/dotfiles
mkdir -p ~/.claude ~/.agents

# Config files (symlink)
for f in CLAUDE.md settings.json statusline-command.sh; do
  ln -sf "$DOT/config/claude/$f" ~/.claude/$f
done

# Skills generales
ln -sfn "$DOT/config/agents-skills" ~/.agents/skills

# MCPs: mergear mcp-servers.json en ~/.claude.json manual, o re-agregar con:
#   claude mcp add ...
# Ver mcp-servers.json para command/args de cada uno.
```

### MCPs

`mcp-servers.json` es snapshot (no symlink, porque `~/.claude.json` tiene
historial de proyectos que NO se sube). En PC nuevo, mergear la clave
`mcpServers` en `~/.claude.json` o recrear con `claude mcp add`.

⚠️ **pencil** apunta a ruta de extensión VSCode versionada
(`highagency.pencildev-0.6.37`) — ajustar versión en PC nuevo.

## Memorias (engram + nativa) — NO se suben a este repo

Script: `~/Documentos/scripts/backup-memories.sh` (fuera del repo).
Tarballs en `~/Documentos/scripts/data/`.

```sh
~/Documentos/scripts/backup-memories.sh            # crear backup
~/Documentos/scripts/backup-memories.sh restore <archivo.tar.gz>  # restaurar (Claude cerrado)
```

El tarball incluye `~/.engram/engram.db` + memoria nativa
(`~/.claude/projects/*/memory/`), con rutas relativas a `$HOME`.
Restore directo si el PC nuevo tiene mismo usuario/layout.

Sync alternativo de engram entre PCs:

1. **Git sync nativo de engram** — chunks comprimidos, sin merge conflicts.
   Repo privado aparte. Ver docs: github.com/Gentleman-Programming/engram
2. **Cloud opt-in** — replicación project-scoped. Local SQLite siempre es
   la fuente de verdad; aunque el cloud falle no se pierden datos.
