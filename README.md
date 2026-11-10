# Marketplace de skills de Claude Code

Plugins de Claude Code para **documentar un código por procesos de negocio**: cada afirmación
lleva su cita `fichero:línea`, el resultado se revisa contra el código y se exporta a Word.
Es un *marketplace*: un catálogo que Claude Code lee para instalar plugins por nombre y
recibir sus actualizaciones.

Es público y sirve de plantilla: cópialo como repo privado de tu empresa y adapta los
ejemplos (aquí son de un almacén).

## Estructura

```
empresa-skills/                      ← raíz del marketplace (este repo)
├── .claude-plugin/
│   └── marketplace.json             ← catálogo: nombre del marketplace y lista de plugins
├── plugins/                         ← nombre por convención; manda el `source` del catálogo
│   ├── documentacion/               ← un plugin = una carpeta
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json          ← manifiesto: name, description, version
│   │   ├── skills/
│   │   │   ├── wiki-codigo/         ← SKILL.md + plantilla-pagina.md
│   │   │   ├── wiki-lint/
│   │   │   ├── wiki-query/
│   │   │   ├── mapa-repo/           ← SKILL.md + scripts/mapa_repo.py (Python)
│   │   │   ├── exportar-manual/     ← SKILL.md + scripts/ (PowerShell y filtro de pandoc)
│   │   │   └── onboarding-procesos/
│   │   └── README.md
│   ├── diagramas/                   ← mermaid, diagrama-flujo
│   └── revision/                    ← grill-me, code-review y .mcp.json (Microsoft Learn)
├── ejemplos/
│   ├── hooks/                       ← hooks de ejemplo: ruff, pre-commit y aviso de Windows
│   └── mcp-festivos/                ← MCP de ejemplo: envuelve una API pública (no es un plugin)
├── CHANGELOG.md
├── GUIA-SKILLS.md                   ← qué enseña cada skill y notas para la clase
├── LICENSE                          ← MIT
└── README.md
```

| Plugin | Skills | Sesión |
|---|---|---|
| `documentacion` | `wiki-codigo`, `onboarding-procesos` · `wiki-lint`, `exportar-manual`, `mapa-repo` · `wiki-query` | 1 · 2 · 3 |
| `diagramas` | `mermaid` (`diagrama-flujo`, de consulta) | 1 |
| `revision` | `grill-me` · `code-review` (de consulta) + MCP de Microsoft Learn | 2 · 3 |

`.claude-plugin/marketplace.json` en la raíz es obligatorio. El `plugin.json` de cada plugin
es opcional, pero sin él no hay `version` y nadie recibe los cambios: se deja siempre.

Más adelante, dentro de cada plugin: `agents/` (subagentes), `hooks/hooks.json` (hooks) y
`.mcp.json` (servidores MCP; `revision` ya trae uno). Ver «Reglas».

## Reglas

1. **Dentro de `.claude-plugin/` solo va el JSON.** Si `skills/` se mete ahí, no carga.
2. **El `name` del plugin en `marketplace.json` y en su `plugin.json` es el mismo.** Si no,
   la instalación falla con `Plugin "<x>" not found`.
3. **`source` es relativo a la raíz del marketplace** (`./plugins/documentacion`), sin `..`.
4. **Los nombres no se cambian** una vez instalado en otros equipos: rompe las instalaciones.
   Para cambiar lo que se ve, usar `displayName` en `plugin.json`.
5. **Cada cambio que deba llegar a los demás sube `version`** en `plugin.json` (y se anota en
   `CHANGELOG.md`). La versión va solo en `plugin.json`, no también en `marketplace.json`.
6. **Las skills de un plugin llevan prefijo**: `wiki-codigo` se lanza como
   `/documentacion:wiki-codigo`.
7. **Las herramientas MCP de un plugin también llevan prefijo**:
   `mcp__plugin_<plugin>_<servidor>__<herramienta>`. Es el nombre que va en los permisos.
