# MCP de ejemplo: festivos

Un MCP de unas 100 líneas para ver **qué es un MCP por dentro**: un programa que envuelve una
API y se la ofrece a Claude como herramientas.

| | |
|---|---|
| API que envuelve | [Nager.Date](https://date.nager.at): festivos por país y región. Pública, gratuita, sin clave |
| Herramientas | `festivos(anio, pais, region)` · `es_laborable(fecha, pais, region)` · `siguiente_laborable(fecha, pais, region)` |
| Lenguaje | Python, con el SDK oficial `mcp` (2.x) |
| Cómo corre | En tu máquina, por stdio: Claude Code lo arranca como proceso hijo |
| Requisito | [`uv`](https://docs.astral.sh/uv/): `winget install --id astral-sh.uv -e`. Instala Python y la librería `mcp` solo, la primera vez |
| Qué sale de tu máquina | Año y país (`GET /PublicHolidays/2026/ES`). Nada de tu código ni de tus datos |

## Qué hay en `servidor.py`

1. `MCPServer("festivos")`: el servidor y su nombre
2. Tres funciones con `@mcp.tool()`. **El nombre, el docstring y los parámetros son lo que
   Claude ve**: con eso decide cuándo llamar a cada una. Es la misma idea que la
   `description` de una skill
3. Dentro de cada función, una petición HTTP normal a la API
4. `mcp.run()`: queda esperando peticiones de Claude por stdio

Lo demás (protocolo, JSON-RPC, esquema de parámetros) lo pone el SDK.

## Conectarlo

Desde la raíz del repo donde se quiera usar:

```powershell
claude mcp add --scope project festivos -- uv run --script <ruta>/servidor.py
```

Crea `.mcp.json` en el repo (se sube a git y le llega al equipo; cada persona lo aprueba al
arrancar `claude`). Sin `--scope project`, queda solo para ti en ese repo.

Comprobar: `claude mcp list` o, dentro de Claude Code, `/mcp`.

## Probarlo

```
¿Es laborable el 8 de diciembre de 2026 en Madrid?
¿El alta de pedidos tiene en cuenta los festivos al calcular la fecha de preparación?
Mira el código y, con el MCP de festivos, dime qué pasaría con un pedido que entra el
7 de diciembre de 2026 después de la hora de corte en Madrid (ES-MD).
```

La segunda es la interesante: Claude lee el código, llama al MCP y cruza las dos cosas. En
`almacen-prueba` descubre que la fecha de preparación cae en festivo.

## De aquí a un MCP de verdad

Un MCP sobre vuestra herramienta de incidencias o sobre una API interna se hace igual:
cambiar la URL, añadir autenticación (con variables de entorno, nunca en el código ni en
`.mcp.json`) y escribir bien el docstring de cada herramienta. Antes de escribir uno, mirar
si ya existe: Jira, Azure DevOps, GitHub o SQL Server tienen MCP oficial.
