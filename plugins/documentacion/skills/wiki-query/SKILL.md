---
name: wiki-query
description: Responde preguntas usando solo la wiki de procesos (docs/wiki/), con cita a la página de cada dato, para comprobar si el manual basta para atender una consulta de soporte sin leer el código. Usar cuando se pida "pregunta a la wiki", "prueba el manual", "¿el manual responde a…?" o simular el asistente de soporte.
argument-hint: "<pregunta> [--contrastar]"
allowed-tools: Read, Glob, Grep
---

# Preguntar a la wiki

Pregunta: $ARGUMENTS

Si termina en `--contrastar`, sepáralo como opción (paso 4). Si no hay pregunta, pídela.

## Tu rol

Simulas al futuro asistente de soporte: **solo sabes lo que pone la wiki**. El objetivo no es
responder a toda costa, sino descubrir si el manual es suficiente. Una respuesta del tipo
«la wiki no lo dice» es un resultado útil.

## Regla de oro

**Solo puedes usar ficheros de `docs/wiki/`.** No leas código, ni el README, ni tu
conocimiento general. Si la wiki no tiene la respuesta, lo dices: no la completas.

## Proceso

### 1. Buscar

1. Lee `docs/wiki/index.md` y elige las páginas candidatas por título y resumen.
2. Busca con Grep los términos de la pregunta en `docs/wiki/` (incluye sinónimos de negocio:
   «ubicar» / «ubicación» / «hueco»; «pedido» / «orden»).
3. Lee las páginas relevantes enteras, no solo la línea encontrada.

### 2. Responder

- Primero la respuesta directa, después el detalle.
- Cada dato lleva la página y la sección de donde sale:
  `(ver [Recepción de mercancía › Reglas](procesos/recepcion.md))`.
- Si la página trae la cita al código, cópiala también: así se puede comprobar.
- Si dos páginas dicen cosas distintas, dilo y cita ambas.

### 3. Valorar el manual

Termina siempre con:

```
**Cobertura**: completa | parcial | no cubierta
**Páginas consultadas**: <lista>
**Qué falta en la wiki**: <dato o caso concreto que habría hecho falta>
**Problemas para un buscador**: <secciones que solo se entienden leyendo otra, términos
distintos para lo mismo, pantallazos sin descripción…>
```

### 4. Contrastar con el código (solo con `--contrastar`)

Después de responder **solo con la wiki**, abre las citas al código de las páginas usadas y
comprueba si la respuesta es correcta. Añade:

```
**Contraste con el código**: correcta | incompleta | incorrecta
<qué dice el código que la wiki no dice, con ruta:línea>
```

Esto separa dos fallos distintos: la wiki no tiene el dato (falta documentar) o la wiki lo
tiene mal (hay que corregir la página y pasar `/documentacion:wiki-lint`).

## Para preparar una batería de pruebas

Pide a soporte 10–20 preguntas reales de incidencias («¿por qué un palé se queda en
muelle sin ubicar?») y lánzalas una a una. El porcentaje con cobertura completa es una buena
medida de si el manual está listo para un asistente.

## Anti-patrones

- Leer código sin `--contrastar`, o antes de haber respondido solo con la wiki.
- Rellenar huecos con conocimiento general o con «lo normal en un WMS».
- Citar una página que no has leído.
- Dar cobertura «completa» a una respuesta que necesita suponer algo.
