---
name: mermaid
description: Crea diagramas Mermaid (flujo, secuencia, estados, entidad-relación, clases) a partir de una descripción o del código, y genera un visor HTML local para verlos en el navegador. Usar cuando se pida un diagrama, un esquema, "dibújame", "visualiza" o ver un diagrama Mermaid existente.
argument-hint: "<qué diagramar> [flujo | secuencia | estados | er | clases]"
allowed-tools: Read, Write, Glob, Grep
---

# Diagramas Mermaid

Diagramar: $ARGUMENTS

## Qué es Mermaid

Mermaid describe diagramas como texto. Ese texto se versiona con el código, se revisa en
un diff y lo dibujan GitHub, GitLab, VS Code (extensión «Markdown Preview Mermaid
Support») y el visor HTML que genera esta skill.

## Proceso

### 1. Entender qué hay que dibujar

- Si `$ARGUMENTS` apunta a código (un proceso, un módulo, una tabla), léelo antes de
  dibujar. Nunca deduzcas por los nombres.
- Si es una descripción («el flujo de aprobación de pedidos»), dibuja lo que se describe y
  pregunta solo si falta algo imprescindible.
- Si te pasan un `.md` o `.mmd` que ya tiene un diagrama, sáltate al paso 4 y solo genera el visor.

### 2. Elegir el tipo

| Tipo | Cuándo | Cabecera |
|---|---|---|
| Flujo | Pasos y decisiones de un proceso | `flowchart TD` |
| Secuencia | Varios componentes o sistemas intercambiando mensajes | `sequenceDiagram` |
| Estados | Ciclo de vida de algo (pedido, palé, tarea) | `stateDiagram-v2` |
| Entidad-relación | Tablas y cómo se relacionan | `erDiagram` |
| Clases | Estructura de clases y dependencias | `classDiagram` |

Si el usuario indica el tipo, usa ese. La sintaxis de cada uno está en
[referencia.md](referencia.md): léela antes de escribir un tipo que no sea flujo.

### 3. Escribir el diagrama

- Máximo ~20 nodos. Si hay más, un diagrama general y otros de detalle.
- IDs simples (`P1`, `D1`) y textos entre comillas dobles: `P1["Leer albarán"]`.
- Nada de comillas dobles, corchetes ni llaves dentro de los textos.
- Textos en lenguaje de negocio, no nombres de funciones.
- Si sale del código, añade debajo una tabla `Nodo | Qué pasa | Fuente (fichero:línea)`.

### 4. Guardar y generar el visor

Escribe dos ficheros en `docs/diagramas/`:

1. **`<slug>.md`**: la fuente. Título, bloque ` ```mermaid `, y la tabla de fuentes si la hay.
   Es lo que se versiona.
2. **`<slug>.html`**: el visor. Copia [visor.html](visor.html) sustituyendo:
   - `{{TITULO}}` por el título del diagrama
   - `{{DIAGRAMA}}` por el código Mermaid (sin las comillas ` ``` `)

### 5. Abrir el visor

Ofrece abrirlo en el navegador con el comando del sistema:

- Windows: `start "" "docs/diagramas/<slug>.html"` (PowerShell: `Start-Process`)
- macOS: `open docs/diagramas/<slug>.html`
- Linux: `xdg-open docs/diagramas/<slug>.html`

El visor descarga la librería Mermaid de internet, pero **el diagrama se dibuja en el
navegador y no sale del equipo**. Si hay un error de sintaxis, el visor lo muestra: corrige
el `.md` y el `.html` y vuelve a abrir.

### 6. Resumen al usuario

- Rutas del `.md` y del `.html`
- Tipo de diagrama y número de nodos
- Qué se ha dejado fuera, si algo

## Exportar a imagen (opcional)

Si piden SVG o PNG para un documento: el visor tiene un botón «Descargar SVG». Con Node
instalado también vale `npx -y @mermaid-js/mermaid-cli -i <fichero>.mmd -o <fichero>.svg`
(la primera vez descarga un navegador; tarda).

## Confidencialidad

No pegues diagramas de código interno en editores web públicos (mermaid.live y similares).
Usa el visor local, VS Code o el GitLab/GitHub de la empresa.
