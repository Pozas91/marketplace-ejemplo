---
name: wiki-lint
description: Revisa la wiki de procesos generada con wiki-codigo contra el código real y contra criterios de RAG-readiness. Comprueba que cada cita fichero:línea respalda lo que dice, detecta afirmaciones sin fuente, contradicciones entre páginas, enlaces rotos y secciones que no se entienden solas. Usar cuando se pida revisar, validar o auditar el manual o la wiki antes de darlo por bueno.
argument-hint: "[página o proceso] [--fix]"
allowed-tools: Read, Glob, Grep
context: fork
agent: general-purpose
---

# Revisión de la wiki de procesos

Revisión solicitada: $ARGUMENTS

- Si `$ARGUMENTS` nombra una página o proceso, revisa solo esa página. Si no, toda la wiki.
- **Sin `--fix` solo se informa: no se toca ningún fichero.** Con `--fix` se corrige lo
  mecánico (ver «Correcciones»); editar no está en `allowed-tools`, así que Claude Code pide
  permiso en cada cambio.

## Tu rol

Eres el revisor que no escribió el manual. Tu trabajo es encontrar dónde el texto dice algo
que el código no dice. Desconfía por defecto: una afirmación sin cita, o con una cita que no
la respalda, es un fallo aunque «suene razonable».

## Qué se revisa

Estructura de `wiki-codigo`: `docs/wiki/index.md`, `docs/wiki/log.md` y
`docs/wiki/procesos/*.md` con el frontmatter de `plantilla-pagina.md`.
Si `docs/wiki/` no existe, dilo y sugiere `/documentacion:wiki-codigo`.

### 1. Citas contra el código (el más importante)

Para cada afirmación con cita `(ruta:línea)` o `(ruta:inicio-fin)`:
1. Abre el fichero en esas líneas.
2. Clasifica:
   - **OK**: las líneas respaldan la afirmación.
   - **Cita desplazada**: lo que se afirma está en el fichero, pero en otras líneas (indica
     cuáles).
   - **No respaldada**: las líneas no dicen eso. Es el fallo grave: el modelo rellenó un hueco.
   - **Rota**: el fichero o las líneas no existen.

Si hay más de 40 citas, revisa todas las de «Reglas y validaciones» y «Puntos de
personalización» y una muestra de 1 de cada 3 del resto; di en el informe que es una muestra.

### 2. Afirmaciones sin fuente

Frases sobre comportamiento del sistema sin cita. No cuentan el «Resumen» (si lo que dice
está citado más abajo) ni «Procesos relacionados».

### 3. Contradicciones entre páginas

El mismo dato o regla descrito de forma distinta en dos páginas. Indica ambas citas y cuál
respalda el código.

### 4. RAG-readiness

- **Secciones que no se entienden solas**: «este proceso», «lo anterior», «como se ha dicho»
  sin repetir el nombre del proceso.
- **Frontmatter incompleto**: faltan `proceso`, `cliente`, `instalacion`, `tecnologia`,
  `version`, `modulos`, `ficheros_fuente`, `actualizado` o `estado`. `version: desconocida`
  se avisa como pendiente, no como error.
- **Metadatos que no cuadran con el contenido**: una página con `cliente: generico` que
  describe el comportamiento de un cliente concreto (nombrar qué clientes cambian un punto
  y enlazar su página está bien; contar qué hacen, no), o una `tecnologia` que el código citado
  no respalda. Sin metadatos fiables, un asistente mezcla la información de varios clientes.
- **Páginas de más de ~300 líneas**: candidatas a dividir en subprocesos.
- **Imágenes o pantallazos sin descripción en texto**: un buscador no puede leerlos.
- **Bloques de código largos** (más de 3 líneas): no aportan a un lector de soporte.

### 5. Estructura

- Páginas que no están en `index.md`, o entradas del índice sin página.
- Enlaces entre páginas que apuntan a ficheros que no existen.
- Páginas con `estado: revisado` y `actualizado` anterior a cambios en sus `ficheros_fuente`
  (si hay git: `git log -1 --format=%ad --date=short -- <fichero>`; pide permiso para usarlo).

### 6. Preguntas abiertas

Revisa las «Preguntas abiertas» de cada página: si alguna se responde leyendo el código,
márcala como «respondible» e indica dónde.

## Informe

```
## Revisión de la wiki · <fecha>
Páginas: N · Citas revisadas: N (todas | muestra)

| Resultado | Nº |
|---|---|
| Citas OK | |
| Citas desplazadas | |
| Citas no respaldadas | |
| Citas rotas | |
| Afirmaciones sin fuente | |
| Problemas de RAG-readiness | |
| Problemas de estructura | |

### Fallos graves (no respaldadas, contradicciones)
- <página>:<sección> · «<afirmación>» · cita (<ruta:línea>) · lo que dice el código: <…>

### Resto, por página
...

### Veredicto
<lista para revisión humana | necesita otra pasada de /documentacion:wiki-codigo>
```

## Correcciones (solo con `--fix`)

- Sí: mover citas desplazadas a las líneas correctas, arreglar enlaces e índice, completar
  frontmatter, repetir el nombre del proceso en secciones que no se entienden solas.
- No: reescribir afirmaciones no respaldadas ni resolver contradicciones. Se marcan con
  `> [!warning] Revisar: <motivo>` y las decide una persona.
- Al terminar, añade a `docs/wiki/log.md`:

```markdown
## [AAAA-MM-DD] revisión
- Páginas: N · Citas revisadas: N
- Corregido: N · Pendiente de decisión humana: N
```

## Anti-patrones

- Dar una cita por buena sin abrir el fichero.
- Corregir una afirmación no respaldada inventando otra «más probable».
- Quitar un `> [!warning]` cuya decisión sigue pendiente.
- Tocar ficheros sin `--fix`.
