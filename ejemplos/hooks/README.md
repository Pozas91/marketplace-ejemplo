# Hooks de ejemplo

Un hook es un comando que Claude Code ejecuta **siempre** en un momento concreto (antes de
usar una herramienta, después de editar, cuando necesita tu atención…). No depende de que el
modelo se acuerde: lo ejecuta Claude Code, no Claude.

- Todos los eventos y su formato: [referencia de hooks](https://code.claude.com/docs/en/hooks)
- Guía con ejemplos: [Automate actions with hooks](https://code.claude.com/docs/en/hooks-guide)
- Dentro de Claude Code, `/hooks` lista los que hay configurados

| Hook | Evento | Qué hace | Script |
|---|---|---|---|
| Formatear | `PostToolUse` con `Edit\|Write` | Pasa `ruff format` al `.py` que Claude acaba de escribir | [`formatear.ps1`](scripts/formatear.ps1) |
| Pre-commit | `PreToolUse` con `Bash`, solo `git commit` | Pasa `pre-commit` antes del commit. Si falla, **lo bloquea** (salida 2) y Claude recibe el error para corregirlo | [`precommit.ps1`](scripts/precommit.ps1) |
| Notificación | `Notification` | Aviso de Windows cuando Claude pide permiso, pregunta algo o lleva rato esperando | [`notificar.ps1`](scripts/notificar.ps1) |

## Montar la demo en un minuto

En PowerShell, desde la carpeta donde se quiera crear (no hace falta clonar nada):

```powershell
irm https://raw.githubusercontent.com/Pozas91/marketplace-ejemplo/main/ejemplos/hooks/instalar-demo.ps1 | iex
cd demo-hooks
claude
```

Crea `demo-hooks/` con git, los tres hooks, `.pre-commit-config.yaml` y un `demo-malo.py` con
fallos a propósito, y escribe los pasos de la demo. Volver a lanzarlo la deja como al
principio. Necesita `ruff` y `pre-commit` (ver Requisitos).

## Instalarlos en un repo

1. Copiar `scripts/*.ps1` a `<repo>/.claude/hooks/`
2. Copiar el bloque `hooks` de [`settings.json`](settings.json) a `<repo>/.claude/settings.json`
   (para todo el equipo) o a `~/.claude/settings.json` (solo para ti, en todos los repos;
   cambiando `${CLAUDE_PROJECT_DIR}/.claude/hooks/` por la ruta de los scripts)
3. Para el de pre-commit: `.pre-commit-config.yaml` en la raíz (hay uno de ejemplo aquí)
4. Reiniciar `claude` y comprobar con `/hooks`

Requisitos: `ruff` y `pre-commit` (`uv tool install ruff`, `uv tool install pre-commit`). Si no
están, los hooks dejan pasar y avisan en el log; no paran a Claude.

## Cómo funcionan

- **Entrada**: Claude Code le pasa al script un JSON por la entrada estándar (qué herramienta,
  con qué parámetros, en qué carpeta). `formatear.ps1` lee de ahí `tool_input.file_path`
- **Salida**: `0` = sigue; `2` = bloquea, y lo que el script escriba en stderr le llega a
  Claude como motivo; otro código = error que no bloquea
- **`matcher`** filtra por herramienta (`Edit|Write`) o tipo de aviso (`permission_prompt`);
  **`if`** afina con la sintaxis de permisos (`Bash(git commit *)`)
- **Forma `command` + `args`**: se ejecuta sin shell intermedia y `${CLAUDE_PROJECT_DIR}` se
  sustituye por la raíz del repo. Funciona igual con Git Bash o sin él
- **`async: true`** en la notificación: no hace esperar a Claude mientras sale el aviso

## Lo que aprendimos probándolos

- El hook de commit corre **antes del comando entero**. Con `git add -A && git commit`, al
  ejecutarse aún no hay nada preparado: por eso revisa también los modificados y los nuevos
- Los scripts van en ASCII y leen la entrada en UTF-8: con PowerShell 5.1, una ruta con tildes
  (`formación`) llegaría rota
- Si el equipo ya tiene `pre-commit install` en git, el commit fallaría igual; el hook hace que
  Claude lo vea antes y lo arregle solo

## Adaptarlos

- .NET en vez de Python: en `formatear.ps1`, cambiar el filtro a `\.cs$` y `ruff format` por
  `dotnet format whitespace --include "$fichero"`
- Otro aviso: el `matcher` de `Notification` acepta `permission_prompt`, `idle_prompt`,
  `elicitation_dialog`, `agent_needs_input`, `agent_completed`…
- En un plugin: el mismo bloque en `plugins/<plugin>/hooks/hooks.json`, con
  `${CLAUDE_PLUGIN_ROOT}` en lugar de `${CLAUDE_PROJECT_DIR}/.claude`
