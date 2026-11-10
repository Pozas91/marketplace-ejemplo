---
name: mapa-repo
description: Genera un mapa del repositorio con un script de Python, sin leer los ficheros uno a uno - carpetas, lenguajes, tamaño en ficheros y líneas, ficheros más grandes y carpetas que parecen personalizaciones por cliente. Usar antes de documentar un repo grande, para decidir por dónde empezar o qué carpeta pasarle a wiki-codigo, o cuando se pregunte "qué hay en este repo", "cuánto código hay" o "dónde están las personalizaciones".
argument-hint: "[carpeta] [--profundidad N]"
allowed-tools: Bash(uv run --script ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py *), Bash(uv run --script "${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py" *), Bash(python ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py *), Bash(python "${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py" *), PowerShell(uv run --script ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py *), PowerShell(python ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py *)
---

# Mapa del repositorio

Mapa de: $ARGUMENTS

El recuento lo hace [scripts/mapa_repo.py](scripts/mapa_repo.py), no tú: recorre miles de
ficheros en segundos y te devuelve un resumen de unas pocas tablas. **No leas ni listes los
ficheros por tu cuenta** (ni Glob ni Read sobre el repo): gastarías el contexto en lo que el
script ya hace.

## 1. Lanzar el script

Desde la raíz del repositorio, **siempre con la ruta** (aunque sea `.`) y exactamente así:

```
uv run --script ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py <carpeta o .> [--profundidad N]
```

- Si la ruta del script tiene espacios, la misma forma con la ruta entre comillas dobles
- Sin `uv`: `python ${CLAUDE_SKILL_DIR}/scripts/mapa_repo.py <carpeta o .>` (solo usa la
  librería estándar). Si tampoco hay Python, dile al usuario que instale `uv`
  (`winget install --id astral-sh.uv -e`); no lo instales tú
- `--profundidad 3` si el primer mapa agrupa demasiado (por defecto, 2 niveles)
- La primera vez en un repo recién clonado puede tardar más (el antivirus revisa los ficheros)

## 2. Resumir para documentar

Con la salida del script, en este orden y en pocas líneas:

1. **Tamaño y lenguajes**: total de ficheros y líneas, y el lenguaje principal
2. **Zonas del código**: las 3–6 carpetas que concentran el código propio y qué parecen ser
   por su nombre (dilo como hipótesis: «parece», no «es»)
3. **Personalizaciones**: las carpetas de la sección de pistas. Si no hay ninguna, dilo: la
   personalización estará en configuración, ramas o condiciones en el código, y habrá que
   preguntarlo (por ejemplo con `grill-me`)
4. **Por dónde empezar**: una carpeta concreta y pequeña para el primer
   `/documentacion:wiki-codigo <proceso> <carpeta>`, y por qué
5. **Lo que no es código propio** y conviene dejar fuera (scripts de migración, ficheros
   generados, recursos)

## Anti-patrones

- Listar o leer ficheros para «completar» el mapa: si falta algo, relanza con otra
  `--profundidad` o sobre una subcarpeta
- Afirmar qué hace una carpeta solo por su nombre
- Copiar las tablas enteras en la respuesta: el usuario quiere la lectura, no el volcado
