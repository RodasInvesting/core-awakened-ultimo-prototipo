
# Prototipo 89.3 — Fix de encuadre real

Se corrigió el fallo del selector de personajes.

Problema detectado:
- la nueva imagen del selector estaba guardada con extensión .png pero con contenido JPEG,
  lo que hacía que Godot no la cargara correctamente y apareciera pantalla negra.

Corrección aplicada:
- se volvió a guardar `assets/ui/selector_personajes.png` como PNG real.
- se mantienen el menú panorámico y el selector horizontal de rostros.
