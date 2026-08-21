# CORE AWAKENED — Prototipo 86.3

## Audio pesado y ambientación específica

### Golpes
- Se retiraron del banco activo los sonidos derivados de Slap / Hard Slap.
- También se retiraron los impactos débiles de cara que podían sonar a palmada.
- Nuevos golpes principales: boxing-strong-punch y tough-fighter-punch.
- Se agregó una capa grave `thump` debajo de puños/patadas para dar masa al contacto.
- Crunchy Punch y Punches A1 quedan como variaciones secundarias, nunca los sonidos de bofetada.
- Patadas mantienen su banco propio y reciben una capa grave en impactos fuertes.

### Kai
- `background-sound-quothuman-painquot.mp3` fue integrado como ambiente exclusivo del escenario de Kai.
- Se reproduce a volumen de fondo y se repite mientras el escenario de Kai siga activo.
- Al cambiar de escenario, el ambiente se detiene automáticamente.

### Cibor-X
- `the-stun-gun-works-intermittently.mp3` se usa como descarga/energía robótica.
- Se creó además un burst corto para acentos de golpes y Furia.
- `the-sound-of-a-space-blaster.mp3` se usa en Especial, Rematador y Absoluto de Cibor-X.
- Estos sonidos solo se disparan cuando el atacante es Cibor-X.

### Procesamiento
- Impactos convertidos a WAV PCM 16-bit / 48 kHz.
- Ambiente de Kai convertido a OGG estéreo para mantener calidad sin inflar el proyecto.
- Se controlaron picos y se reforzó el cuerpo grave de los nuevos impactos.
