CORE AWAKENED 90.10.84 — PUSHBOX AUTORITATIVO / FIX DASH ASIMÉTRICO

Cambios:
- El contacto Fighter vs Fighter se resuelve UNA sola vez por frame físico.
- Main asigna lado 0 (J1) y lado 1 (J2) para una autoridad estable.
- Si un dash llega al pushbox de un rival quieto, se detiene el dash real
  (carrera_activa), no solamente velocity.x.
- El rival quieto no recibe desplazamiento por el dash del otro jugador.
- Se conservan Versus Local, selector J1/J2, escenarios e input aislado.

No se modifican daño, alcance, IA, CORE, hitboxes de ataque ni velocidad base.
