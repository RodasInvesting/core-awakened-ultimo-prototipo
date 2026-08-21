# CORE AWAKENED — Prototipo 86.1

## Integración de impactos reales

Se incorporaron al banco de audio los sonidos de pegada y bloqueo aportados por el creador.
Los MP3 originales fueron convertidos a WAV PCM 16-bit / 48 kHz para integrarlos al flujo actual del proyecto.

### Clasificación usada
- Crunchy Punch A/B -> puños medios/pesados
- Punches A1 -> puño seco
- Hard Slap C -> impacto pesado
- Slap A2 -> impacto rápido/liviano
- Punch-Kick A1/A2 -> variaciones mixtas de contacto
- Fight Kicks A1/A3 -> patadas
- Swing and Block A3 -> bloqueo

El segundo archivo Fight-Kicks-A3 era un duplicado binario exacto y no se agregó dos veces.

### Comportamiento en juego
- Los puños eligen variantes según la fuerza del golpe.
- Las patadas usan un pool independiente.
- El bloqueo usa el sonido real de swing + contacto.
- Hay variación mínima de pitch para evitar repetición sin deformar el sonido original.
- Especial, rematador y absoluto pueden superponer un impacto real pesado con los efectos de energía ya existentes.

### Nota de origen
Los nombres de los archivos originales indican procedencia de Fesliyan Studios. Conservá la documentación/licencia correspondiente de los audios originales para la publicación final del juego.