8. Nada de datos de clientes ni credenciales en este repo (tampoco en un `.mcp.json`: las
   credenciales van en variables de entorno, `${VARIABLE}`).

## Probar cambios antes de publicarlos

```bash
claude plugin validate ./plugins/documentacion     # manifiesto y frontmatter de las skills (uno por plugin)
claude plugin validate .                           # el catálogo
claude --plugin-dir ./plugins/documentacion        # sesión con el plugin cargado, sin instalar
```

Dentro de la sesión, `/reload-plugins` recarga tras editar.

`validate` puede avisar de que falta icono: es requisito del directorio público de
Anthropic, no de un marketplace. Se puede ignorar.

## Instalar (cada persona, una vez)

Este mismo repo:

```bash
claude plugin marketplace add Pozas91/marketplace-ejemplo
claude plugin install documentacion@empresa-skills
```

En tu copia privada. Requisito: `git` con acceso al repo y la credencial ya guardada (Claude
Code no pide contraseña: si git tiene que preguntar, falla).

```bash
claude plugin marketplace add <URL-git-del-repo>     # GitLab/Azure/etc.: URL completa .git
claude plugin install documentacion@empresa-skills
claude plugin install diagramas@empresa-skills      # opcional
claude plugin install revision@empresa-skills       # opcional
```

O dentro de Claude Code: `/plugin marketplace add <URL>` y `/plugin install documentacion@empresa-skills`.

## Requisitos

La mayoría de las skills solo necesitan Claude Code. Tres usan programas externos (Windows,
sin permisos de administrador):

| Para | Hace falta | Cómo se instala |
|---|---|---|
| `documentacion:exportar-manual` (wiki a Word) | [pandoc](https://pandoc.org) | `winget install --id JohnMacFarlane.Pandoc -e` y abrir una terminal nueva |
| `documentacion:exportar-manual --pdf` | Microsoft Word | Sin Word sale el `.docx`; el PDF se guarda a mano |
| `documentacion:mapa-repo` y el MCP de `ejemplos/mcp-festivos` | [uv](https://docs.astral.sh/uv/) | `winget install --id astral-sh.uv -e` |
| Hooks de `ejemplos/hooks` | `ruff` y `pre-commit` | `uv tool install ruff` · `uv tool install pre-commit` |

Cómo exportar la wiki a Word, con ejemplos y la plantilla corporativa: ver el
[README de `documentacion`](plugins/documentacion/README.md#exportar-la-wiki-a-word).

## Ejemplos que no son plugins

| Carpeta | Qué es |
|---|---|
| [`ejemplos/mcp-festivos`](ejemplos/mcp-festivos/README.md) | Un MCP de ~100 líneas en Python que envuelve una API pública de festivos: para ver qué es un MCP por dentro |
| [`ejemplos/hooks`](ejemplos/hooks/README.md) | Tres hooks en PowerShell: `ruff` tras editar, `pre-commit` antes de `git commit` y aviso de Windows cuando Claude necesita atención |

## Activarlo en el repo de código para todo el equipo

Desde la raíz del repo de código (no de este):

```bash
claude plugin marketplace add <URL-git-del-repo> --scope project
claude plugin install documentacion@empresa-skills --scope project
```

Escribe `extraKnownMarketplaces` y `enabledPlugins` en `.claude/settings.json`: hacer commit.
Quien clone el repo y confíe en la carpeta recibe el marketplace; cada persona lo instala
en su máquina la primera vez.

## Actualizar

- Quien publica: cambia, sube `version`, commit y push.
- Quien usa: `/plugin marketplace update empresa-skills`, o activar *auto-update* en
  `/plugin` → Marketplaces (desactivado por defecto en marketplaces que no son de Anthropic).

## Créditos

- `grill-me` es una adaptación al español de
  [`grilling`](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling),
  de Matt Pocock (licencia MIT).
- El patrón de wiki mantenida por un agente (escribir, consultar y revisar) se inspira en la
  idea [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) de
  Andrej Karpathy.

## Licencia

MIT. Ver [LICENSE](LICENSE).
