# /// script
# requires-python = ">=3.10"
# dependencies = ["mcp>=2.3,<3"]
# ///
"""MCP de ejemplo: envuelve la API pública de festivos de Nager.Date.

Un MCP no es más que esto: un programa que le dice a Claude qué herramientas tiene
(nombre, descripción y parámetros) y que, cuando Claude llama a una, hace el trabajo
(aquí, una petición HTTP a una API) y le devuelve el resultado.

API: https://date.nager.at (pública, gratuita, sin clave). Solo se le envía año y país.

Arranque (lo hace Claude Code, no tú):  uv run --script servidor.py
"""

import json
import urllib.request
from datetime import date, timedelta

from mcp.server.mcpserver import MCPServer

API = "https://date.nager.at/api/v3/PublicHolidays/{anio}/{pais}"
# La API responde en menos de un segundo; 10 s deja margen a una red lenta
TIMEOUT_S = 10
# Más de 60 días seguidos sin día laborable no ocurre en ningún calendario real
MAX_DIAS_BUSQUEDA = 60

mcp = MCPServer("festivos")
_cache: dict[tuple[int, str], list[dict]] = {}


def _festivos(anio: int, pais: str) -> list[dict]:
    """Descarga (una vez por año y país) la lista de festivos de la API."""
    clave = (anio, pais.upper())
    if clave not in _cache:
        url = API.format(anio=anio, pais=pais.upper())
        try:
            with urllib.request.urlopen(url, timeout=TIMEOUT_S) as r:
                _cache[clave] = json.loads(r.read().decode("utf-8"))
        except Exception as e:  # sin red, país inexistente, API caída…
            raise RuntimeError(f"No se pudo consultar {url}: {e}") from e
    return _cache[clave]


def _aplica(festivo: dict, region: str | None) -> bool:
    """Un festivo aplica si es nacional o si es de la región pedida (p. ej. ES-MD)."""
    if festivo.get("global"):
        return True
    return region is not None and region.upper() in (festivo.get("counties") or [])


def _motivo_no_laborable(dia: date, pais: str, region: str | None) -> str | None:
    if dia.weekday() >= 5:
        return "sábado" if dia.weekday() == 5 else "domingo"
    for f in _festivos(dia.year, pais):
        if f["date"] == dia.isoformat() and _aplica(f, region):
            return f"festivo: {f['localName']}"
    return None


@mcp.tool()
def festivos(anio: int, pais: str = "ES", region: str | None = None) -> list[dict]:
    """Lista los festivos de un año en un país (código ISO, p. ej. ES, PT, FR).

    Con `region` (código ISO de la comunidad, p. ej. ES-MD, ES-CT, ES-PV) incluye también
    los autonómicos de esa región; sin ella, solo los nacionales.
    """
    return [
        {"fecha": f["date"], "nombre": f["localName"],
         "ambito": "nacional" if f.get("global") else ", ".join(f.get("counties") or [])}
        for f in _festivos(anio, pais)
        if _aplica(f, region)
    ]


@mcp.tool()
def es_laborable(fecha: str, pais: str = "ES", region: str | None = None) -> dict:
    """Dice si una fecha (AAAA-MM-DD) es día laborable y, si no lo es, por qué
    (fin de semana o el nombre del festivo)."""
    motivo = _motivo_no_laborable(date.fromisoformat(fecha), pais, region)
    return {"fecha": fecha, "laborable": motivo is None, "motivo": motivo}


@mcp.tool()
def siguiente_laborable(fecha: str, pais: str = "ES", region: str | None = None) -> dict:
    """Devuelve el primer día laborable posterior a una fecha (AAAA-MM-DD), saltando
    fines de semana y festivos. Útil para fechas de preparación o de entrega."""
    dia = date.fromisoformat(fecha)
    saltados = []
    for _ in range(MAX_DIAS_BUSQUEDA):
        dia += timedelta(days=1)
        motivo = _motivo_no_laborable(dia, pais, region)
        if motivo is None:
            return {"desde": fecha, "siguiente_laborable": dia.isoformat(), "saltados": saltados}
        saltados.append({"fecha": dia.isoformat(), "motivo": motivo})
    raise RuntimeError(f"No hay día laborable en los {MAX_DIAS_BUSQUEDA} días siguientes a {fecha}")


if __name__ == "__main__":
    mcp.run()  # por defecto, stdio: Claude Code lo arranca como proceso hijo
