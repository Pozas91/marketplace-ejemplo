# revision

| Comando | Qué hace |
|---|---|
| `/revision:grill-me <plan o alcance>` | Entrevista por rondas con recomendación en cada pregunta (adaptada de Matt Pocock, MIT). Solo se lanza a mano |
| `/revision:code-review [--commits N \| ruta]` | Informe de los cambios recientes con escenario de fallo concreto. No modifica código. Solo se lanza a mano |

## MCP incluido: Microsoft Learn

`.mcp.json` en la raíz del plugin conecta el servidor MCP oficial de Microsoft Learn
(`https://learn.microsoft.com/api/mcp`): busca en la documentación de .NET, C# y SQL Server.
Es remoto, no pide login y solo lee documentación pública. Sirve, por ejemplo, para que
`code-review` contraste una recomendación con la documentación oficial.

- Arranca solo al activar el plugin: no hay que aprobarlo aparte, como con un `.mcp.json` de
  proyecto.
- Las herramientas llevan el prefijo del plugin:
  `mcp__plugin_revision_microsoft-learn__microsoft_docs_search` (también `…__microsoft_docs_fetch`
  y `…__microsoft_code_sample_search`).
- Para no confirmar cada llamada, en `.claude/settings.json`:
  `"allow": ["mcp__plugin_revision_microsoft-learn__*"]`
- La consulta viaja a Microsoft: no poner nombres de clientes ni código en la pregunta.
- Si no trabajas con tecnología de Microsoft, desactívalo en `/mcp`.

Ver [CHANGELOG.md](../../CHANGELOG.md) en la raíz del repositorio.
