# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Mapa de un repositorio en Markdown: carpetas, lenguajes, tamaño, ficheros más grandes y
pistas de personalización por cliente. Solo usa la librería estándar.

Uso:  uv run --script mapa_repo.py [ruta] [--profundidad N] [--top N]
      python mapa_repo.py [ruta] ...   (si no hay uv)

Si la ruta es un repo git, usa `git ls-files` (respeta .gitignore y es rápido); si no,
recorre las carpetas saltando las de compilación y dependencias.
"""

import argparse
import os
import re
import subprocess
import sys
from collections import Counter, defaultdict
from pathlib import Path

# Carpetas que nunca son código propio (compilados, dependencias, IDE)
IGNORAR = {".git", "node_modules", "bin", "obj", ".vs", ".vscode", ".idea", "packages",
           "dist", "build", "target", "__pycache__", ".venv", "venv", ".claude"}
# Por encima de 2 MB casi siempre es un binario o un volcado: no se cuentan sus líneas
MAX_BYTES_LINEAS = 2 * 1024 * 1024
# Nombres de carpeta que suelen indicar código o configuración por cliente. Se comparan
# trozos enteros del nombre (separados por . _ -): "Clientes" o "Custom" sí, pero
# "Customers" (clientes como dato de negocio) o "ClientSide" no
PISTAS = re.compile(
    r"^(clientes?|clients?|custom|customs|customi[sz]ations?|personaliza\w*|overrides?|"
    r"especific\w*|instalacion(es)?|tenants?|proyectos?)$", re.I)

LENGUAJE = {
    ".cs": "C#", ".vb": "VB.NET", ".java": "Java", ".kt": "Kotlin", ".py": "Python",
    ".js": "JavaScript", ".ts": "TypeScript", ".tsx": "TypeScript", ".jsx": "JavaScript",
    ".sql": "SQL", ".xml": "XML", ".json": "JSON", ".yaml": "YAML", ".yml": "YAML",
    ".config": "Config", ".csproj": "Proyecto .NET", ".sln": "Solución .NET",
    ".cshtml": "Razor", ".razor": "Razor", ".aspx": "ASP.NET", ".html": "HTML", ".css": "CSS",
    ".scss": "CSS", ".md": "Markdown", ".ps1": "PowerShell", ".sh": "Shell", ".go": "Go",
    ".php": "PHP", ".rb": "Ruby", ".cpp": "C++", ".c": "C", ".h": "C/C++", ".pas": "Pascal",
    ".frm": "Formularios", ".rpt": "Informes", ".resx": "Recursos .NET",
}


def listar(raiz: Path) -> list[Path]:
    try:
        salida = subprocess.run(["git", "-C", str(raiz), "ls-files", "-z"], capture_output=True,
                                check=True).stdout.decode("utf-8", "replace")
        ficheros = [raiz / f for f in salida.split("\0") if f]
        if ficheros:
            return [f for f in ficheros if not (set(f.relative_to(raiz).parts) & IGNORAR)]
    except (OSError, subprocess.CalledProcessError):
        pass  # sin git o no es un repo: se recorre a mano
    ficheros = []
    for carpeta, subcarpetas, nombres in os.walk(raiz):
        subcarpetas[:] = [d for d in subcarpetas if d not in IGNORAR]
        ficheros.extend(Path(carpeta) / n for n in nombres)
    return ficheros


def lineas(f: Path) -> int:
    try:
        if f.stat().st_size > MAX_BYTES_LINEAS:
            return 0
        with open(f, "rb") as h:
            datos = h.read()
        if b"\0" in datos[:8000]:  # binario
            return 0
        return datos.count(b"\n") + (1 if datos and not datos.endswith(b"\n") else 0)
    except OSError:
        return 0


def miles(n: int) -> str:
    return f"{n:,}".replace(",", ".")


def tabla(cabecera: list[str], filas: list[list]) -> str:
    out = ["| " + " | ".join(cabecera) + " |", "|" + "---|" * len(cabecera)]
    out += ["| " + " | ".join(miles(c) if isinstance(c, int) else str(c) for c in fila) + " |"
            for fila in filas]
    return "\n".join(out)


def main() -> int:
    # En Windows la consola no es UTF-8: sin esto, las tildes le llegan rotas a Claude
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("ruta", nargs="?", default=".")
    ap.add_argument("--profundidad", type=int, default=2, help="niveles de carpeta (defecto 2)")
    ap.add_argument("--top", type=int, default=15, help="filas por tabla (defecto 15)")
    args = ap.parse_args()

    raiz = Path(args.ruta).resolve()
    if not raiz.is_dir():
        print(f"ERROR: no existe la carpeta {raiz}", file=sys.stderr)
        return 1

    ficheros = [f for f in listar(raiz) if f.is_file()]
    if not ficheros:
        print(f"ERROR: no hay ficheros en {raiz}", file=sys.stderr)
        return 1

    por_ext, lin_ext = Counter(), Counter()
    por_carpeta, lin_carpeta = Counter(), Counter()
    ext_carpeta: dict[str, Counter] = defaultdict(Counter)
    tamanos, pistas = [], Counter()
    total_lineas = 0

    for f in ficheros:
        rel = f.relative_to(raiz)
        ext = f.suffix.lower() or "(sin extensión)"
        n = lineas(f)
        total_lineas += n
        por_ext[ext] += 1
        lin_ext[ext] += n
        carpeta = "/".join(rel.parts[:-1][: args.profundidad]) or "(raíz)"
        por_carpeta[carpeta] += 1
        lin_carpeta[carpeta] += n
        ext_carpeta[carpeta][ext] += 1
        tamanos.append((n, rel.as_posix()))
        # La pista se busca en las carpetas, no en el nombre del fichero
        for i, parte in enumerate(rel.parts[:-1]):
            if any(PISTAS.match(t) for t in re.split(r"[._\-\s]+", parte) if t):
                pistas["/".join(rel.parts[: i + 1])] += 1
                break

    print(f"# Mapa de `{raiz.name}`\n")
    print(f"- **{miles(len(ficheros))}** ficheros, **{miles(total_lineas)}** líneas de texto")
    lenguajes = Counter()
    for ext, n in por_ext.items():
        if ext in LENGUAJE:
            lenguajes[LENGUAJE[ext]] += lin_ext[ext]
    if lenguajes:
        print("- Lenguajes por líneas: " + ", ".join(f"{l} ({miles(n)})"
                                                   for l, n in lenguajes.most_common(6)))
    print()

    print(f"## Carpetas (hasta {args.profundidad} niveles)\n")
    filas = []
    for c, n in por_carpeta.most_common(args.top):
        principales = ", ".join(e for e, _ in ext_carpeta[c].most_common(3))
        filas.append([f"`{c}`", n, lin_carpeta[c], principales])
    print(tabla(["Carpeta", "Ficheros", "Líneas", "Extensiones"], filas))
    if len(por_carpeta) > args.top:
        print(f"\n…y {len(por_carpeta) - args.top} carpetas más.")
    print()

    print("## Extensiones\n")
    print(tabla(["Extensión", "Ficheros", "Líneas"],
                [[f"`{e}`", n, lin_ext[e]] for e, n in por_ext.most_common(args.top)]))
    print()

    print("## Ficheros más grandes\n")
    print(tabla(["Fichero", "Líneas"],
                [[f"`{r}`", n] for n, r in sorted(tamanos, reverse=True)[: min(10, args.top)]]))
    print()

    print("## Pistas de personalización\n")
    if pistas:
        print("Carpetas cuyo nombre sugiere código por cliente o configuración (revisar a mano):\n")
        print(tabla(["Carpeta", "Ficheros"], [[f"`{c}`", n] for c, n in pistas.most_common(args.top)]))
    else:
        print("Ninguna carpeta con nombres como cliente, custom, personalización u override. "
              "La personalización puede estar en configuración, ramas o `if` dentro del código.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
