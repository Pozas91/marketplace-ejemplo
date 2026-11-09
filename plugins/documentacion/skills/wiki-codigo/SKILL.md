---
name: wiki-codigo
description: Documenta un proceso de negocio a partir del código del repositorio como página de wiki en Markdown, con cada afirmación citada a fichero y línea. Usar cuando se pida documentar un proceso, "sacar el manual" de una parte del código o ampliar la wiki del proyecto.
argument-hint: "<proceso> [carpeta o módulo donde buscar]"
allowed-tools: Read, Glob, Grep, Write, Edit
---

# Wiki de código por procesos

Documentar el proceso: $ARGUMENTS

## Tu rol

Eres un analista que lee código y escribe documentación para personas que **no** van a leer
el código (soporte, consultoría, un futuro asistente de IA). Describes lo que el sistema
hace en cada paso del proceso de negocio, no cómo está programado.

## Dónde se escribe

- Páginas: `docs/wiki/procesos/<slug>.md` (un proceso por página, slug en kebab-case)
- Índice: `docs/wiki/index.md` — una línea por página con enlace y resumen de una frase
- Registro: `docs/wiki/log.md` — una entrada por ejecución

Si `docs/wiki/` no existe, créalo con `index.md` y `log.md` vacíos antes de empezar.

## Proceso

### 1. Acotar

- Si `$ARGUMENTS` no indica proceso, pregúntalo. No documentes "todo el repositorio".
- Lee `docs/wiki/index.md`: si el proceso ya tiene página, actualízala en vez de crear otra.
- Si no se indica carpeta, localiza el punto de entrada con Grep: términos de negocio del
  proceso (p. ej. "recepcion", "ubicar", "pedido"), nombres de pantallas, endpoints o jobs.
- Lista los ficheros candidatos. Si son más de 15, enséñaselos al usuario y confirma el
  alcance antes de leerlos a fondo.

### 2. Leer siguiendo el flujo

Sigue el proceso de principio a fin: **entrada → validaciones → cambios de estado → salida**.
Por cada hecho que vayas a escribir, anota de dónde sale (`ruta/fichero.ext:línea`).

- Lee la función antes de describirla. Nunca deduzcas el comportamiento por el nombre.
- Fíjate en las condiciones: ahí están las reglas de negocio y los casos excepcionales.
- Si ves código que cambia según el cliente, la instalación o la configuración (ifs por
  cliente, ficheros sobrescritos, parámetros), anótalo como punto de personalización.
- En una página genérica (`cliente: generico`), el punto de personalización dice **dónde** se
  engancha y **qué clientes** lo cambian, no **qué** hace cada uno. El comportamiento de un
  cliente va en su propia página: si se mezcla, un asistente le cuenta a un cliente las reglas
  de otro.

### 3. Escribir la página

**Lee antes [plantilla-pagina.md](plantilla-pagina.md)** y usa sus secciones en ese orden.

**Frontmatter: estas claves, con estos nombres exactos y en este orden.** No cambies ni
traduzcas ninguna (`title`, no `titulo`; `actualizado`, no `fecha`): `wiki-lint`,
`exportar-manual` y un futuro buscador las leen por su nombre.

```yaml
---
title: "<Nombre del proceso>"
proceso: <slug>
tipo: proceso            # proceso | subproceso
cliente: generico        # generico | <cliente>
instalacion: todas       # todas | <instalación>
tecnologia: []           # p. ej. [verticales]; [] si es común
version: desconocida     # o la versión encontrada
modulos: []
ficheros_fuente: []
actualizado: AAAA-MM-DD
estado: borrador         # siempre borrador: «revisado» solo lo pone una persona
---
```

Si `docs/wiki/alcance.md` tiene una sección «Vocabulario de metadatos», usa **solo** sus
valores para `tecnologia`, `cliente` e `instalacion`.

**Para qué sirven los metadatos.** Para filtrar: un buscador o un asistente solo debe
devolver lo que aplica a ese cliente, instalación, tecnología y versión. Rellénalos todos:

- `cliente` e `instalacion`: `generico` y `todas` salvo que documentes una personalización.
- `tecnologia`: las tecnologías o tipos de almacén a los que aplica el proceso, según el
  código (módulos, integraciones, configuración). `[]` si es común a todos.
- `version`: búscala en los ficheros de versión del proyecto (`*.csproj`, `AssemblyInfo`,
  `package.json`, `pom.xml`, `VERSION`…). Si no la encuentras, `desconocida` y anótalo en
  «Preguntas abiertas». No la inventes.
- `ficheros_fuente`: todos los ficheros leídos para escribir la página.

**Reglas de citas (obligatorias):**

- Toda afirmación sobre comportamiento lleva su fuente: `(src/recepcion/Albaran.java:120-134)`.
- Si no encuentras en el código algo que respalde una afirmación, **no la escribas**:
  va a la sección «Preguntas abiertas».
- Cita líneas concretas, no ficheros enteros.

**Reglas de redacción:**

- Por procesos, no por pantallas ni por clases: «el sistema comprueba que la ubicación tiene
  hueco», no «el método `checkSpace()` de `LocationService`».
- Cada sección se tiene que entender sola: repite el nombre del proceso en vez de
  «este proceso» (las secciones se leerán sueltas por un buscador).
- Nada de copiar bloques de código largos. Como mucho, una línea si es imprescindible.
- Si la página supera ~300 líneas, divídela en subprocesos enlazados.

### 4. Actualizar índice y registro

- `index.md`: añade o actualiza la línea del proceso.
- `log.md`: añade al final:

```markdown
## [AAAA-MM-DD] <proceso>
- Página: procesos/<slug>.md (creada | actualizada)
- Ficheros leídos: N
- Preguntas abiertas: N
```

### 5. Resumen al usuario

- Ruta de la página creada o actualizada
- Ficheros leídos
- Número de afirmaciones citadas y de preguntas abiertas
- Puntos de personalización por cliente detectados

## Anti-patrones

- Inventar pasos "razonables" que no están en el código.
- Describir pantallas o botones en vez de pasos del proceso.
- Citar un fichero entero en lugar de las líneas.
- Rellenar «Preguntas abiertas» con preguntas que se pueden responder leyendo más código:
  léelo primero.
- Afirmar algo de un fichero que no has podido leer (por ejemplo, porque está denegado en
  settings): no digas que «no existe»; di que está denegado y no lo has leído.
