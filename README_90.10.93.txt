CORE AWAKENED 90.10.93 — INPUT ROUTER DETERMINISTA

Esta versión conserva el flujo completo de VERSUS LOCAL (menú, selector J1/J2,
selector de escenario y GameState) y reemplaza solamente fighter.gd + main.gd
por la arquitectura de input enrutado.

VERSUS LOCAL:
- 1 mando: J1 teclado Flechas/X/C/Z; J2 mando.
- 2 mandos: un mando por jugador.
- 0 mandos: J1 Flechas/X/C/Z; J2 WASD/F/G/H.

CAMBIO CLAVE:
Los Fighter no leen Input directamente en Versus Local. Main construye un Input
Frame independiente para cada jugador y lo inyecta a su Fighter. Esto elimina
cualquier cruce de flechas/dash entre J1 y J2 y deja la base correcta para red/rollback.
