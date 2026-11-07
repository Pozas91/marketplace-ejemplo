---
name: exportar-manual
description: Exporta la wiki de docs/wiki a un manual en Word (y PDF si hay Word instalado) con portada, índice y un capítulo por página, en el orden del índice. Usar cuando se pida el manual en Word o PDF, "sacar el documento" o entregar la wiki a alguien que no la lee en Markdown.
argument-hint: "[páginas…] [--pdf] [--con-citas] [--titulo \"…\"] [--nombre …] [--wiki ruta]"
allowed-tools: Read, Glob, Bash(powershell -NoProfile -ExecutionPolicy Bypass -File ${CLAUDE_SKILL_DIR}/scripts/exportar-manual.ps1 *)
---

# Exportar la wiki a un manual en Word

Exportar: $ARGUMENTS

La wiki en Markdown es **la fuente**. El Word es una salida que se regenera cada vez: no se
edita a mano, porque se pierde en la siguiente exportación. Si algo está mal en el Word, se
corrige en la página de la wiki y se vuelve a exportar.

Todo el trabajo lo hace [scripts/exportar-manual.ps1](scripts/exportar-manual.ps1) con
pandoc y el filtro [scripts/manual.lua](scripts/manual.lua). Tú solo traduces la petición a
parámetros, lanzas el script y resumes el resultado. **No leas las páginas de la wiki** para
exportarlas: el script ya lo hace y así no se gasta contexto.

## 1. Comprobar la wiki

- Por defecto la wiki está en `docs/wiki/` y su índice en `docs/wiki/index.md`. Si no
  existe, busca con Glob otro `index.md` de wiki y pregunta cuál usar antes de seguir.
- El orden del manual es el orden de los enlaces del índice. Las páginas `index.md`,
  `log.md` y `alcance.md` no se exportan.

## 2. Traducir la petición a parámetros

| Petición | Parámetro |
|---|---|
| Unas páginas concretas (nombre del fichero sin `.md`) | `-Paginas recepcion,expedicion` |
| «También en PDF» | `-Pdf` |
| Manual para desarrolladores, con las citas al código | `-ConCitas` |
| Título de la portada | `-Titulo "Manual técnico · Almacén"` |
| Nombre del fichero | `-Nombre manual-almacen` (por defecto, `manual-AAAA-MM-DD`) |
| Otra carpeta de wiki o de salida | `-Wiki <ruta>` · `-Salida <ruta>` (por defecto, `docs/manual`) |
| Plantilla de Word concreta | `-Plantilla <ruta.docx>` |

Por defecto las citas `(fichero:línea)` se quitan: el manual lo lee gente que no abre el
código. Si no se indica título, usa `Manual técnico`.

## 3. Lanzar el script

Desde la raíz del repositorio, exactamente con esta forma:

```
powershell -NoProfile -ExecutionPolicy Bypass -File ${CLAUDE_SKILL_DIR}/scripts/exportar-manual.ps1 <parámetros>
```

Si falla porque no encuentra pandoc, **no lo instales tú**: dile al usuario que ejecute
`winget install --id JohnMacFarlane.Pandoc -e`, que abra una terminal nueva y vuelva a
lanzar la skill.

## 4. Resumir al usuario

A partir de la salida del script:
- ruta del `.docx` (y del `.pdf`, si lo hay)
- número de páginas exportadas
- **páginas en borrador**: si hay, avisa de que el manual incluye contenido que nadie ha
  validado todavía y nómbralas
- páginas que el índice enlaza pero no existen
- si las citas van incluidas o quitadas, y qué plantilla se ha usado
- si Word no estaba disponible: el índice del documento se actualiza al abrirlo (Word pide
  actualizar campos) y el PDF hay que guardarlo a mano

## Plantilla corporativa

Si existe `docs/wiki/plantilla-manual.docx`, se usa sola. Para crearla:

```
pandoc -o docs/wiki/plantilla-manual.docx --print-default-data-file reference.docx
```

Después se abre en Word y se cambian **solo los estilos** (Título, Título 1, Título 2,
Normal, encabezado y pie, logotipo en el encabezado). El contenido de la plantilla no sale en
el manual.

## Qué hace el filtro con cada cosa

- Citas al código: fuera, salvo `-ConCitas`
- Enlaces entre páginas de la wiki: pasan a texto normal
- Un salto de página antes de cada capítulo
- `> [!warning] Revisar` pasa a «**Aviso: Revisar**» con el texto debajo
- Diagramas Mermaid: se dejan como texto con un aviso de que la versión gráfica está en la
  wiki

## Anti-patrones

- Editar el `.docx` generado en lugar de la wiki
- Leer o resumir las páginas por tu cuenta en vez de lanzar el script
- Entregar como definitivo un manual con páginas en borrador sin decirlo
- Instalar pandoc u otras herramientas sin que el usuario lo pida
