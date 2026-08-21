# Prototipo 83 — Normalización real de sprites + timing cinematográfico

Esta fase corrige de raíz el crecimiento/achicamiento entre PNGs.

## Cambios principales
- Escala **precalibrada para los 295 PNG actuales** de los 7 luchadores.
- La escala se calcula por masa alfa del arte respecto a `parado.png`, no por altura simple. Así una pose horizontal, una patada larga o un PNG de 1300 px no vuelve gigante al luchador.
- Recarga limitada a una presencia similar al cuerpo normal.
- Golpes recibidos calibrados individualmente para que el 1°, 2° y 3° impacto no cambien brutalmente de tamaño.
- Combo automático sin aumento de escala.
- Póster sin pulso de tamaño: solo pulsa luz/opacidad.
- Impactos de poderes ya no hacen reaccionar al rival mientras el póster sigue visible.
- En el rematador de carga 2: **póster -> desaparece -> rival sale despedido -> cae -> se levanta**.
- En el absoluto: **póster -> desaparece -> vuelo final -> caída definitiva**.
