# dotfiles

Config personal: zsh, kitty, nvim (LazyVim), fastfetch, Claude Code, skills, Firefox userChrome.

## Instalación (PC nueva)

```sh
curl -fsSL https://raw.githubusercontent.com/ricardojparram/dotfiles/main/install.sh | bash
```

`install.sh` clona el repo, aplica los symlinks y pregunta lo que haga falta
(merge de MCP, userChrome de Firefox).
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

- **Secrets** — `~/.zshrc.local` (cargado por `.zshrc`). Creálo a mano con
  tus API keys; queda fuera del repo.
- **Memorias de Claude** — aparte de los dotfiles. Script
  `~/Documentos/scripts/backup-memories.sh` (+ tarballs en `./data`).
  Llevá esa carpeta por USB a la PC nueva y corré
  `backup-memories.sh restore`. No tiene que ver con `install.sh`.

Ver `config/claude/README.md` para detalle de MCP.
