---
name: grill-me
description: Entrevista por rondas para poner a prueba un plan, una decisión o el alcance de un trabajo antes de empezar, con árbol de decisiones y respuesta recomendada en cada pregunta. Usar cuando se pida "grill me", "acribíllame a preguntas", "pon a prueba este plan" o acotar el alcance de un manual.
argument-hint: "<plan, decisión o alcance a poner a prueba>"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Agent
---

# Grill me

Entrevístame sin descanso sobre: $ARGUMENTS, hasta que tengamos un entendimiento compartido.

Basado en [`grilling`](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling)
de Matt Pocock.

## Árbol de decisiones

Organiza el tema como un **árbol**: cada decisión se ramifica en las que dependen de ella.

La **frontera** son las decisiones cuyos requisitos previos ya están resueltos: las que se
pueden preguntar _ahora_ sin suponer respuestas que todavía no has oído.

## Rondas

En cada ronda pregunta **toda la frontera**: numera las preguntas y da tu respuesta
recomendada. Después espera mis respuestas.

```
❓ **P1 · <título>**: <pregunta; puede incluir opciones>

➡️ <tu recomendación>

---

❓ **P2 · <título>**: <pregunta>

➡️ <tu recomendación>
```

- Redacta cada pregunta para que «sí» acepte tu recomendación.
- Si una pregunta depende de otra todavía abierta, va a una ronda posterior.
- Tras cada ronda, recalcula la frontera y lanza la siguiente.
- Si una respuesta invalida otra anterior, reabre esa rama en la siguiente ronda.

## Hechos y decisiones

- **Los hechos son tu trabajo.** Si una pregunta necesita un dato del código o de los
  ficheros, búscalo tú (Read, Grep, Glob) o lanza un subagente con `Agent`. No me preguntes
  nada que puedas averiguar leyendo.
- No bloquees la ronda por una búsqueda: solo esperan las preguntas que dependen de ella.
- **Las decisiones son mías.** Nunca respondas tú tus propias preguntas de decisión.

## Uso típico en documentación

- **Acotar un manual** antes de escribirlo: `/revision:grill-me manual AutoStore del cliente X`.
  Ramas habituales: qué procesos entran y cuáles no, nivel de detalle, quién es el lector
  (soporte, consultoría, asistente de IA), qué cuenta como personalización, quién valida y
  cómo, dónde se guarda.
- **Sacar lo que solo sabe una persona**: `/revision:grill-me personalización de picking del cliente X`
  con el desarrollador que la hizo delante. Lee tú el código primero y pregunta solo lo que
  el código no explica: el porqué de una regla, casos que no están en el código, historia.

## Final

La entrevista termina cuando la frontera queda vacía: todas las ramas visitadas, nada
supuesto en silencio. Resume las decisiones en una lista numerada y **no hagas nada** hasta
que confirme que estamos de acuerdo. Si lo pido, guarda el resumen en un fichero (escribir
no está en `allowed-tools`: Claude Code pedirá permiso).
