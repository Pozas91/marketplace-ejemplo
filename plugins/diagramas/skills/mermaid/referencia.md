# Referencia rápida de Mermaid

## Flujo

```mermaid
flowchart TD
    P1["Llega el albarán"] --> D1{"¿Proveedor dado de alta?"}
    D1 -->|"no"| P2["Rechazar y avisar"]
    D1 -->|"sí"| P3["Crear líneas de recepción"]
    P3 --> P4(["Fin"])
```

- Dirección: `TD` (arriba-abajo) o `LR` (izquierda-derecha)
- Formas: `["rectángulo"]`, `{"decisión"}`, `(["inicio/fin"])`, `[("base de datos")]`
- Agrupar: `subgraph Recepcion["Recepción"] ... end`

## Secuencia

```mermaid
sequenceDiagram
    participant RF as Terminal RF
    participant WMS
    participant BD as Base de datos
    RF->>WMS: Lee etiqueta del palé
    WMS->>BD: Busca ubicación libre
    BD-->>WMS: Ubicación A-03-02
    alt Ubicación encontrada
        WMS-->>RF: Muestra ubicación
    else Sin hueco
        WMS-->>RF: Aviso de almacén lleno
    end
```

- `->>` llamada, `-->>` respuesta
- Bloques: `alt / else / end`, `opt ... end`, `loop ... end`
- Notas: `Note over WMS: texto`

## Estados

```mermaid
stateDiagram-v2
    [*] --> Pendiente
    Pendiente --> EnPreparacion: Se asigna operario
    EnPreparacion --> Preparado: Última línea completada
    EnPreparacion --> Incidencia: Falta stock
    Incidencia --> EnPreparacion: Stock repuesto
    Preparado --> Expedido
    Expedido --> [*]
```

- Nombres de estado sin espacios; texto libre después de `:` en las transiciones

## Entidad-relación

```mermaid
erDiagram
    PEDIDO ||--|{ LINEA_PEDIDO : contiene
    LINEA_PEDIDO }o--|| ARTICULO : referencia
    ARTICULO ||--o{ STOCK : "se guarda en"
    STOCK }o--|| UBICACION : ocupa
    PEDIDO {
        int id PK
        string cliente
        date fecha
    }
```

- Cardinalidad: `||` uno, `o|` cero o uno, `}|` uno o más, `}o` cero o más

## Clases

```mermaid
classDiagram
    class Pedido {
        +int id
        +List~Linea~ lineas
        +confirmar()
    }
    Pedido "1" --> "*" Linea : contiene
    ServicioPedidos ..> Pedido : usa
```

- `-->` asociación, `..>` dependencia, `<|--` herencia, `*--` composición

## Errores frecuentes

- Comillas, corchetes o paréntesis dentro de un texto sin comillas → envolver en `"..."`
- La palabra `end` en minúsculas como texto de un nodo rompe el diagrama → `"Fin"` o `End`
- Tildes y eñes: funcionan dentro de comillas; en IDs, mejor evitarlas
