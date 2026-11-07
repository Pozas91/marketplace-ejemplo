# Changelog

Cada versión sube `version` en `plugins/<plugin>/.claude-plugin/plugin.json`.
Sin subir la versión, quien ya tenga el plugin instalado **no recibe los cambios**.

## 2026-11-07
- `documentacion` 0.2.0: `exportar-manual` exporta la wiki a Word (y PDF si hay Word) con
  pandoc: portada, índice, un capítulo por página, citas quitadas y plantilla corporativa
  opcional. Requiere pandoc (`winget install --id JohnMacFarlane.Pandoc -e`).
  `wiki-codigo` también marca como personalización lo que cambia por instalación o parámetros
- `revision` 0.2.1: ejemplo genérico en `grill-me`; créditos y cómo desactivar el MCP en el README
- Fusionado con `claude-doc-skills`, que deja de existir: licencia MIT y `.gitignore`

## 2026-11-05 (2)
- `documentacion` 0.1.1: `wiki-codigo` y `onboarding-procesos` dicen «denegado, no leído»
  cuando un fichero está bloqueado por permisos, en lugar de afirmar que no existe

## 2026-11-05
- `revision` 0.2.0: `.mcp.json` con el servidor MCP de Microsoft Learn

## 2026-11-04
- `documentacion` 0.1.0: `wiki-codigo`, `wiki-lint`, `wiki-query`, `onboarding-procesos`
- `diagramas` 0.1.0: `mermaid`, `diagrama-flujo`
- `revision` 0.1.0: `grill-me`, `code-review`
