# dotfiles

Config personal: zsh, kitty, nvim (LazyVim), fastfetch, Claude Code, skills, Firefox userChrome.

## Instalación (PC nueva)

```sh
curl -fsSL https://raw.githubusercontent.com/ricardojparram/dotfiles/main/install.sh | bash
```

`install.sh` (Fedora/dnf) clona el repo, instala paquetes y herramientas,
aplica los symlinks y pregunta lo que haga falta. Pasos (cada uno confirmable):

1. **Paquetes dnf**: `nvim fastfetch kitty zsh lsd fzf jq ripgrep unzip gcc …`
   (+ `lazygit` desde el COPR oficial `dejan/lazygit`, no está en repos base).
2. **oh-my-zsh** + plugins `zsh-autosuggestions`, `zsh-syntax-highlighting`.
3. **Runtimes JS**: nvm + node LTS + pnpm (corepack), bun. **opencode**.
4. **Homebrew** + tap de Gentleman: `engram`, `gentle-ai`, `gga`, `gitleaks`, `lazydocker`.
   (engram corre sobre brew.)
5. **JetBrainsMono Nerd Font** (iconos para lsd/fastfetch/kitty).
6. **Shell** por defecto → zsh.
7. **Symlinks** (ver tabla).
8. **MCP** (`codegraph`, `next-devtools`, `shadcn`) merge en `~/.claude.json`.
   **userChrome** de Firefox (opcional).

Es idempotente: respalda archivos reales que pise en `*.bak.<fecha>` y saltea
lo ya instalado.

## Portabilidad

Funciona para cualquier usuario, sin importar el path: `install.sh` detecta el
repo solo y usa `$HOME` en todo; los configs versionados (`.zshrc`, etc.) no
tienen rutas hardcodeadas a un usuario. Un `curl | bash` desde otra cuenta deja
el entorno funcional sin editar nada.

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
- **Memorias + chats de Claude** — aparte de los dotfiles. Script
  `~/Documentos/scripts/backup-memories.sh` (+ tarballs en `./data`) respalda
  engram, memoria nativa y los transcripts `.jsonl`. Llevá esa carpeta por USB
  a la PC nueva y corré `backup-memories.sh restore`. No tiene que ver con
  `install.sh`.

Ver `config/claude/README.md` para detalle de MCP.
