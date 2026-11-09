---
title: "<Nombre del proceso>"
proceso: <slug-del-proceso>
tipo: proceso            # proceso | subproceso
cliente: generico        # generico | <nombre-cliente>
instalacion: todas       # todas | <instalación concreta, si el cliente tiene varias>
tecnologia: []           # tipos de almacén a los que aplica (p. ej. [verticales]); [] si es común
version: desconocida     # versión del producto documentada; desconocida si no consta
modulos: []              # módulos o carpetas del código implicados
ficheros_fuente: []      # rutas leídas para escribir esta página
actualizado: AAAA-MM-DD
estado: borrador         # borrador | revisado
---

# <Nombre del proceso>

## Resumen
<2-3 frases: qué hace el proceso <nombre>, quién o qué lo dispara y qué resultado deja.>

## Disparadores y datos de entrada
- <Qué inicia el proceso <nombre>: acción de usuario, mensaje de otro sistema, tarea programada…> (fuente)

## Pasos
1. <Paso en lenguaje de negocio> (fuente)
2. <…> (fuente)

## Reglas y validaciones
- <Condición que el sistema comprueba y qué pasa si no se cumple> (fuente)

## Errores y casos excepcionales
- <Situación> → <comportamiento del sistema> (fuente)

## Datos que lee y escribe
| Dato / tabla | Lee | Escribe | Fuente |
|---|---|---|---|
| | | | |

## Puntos de personalización
<En el manual genérico: dónde se puede cambiar el comportamiento (método que un cliente
sobrescribe, parámetro de configuración) y qué clientes lo cambian, con enlace a su página.
NO lo que hace cada cliente: eso va en su página (cliente: <x>), para que no se mezcle.
En un manual de cliente: qué cambia respecto al genérico y por qué.>
- <…> (fuente)

## Procesos relacionados
- [<Proceso>](<slug>.md) — <relación: lo dispara, lo continúa, comparte datos…>

## Preguntas abiertas
- <Lo que no se ha podido confirmar en el código y hay que preguntar a un desarrollador>
