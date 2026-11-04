# Guía de las skills

Ocho skills de ejemplo para las sesiones, repartidas en tres plugins (`documentacion`,
`diagramas`, `revision`). Cada una enseña una parte distinta del frontmatter.

| Skill | Para qué | Qué enseña |
|---|---|---|
| `wiki-codigo` | Documentar un proceso de negocio desde el código, con citas fichero:línea | `argument-hint`, `$ARGUMENTS`, fichero de apoyo (`plantilla-pagina.md`) |
| `code-review` | Revisar cambios recientes y devolver un informe | `disable-model-invocation`, `allowed-tools` con comandos concretos, `` !`comando` `` |
| `diagrama-flujo` | Diagrama Mermaid de un proceso con tabla de fuentes | `model` (forzar Sonnet) |
| `mermaid` | Cualquier diagrama Mermaid (flujo, secuencia, estados, ER, clases) + visor HTML local | Varios ficheros de apoyo: `referencia.md` (se lee solo si hace falta) y `visor.html` (plantilla) |
| `onboarding-procesos` | Visita guiada al repo por procesos de negocio, para quien llega nuevo | Skill interactiva (`AskUserQuestion`), delega el reconocimiento en un subagente `Explore`, `Bash` acotado a git de lectura, escribir fuera de `allowed-tools` a propósito |
| `grill-me` | Entrevista por rondas para acotar un alcance o sacar lo que solo sabe una persona | `disable-model-invocation`, `Agent` en `allowed-tools` (busca hechos con subagentes), un protocolo de conversación en vez de un resultado |
| `wiki-lint` | Revisa la wiki contra el código (cada cita) y contra RAG-readiness | Modo solo informe por defecto y opción `--fix` en `$ARGUMENTS`; editar fuera de `allowed-tools` |
| `wiki-query` | Responde solo con la wiki, como lo haría el futuro asistente, y valora la cobertura | Restringir las fuentes por instrucción; `--contrastar` para comprobar contra el código |

## Instalar

**Como plugin** (lo normal): ver el [README](README.md). Las skills llevan el prefijo del
plugin: `/documentacion:wiki-codigo`.

**Sueltas** (para probar una sola o enseñar la diferencia): copiar la carpeta de la skill
desde `plugins/<plugin>/skills/` a `<repo>/.claude/skills/` y hacer commit. Se lanzan sin
prefijo: `/mermaid`. Ojo: una copia suelta no se actualiza al subir la versión del plugin.

## Usar

```
/documentacion:wiki-codigo recepción de mercancía src/recepcion
/documentacion:onboarding-procesos picking
/documentacion:wiki-lint recepcion
/documentacion:wiki-query ¿por qué un palé se queda en muelle sin ubicar? --contrastar
/diagramas:mermaid estados de un pedido de salida
/diagramas:diagrama-flujo ubicación de palés secuencia
/revision:grill-me manual AutoStore del cliente X
/revision:code-review --commits 3
```

`wiki-codigo`, `diagrama-flujo`, `mermaid`, `onboarding-procesos`, `wiki-lint` y `wiki-query`
también se activan solas si pides algo que encaja con su `description` («documenta el proceso
de picking», «explícame este proyecto»). `code-review` y `grill-me` solo se lanzan a mano.

## El frontmatter, campo a campo

| Campo | Qué hace | Ejemplo |
|---|---|---|
| `name` | Nombre de la skill; es también el `/comando` | todas |
| `description` | Claude la lee para decidir **cuándo** usar la skill. Es el campo más importante: qué hace + cuándo usarla | todas |
| `argument-hint` | Pista que aparece al escribir `/nombre` | `wiki-codigo` |
| `allowed-tools` | Herramientas que la skill puede usar **sin pedir permiso**. El resto siguen pidiendo confirmación (no es una prohibición) | `code-review`: solo comandos git de lectura |
| `disable-model-invocation` | `true` = Claude no la lanza por su cuenta; solo tú con `/nombre` | `code-review` |
| `model` | Fuerza un modelo mientras la skill está activa | `diagrama-flujo`: `sonnet` |

En el cuerpo:

- `$ARGUMENTS` se sustituye por lo que escribas después de `/nombre`.
- `` !`comando` `` ejecuta el comando **antes** de pasarle la skill a Claude y mete la
  salida en el texto (en `code-review`: rama, cambios y últimos commits).
- Los ficheros de apoyo (`plantilla-pagina.md`) solo se leen cuando la skill los necesita:
  no ocupan contexto hasta entonces.

## Para comentar en clase

- **`allowed-tools` no es una jaula.** Para prohibir de verdad: `deny` en
  `.claude/settings.json`, un hook `PreToolUse`, o un subagente con `tools` limitado.
- **La `description` decide si la skill se activa.** Si no salta cuando debería, casi
  siempre es la descripción: le falta el «cuándo usarla».
- **Una skill es texto.** Se mejora como un documento: se prueba, se ve dónde falla y se
  añade la regla que faltaba. Por eso va versionada en el repo.
- **`onboarding-procesos` vs. `/init` vs. `/team-onboarding`.** `/init` escribe el
  `CLAUDE.md` (contexto para Claude); `/team-onboarding` empaqueta tu configuración de Claude
  Code para un compañero; esta skill explica el código a una persona. Encaja justo después de
  `/init` en el bloque 3.
- **Delegar para no llenar el contexto.** El reconocimiento del repo lo hace un subagente
  `Explore` y solo vuelve el resumen: buen ejemplo para enseñar `/context` antes y después.

- **El ciclo de la wiki.** `wiki-codigo` escribe → `wiki-lint` revisa contra el código →
  `wiki-query` comprueba si basta para soporte. Son las 3 skills base del brief (manual por
  procesos, citas obligatorias, revisión contra el código) más la prueba de RAG-readiness.
- **`wiki-lint` y `wiki-query --contrastar` separan dos fallos:** la wiki no tiene el dato
  (falta documentar) o lo tiene mal (el modelo rellenó un hueco).

## Referencias (skills en las que nos basamos)

- **Grilling** (Matt Pocock): entrevista por rondas con árbol de decisiones. Base de
  `npg-planning:grill-me` y de `grill-me`.
  https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling
- **LLM Wiki** (Andrej Karpathy, gist de abril de 2026): «idea file» para que un agente
  mantenga una wiki en Markdown con fuentes, wiki y esquema (`CLAUDE.md`), y operaciones de
  ingest, query y lint. Base de `npg-knowledge:wiki-*`, `wiki-codigo`,
  `wiki-lint` y `wiki-query`.
  https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
