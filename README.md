# dotfiles

Config personal: zsh, kitty, nvim (LazyVim), fastfetch, Claude Code, skills, Firefox userChrome.

## Instalación (PC nueva)

```sh
curl -fsSL https://raw.githubusercontent.com/ricardojparram/dotfiles/main/install.sh | bash
```

`install.sh` (Fedora/dnf) clona el repo, instala paquetes y herramientas,
aplica los symlinks y pregunta lo que haga falta. Pasos (cada uno confirmable):

1. **Paquetes dnf**: `nvim lazygit fastfetch kitty zsh lsd fzf jq ripgrep` (+git/curl).
2. **oh-my-zsh** + plugins `zsh-autosuggestions`, `zsh-syntax-highlighting`.
3. **Runtimes JS**: nvm + node LTS + pnpm (corepack), bun. **opencode**.
4. **Shell** por defecto → zsh.
5. **Symlinks** (ver tabla).
6. **MCP** merge en `~/.claude.json`. **userChrome** de Firefox (opcional).

Es idempotente: respalda archivos reales que pise en `*.bak.<fecha>` y saltea
lo ya instalado.

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
