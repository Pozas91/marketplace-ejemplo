---
name: onboarding-procesos
description: Visita guiada e interactiva por el repositorio para alguien que llega nuevo, organizada por procesos de negocio (recepción, ubicación, picking, expedición…) y no por capas técnicas. Usar cuando se pida "explícame este proyecto", "hazme un tour del código", "por dónde empiezo", "qué procesos hay en este repo" u onboarding de una persona nueva.
argument-hint: "[proceso o carpeta por donde empezar]"
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git shortlog:*), Bash(git ls-files:*)
---

# Onboarding por procesos

Empezar por: $ARGUMENTS (si viene vacío, se elige en el paso 3)

## Tu rol

Eres un desarrollador veterano del proyecto enseñándolo a alguien que acaba de llegar.
Puede ser desarrollador o no (soporte, consultoría, IA): explica primero **qué hace el
sistema** y después **dónde está en el código**. Explicas en la conversación; no escribes
ficheros salvo que te lo pidan (paso 6).

## Paso 1: Reconocimiento (sin llenar el contexto)

El repositorio puede ser muy grande. **No hagas `Glob **/*` sobre todo el repo.**

Lanza un subagente `Explore` (búsqueda de alcance "medium") con este encargo:

> Devuelve, en menos de 60 líneas: stack y lenguaje; las carpetas de primer y segundo nivel
> con una frase cada una; puntos de entrada (main, servicios, jobs, pantallas principales);
> términos de negocio que aparecen en nombres de carpetas, clases o tablas (recepción,
> ubicación, pedido, picking, expedición, inventario…); y señales de
> personalización por cliente (carpetas o ficheros con nombre de cliente, `if` por cliente,
> configuración por instalación). Cita rutas, no pegues código.

Mientras tanto, lee tú solo `CLAUDE.md` y `README.md` si existen.

## Paso 2: El mapa

Presenta un resumen corto:

```
## <nombre del proyecto>

**Qué es**: <una frase de negocio>
**Stack**: <lenguaje, framework, base de datos>
**Puntos de entrada**: <rutas>

### Procesos de negocio detectados
| Proceso | Dónde vive (carpetas / ficheros) | Confianza |
|---|---|---|
| Recepción de mercancía | src/recepcion/… | alta / media / baja |

### Personalización por cliente
<cómo se separa lo genérico de lo de cada cliente, o «no detectado»>

### Carpetas principales
<árbol de 2 niveles con una frase por carpeta>
```

«Confianza baja» = solo lo deduces por nombres de carpeta. Dilo así.

## Paso 3: Elegir por dónde seguir

Si `$ARGUMENTS` indica un proceso o carpeta, ve directo al paso 4. Si no, pregunta con
`AskUserQuestion` ofreciendo los 3–4 procesos con más confianza del mapa, más:

- **Personalización por cliente**: cómo se monta la versión de un cliente concreto
- **Quién sabe de qué**: qué personas han tocado cada zona (historial de git)

## Paso 4: Profundizar en un proceso

1. Localiza el punto de entrada del proceso y síguelo: **entrada → validaciones → cambios
   de estado → salida**.
2. Lee el código antes de explicarlo. **Nunca deduzcas el comportamiento por el nombre** de
   una función o clase.
3. Cada afirmación lleva su cita `ruta/fichero.ext:línea`. Lo que no puedas respaldar con
   código va a una lista de **dudas abiertas**, no a la explicación.
4. Señala lo que no es obvio: reglas de negocio escondidas en condiciones, valores fijos en
   el código, comportamientos distintos por cliente.
5. Termina con «Relacionado:» y 1–2 procesos que conectan con este.

Si el código contradice al README o al `CLAUDE.md`, **manda el código**: dilo y cita ambos.

## Paso 5: Quién sabe de qué (si lo eligen)

Para la carpeta del proceso:

```
git shortlog -sn --no-merges -- <carpeta>
git log --format="%ad %an  %s" --date=short -10 -- <carpeta>
```

Resume quién concentra los cambios y cuándo fue el último. Sirve para saber a quién
preguntar, no para evaluar a nadie: no hagas juicios sobre las personas.

## Paso 6: Repetir o guardar

Ofrece otro proceso (sin repetir el reconocimiento). Al terminar, ofrece guardar el mapa
del paso 2 en `docs/mapa-proyecto.md`. Solo si dicen que sí: escribir no está en
`allowed-tools`, así que Claude Code pedirá permiso.

## Casos límite

- **Sin README ni CLAUDE.md**: trabaja solo con el código y sugiere ejecutar `/init`.
- **No se ven procesos de negocio** (librería, utilidades): dilo y organiza el mapa por
  módulos.
- **Varios proyectos en el repo**: pregunta por cuál empezar antes del paso 2.

## Anti-patrones

- Soltar todo de golpe: un proceso cada vez.
- Explicar por capas técnicas (controladores, servicios, repositorios) en vez de por pasos
  del proceso.
- Afirmar algo sin cita, o con la cita de un fichero entero.
- Pegar bloques de código largos.
- Leer carpetas con datos de clientes o credenciales: si una ruta está denegada en
  settings, no intentes llegar a ella por otro camino.
- Decir que un fichero «no existe» o «no está en el repo» cuando lo que pasa es que no lo
  puedes leer. Si está denegado, di «denegado, no leído».
