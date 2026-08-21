# Prototipo 71 — Escala estable + recarga/cámara corregidas

- Eliminado el bug de crecimiento/encogimiento al recibir golpes.
- La escala de cada pose se normaliza por su altura visible real, sin clamp contra `parado.png`.
- La recarga queda limitada a una presencia heroica moderada (~22% sobre altura normal), no pantalla completa.
- Durante el combo automático solo el atacante gana +7% de presencia visual.
- La cámara cinematográfica usa el sentido correcto de `Camera2D.zoom` (>1 acerca) y mantiene a ambos luchadores visibles.
- Antes de la recarga 2/3 el atacante se acerca al rival; luego oscurecimiento + pose de recarga + zoom; después inicia el combo.
- Reducido el tamaño de los pósters de Poder 1/Remate/Absoluto para no tapar la pelea.
