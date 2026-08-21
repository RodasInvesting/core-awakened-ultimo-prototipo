# Prototipo 81 — Estabilidad visual y anti-bug

Objetivo de esta fase:
- Eliminar el cuelgue al recibir el segundo golpe fuerte / derribo especial.
- Emparejar mucho más el tamaño visual entre golpes, recibir golpes, recargas y combos.

Cambios principales:
- **Seguro anti-bug de aterrizaje especial**: si el luchador ya tocó el piso pero por timing no entró el frame exacto de aterrizaje, el sistema resuelve igual el derribo y evita que quede congelado en pose de impacto.
- **Tamaño mucho más parejo al recibir golpes**: las poses de daño ahora quedan dentro de un rango visual muy estrecho respecto al tamaño base del personaje.
- **Puños/patadas más estables**: se reducen los saltos de escala entre un golpe y otro.
- **Recarga y especiales más contenidos**: siguen luciendo heroicos, pero ya no invaden tanto la pantalla ni deforman la percepción del tamaño real del peleador.
- **Combo automático más sutil**: el aumento visual durante combo se baja para que no parezca otro recorte con escala distinta.

Sensación buscada:
- Menos efecto de “sprites recortados”.
- Más coherencia entre una pose y otra.
- Combate más sólido y más cercano a una animación continua.
