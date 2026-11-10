# documentacion

Plugin de Claude Code para documentar el código **por procesos de negocio**, con cada
afirmación citada a `fichero:línea`.

## Skills

| Comando | Qué hace |
|---|---|
| `/documentacion:wiki-codigo <proceso> [carpeta]` | Escribe o actualiza la página del proceso en `docs/wiki/procesos/`, con índice y registro |
| `/documentacion:wiki-lint [página] [--fix]` | Revisa la wiki contra el código: citas, afirmaciones sin fuente, contradicciones, RAG-readiness |
| `/documentacion:wiki-query <pregunta> [--contrastar]` | Responde solo con la wiki, como lo haría un asistente, y valora la cobertura |
| `/documentacion:mapa-repo [carpeta]` | Mapa del repo con un script de Python: carpetas, lenguajes, tamaño y pistas de personalización. Para decidir por dónde empezar |
| `/documentacion:exportar-manual [páginas] [--pdf] [--con-citas]` | Exporta la wiki a Word (y PDF si hay Word) en el orden del índice. Requiere pandoc |
| `/documentacion:onboarding-procesos [proceso]` | Visita guiada al repositorio por procesos de negocio |

Claude también las activa solas si pides algo como «documenta el proceso de picking».

## Requisitos

| Para | Hace falta | Cómo se instala (Windows, sin administrador) |
|---|---|---|
| `exportar-manual` | [pandoc](https://pandoc.org) | `winget install --id JohnMacFarlane.Pandoc -e` y abrir una terminal nueva |
| `exportar-manual --pdf` | Microsoft Word | Sin Word sale el `.docx`, pero el PDF se guarda a mano y el índice se actualiza al abrirlo |
| `mapa-repo` | [uv](https://docs.astral.sh/uv/) (o Python 3.9+) | `winget install --id astral-sh.uv -e` |

## Exportar la wiki a Word

```
/documentacion:exportar-manual                          # todo el índice, sin citas
/documentacion:exportar-manual recepcion,expedicion     # solo esas páginas
/documentacion:exportar-manual --pdf                    # también PDF (necesita Word)
/documentacion:exportar-manual --con-citas              # con las citas, para desarrolladores
/documentacion:exportar-manual --titulo "Manual técnico · Almacén"
```

Sale en `docs/manual/manual-AAAA-MM-DD.docx` (y `.pdf`). Lo hace un script con pandoc: Claude
no lee las páginas y no gasta contexto.

- Toma las páginas en el orden en que las enlaza `docs/wiki/index.md`
- Portada con título y fecha, índice y un capítulo por página, cada uno en página nueva
- Quita las citas `(fichero:línea)`, la columna «Fuente» de las tablas y deja los enlaces
  entre páginas como texto
- `> [!warning] Revisar` pasa a «**Aviso: Revisar**»; los diagramas Mermaid quedan como texto
  con un aviso
- Avisa de las páginas en borrador y de las que el índice enlaza pero no existen (las
  marcadas como «pendiente» solo se cuentan)
- Con Word, actualiza el índice del documento y saca el PDF

**Plantilla corporativa.** Si existe `docs/wiki/plantilla-manual.docx`, se usan sus estilos.
Para crearla:

```powershell
pandoc -o docs/wiki/plantilla-manual.docx --print-default-data-file reference.docx
```

Abrirla en Word y cambiar **solo los estilos** (Título, Título 1, Título 2, Normal) y el
encabezado o pie con el logotipo. Su contenido no sale en el manual.

**La wiki es la fuente.** El Word se regenera cada vez: si algo está mal, se corrige la página
y se vuelve a exportar. Editar el `.docx` a mano se pierde en la siguiente exportación.

**Si falla:**
- «pandoc no está instalado»: instalarlo (arriba) y abrir una terminal nueva
- «la ejecución de scripts está deshabilitada»: la skill exporta con pandoc directamente, sin
  PDF ni índice actualizado
- Pide aprobación para ejecutar el script: es normal la primera vez si la ruta del plugin
  tiene algo raro; se puede aprobar

## Cambios

Ver [CHANGELOG.md](../../CHANGELOG.md) en la raíz del repositorio.
