# Scanner Obleas GNC

Contribuí al monitoreo del mercado GNC de Argentina desde tu Raspberry Pi con Home Assistant.

## ¿Qué hace?

Tu Raspberry Pi escanea obleas GNC de ENARGAS en segundo plano, contribuyendo datos al sistema de monitoreo del mercado nacional de gas natural comprimido.

## Instalación

1. En Home Assistant, ir a **Settings → Add-ons → Add-on Store**
2. Hacer click en los tres puntos (⋮) → **Repositories**
3. Pegar la URL del repositorio y confirmar
4. Buscar **"Scanner Obleas GNC"** e instalar
5. Ir a la pestaña **Configuration** y escribir tu nombre (o un apodo)
6. Hacer click en **Start**

## Configuración

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `nombre` | Identificador de tu Raspberry | `pedro`, `garage`, `taller` |

Usá cualquier nombre — queda registrado para identificar tu nodo en el sistema.

## ¿Qué hace exactamente?

- Escanea obleas GNC consultando el sistema de ENARGAS
- Guarda los datos en una base de datos central
- Corre en segundo plano sin afectar el rendimiento de tu HA
- Se actualiza automáticamente cada vez que reiniciás el add-on

## ¿Consume muchos recursos?

No. El scanner usa menos de 50 MB de RAM y prácticamente nada de CPU entre consultas.

## Logs

Podés ver la actividad en tiempo real desde la pestaña **Log** del add-on.
