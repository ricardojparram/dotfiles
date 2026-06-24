# dotfiles

Config personal: zsh, kitty, nvim (LazyVim), fastfetch, Claude Code, skills, Firefox userChrome.

## Instalación (PC nueva)

```sh
curl -fsSL https://raw.githubusercontent.com/ricardojparram/dotfiles/main/install.sh | bash
```

`install.sh` clona el repo, aplica los symlinks y pregunta lo que haga falta
(GEMINI_API_KEY, merge de MCP, userChrome de Firefox, restaurar memorias).
Es idempotente: re-correrlo solo re-aplica symlinks y respalda lo que pise
en `*.bak.<fecha>`.

Si ya tenés el repo clonado:

```sh
./install.sh
```

## Qué symlinkea

| repo | destino |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `config/kitty` | `~/.config/kitty` |
| `config/nvim` | `~/.config/nvim` |
| `config/fastfetch` | `~/.config/fastfetch` |
| `config/claude/{CLAUDE.md,settings.json,statusline-command.sh}` | `~/.claude/` |
| `config/agents-skills` | `~/.agents/skills` |
| `userChrome.css` | perfil Firefox (opcional) |

## Fuera del repo (no se versionan)

- **Secrets** — `~/.zshrc.local` (cargado por `.zshrc`). Contiene la
  GEMINI_API_KEY. `install.sh` lo crea si das la key.
- **Memorias de Claude** — script `~/Documentos/scripts/backup-memories.sh`
  (+ tarballs en `./data`). Llevá esa carpeta por USB a la PC nueva; el
  `install.sh` ofrece restaurar el backup más reciente.

Ver `config/claude/README.md` para detalle de MCP y memorias.
