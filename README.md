# Marketplace de skills de Claude Code

Repositorio **privado** con los plugins internos de Claude Code. Es un *marketplace*: un
catálogo que Claude Code lee para instalar plugins por nombre y recibir sus actualizaciones.

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
│   │   │   └── onboarding-procesos/
│   │   └── README.md
│   ├── diagramas/                   ← mermaid, diagrama-flujo
│   └── revision/                    ← grill-me, code-review y .mcp.json (Microsoft Learn)
├── CHANGELOG.md
├── GUIA-SKILLS.md                   ← qué enseña cada skill y notas para la clase
└── README.md
```

| Plugin | Skills | Sesión |
|---|---|---|
| `documentacion` | `wiki-codigo`, `onboarding-procesos` · `wiki-lint` · `wiki-query` | 1 · 2 · 3 |
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

`validate` avisa de que falta `LICENSE` e icono: son requisitos del directorio público de
Anthropic, no de un marketplace interno. Se pueden ignorar.

## Instalar (cada persona, una vez)

Requisito: `git` con acceso al repo y la credencial ya guardada (Claude Code no pide
contraseña: si git tiene que preguntar, falla).

```bash
claude plugin marketplace add <URL-git-del-repo>     # GitLab/Azure/etc.: URL completa .git
claude plugin install documentacion@empresa-skills
claude plugin install diagramas@empresa-skills      # opcional
claude plugin install revision@empresa-skills       # opcional
```

O dentro de Claude Code: `/plugin marketplace add <URL>` y `/plugin install documentacion@empresa-skills`.

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
