# documentacion

Plugin de Claude Code para documentar el código **por procesos de negocio**, con cada
afirmación citada a `fichero:línea`.

## Skills

| Comando | Qué hace |
|---|---|
| `/documentacion:wiki-codigo <proceso> [carpeta]` | Escribe o actualiza la página del proceso en `docs/wiki/procesos/`, con índice y registro |
| `/documentacion:wiki-lint [página] [--fix]` | Revisa la wiki contra el código: citas, afirmaciones sin fuente, contradicciones, RAG-readiness |
| `/documentacion:wiki-query <pregunta> [--contrastar]` | Responde solo con la wiki, como lo haría un asistente, y valora la cobertura |
| `/documentacion:onboarding-procesos [proceso]` | Visita guiada al repositorio por procesos de negocio |

Claude también las activa solas si pides algo como «documenta el proceso de picking».

## Cambios

Ver [CHANGELOG.md](../../CHANGELOG.md) en la raíz del repositorio.
