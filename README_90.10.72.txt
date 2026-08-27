CORE AWAKENED — 90.10.72
CALIBRACIÓN PUSHBOX 2.1 + PRESENTACIÓN DE VICTORIA

BASE
- Derivada directamente de fighter.gd 90.10.71 probado en video.
- main.gd se incluye sin modificaciones.

CAMBIO 1 — PUSHBOX POR POSE DESPUÉS DEL IMPACTO
- Puño conectado: margen visual adicional de 4 px.
- Patada conectada: margen visual adicional de 6 px.
- Trade confirmado: hasta 2 px extra.
- Máximo adicional: 8 px.
- El margen SOLO aparece cuando _atk_ya_conecto ya es verdadero.
- No modifica rango, hitbox, lunge, daño, velocidad ni precontacto.
- CORE II/III conserva el target adaptativo de 90.10.71 sin mezclar cifras.

CAMBIO 2 — GANADOR VS DERROTADO
- La separación se recalcula después de cargar la pose real de victoria.
- El ganador se recoloca, no el cuerpo derrotado.
- Usa radios visuales actuales y un piso de 220 px.
- Si un borde impide la distancia ideal, elige el lado/extremo con mayor espacio.
- No usa Tween: la presentación final queda estable.

NO TOCADO
- Daño
- IA
- Velocidad general
- Rangos de ataques
- Hitboxes
- CORE
- Gravedad
- Sprites
- Escenarios

PRUEBA RECOMENDADA
1. Pelea normal con presión cuerpo a cuerpo.
2. Puños y patadas a muy corta distancia.
3. Ataques simultáneos/trades.
4. CORE II y CORE III.
5. KO cerca del centro y cerca de los bordes.
6. Confirmar que ganador y derrotado quedan visualmente separados.
