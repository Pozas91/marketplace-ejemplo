---
name: code-review
description: Revisa los cambios recientes del repositorio (o los ficheros indicados) y devuelve un informe en español con hallazgos de corrección, manejo de errores, seguridad básica y legibilidad, cada uno con fichero y línea. Solo informa, no modifica código.
argument-hint: "[--commits N | ruta]"
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*)
---

# Code review

Revisión solicitada: $ARGUMENTS

## Estado del repositorio

- Rama actual: !`git branch --show-current`
- Cambios sin commitear: !`git status --short`
- Últimos commits: !`git log --oneline -5`

## Alcance

- Sin argumentos: cambios sin commitear + último commit (`git diff HEAD~1`).
- `--commits N`: los últimos N commits (`git diff HEAD~N`).
- Una ruta: revisar esos ficheros completos, no solo el diff.

Si el alcance tiene más de 30 ficheros, enseña la lista y pregunta antes de seguir.

## Qué buscar (por prioridad)

1. **Corrección**: condiciones invertidas, casos límite (vacío, nulo, cero, último elemento),
   comparaciones mal hechas, estados que no se actualizan, concurrencia.
2. **Datos**: escrituras a medias sin transacción, actualizaciones que pueden dejar datos
   incoherentes (stock, ubicaciones, estados de pedido).
3. **Errores**: excepciones capturadas y silenciadas, mensajes que no dicen qué falló,
   errores que se pierden entre capas.
4. **Seguridad básica**: SQL montado concatenando texto, credenciales en el código,
   datos de entrada sin validar en los bordes (API, ficheros, pantallas).
5. **Legibilidad y duplicación**: solo si dificulta de verdad entender o mantener el código.

## Reglas

- Lee el contexto completo de cada cambio, no solo las líneas del diff.
- Cada hallazgo necesita un **escenario concreto de fallo**: qué entrada o estado produce
  qué resultado incorrecto. Si no lo puedes describir, no es un hallazgo: como mucho, una duda.
- No reportes estilo que ya detecta un linter o un formateador.
- Máximo 15 hallazgos, los más graves primero. Mejor 3 ciertos que 15 dudosos.

## Formato del informe

```
# Code review — <alcance>

**Ficheros revisados:** N · **Hallazgos:** X (alta: A, media: M, baja: B)

## Hallazgos

### 1. <Título corto> · severidad: alta · confianza: alta
`ruta/fichero.ext:123`
**Qué pasa:** <descripción>
**Cuándo falla:** <escenario concreto>
**Propuesta:** <una o dos líneas>

## Dudas
- `ruta/fichero.ext:45` — <algo que no se ha podido confirmar>

## Lo que está bien
- <1-3 puntos, si los hay>
```

## Fuera de alcance

- Modificar código: esta skill solo informa. Los cambios los decide y hace una persona.
