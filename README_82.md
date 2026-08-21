# Prototipo 82 — Corrección fina de escalas y cinemática

Cambios clave:
- Se eliminó prácticamente todo crecimiento visual en combo automático.
- Recarga, especial, rematador y absoluto quedan al mismo tamaño corporal base, con variación mínima.
- Las poses de recibir golpes quedaron mucho más cerradas para evitar que un frame salga grande y otro chico.
- El póster grande ahora se escala por **área visible real** del PNG, no por el lienzo completo.
- El póster también usa menor altura, menos pulso y menos opacidad.
- Durante rematador y absoluto, el rival permanece congelado mientras corre la parte de póster/cinemática, evitando que se recupere mientras el otro sigue en modo póster.

Objetivo visual:
- combate más parejo,
- menos sensación de recortes,
- menos invasión de pantalla por recargas/posters,
- más limpieza cinematográfica.
