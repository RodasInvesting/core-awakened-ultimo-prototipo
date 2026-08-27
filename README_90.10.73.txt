CORE AWAKENED 90.10.73 — HIT FEEDBACK / IMPACTO

Base: 90.10.72

Cambios deliberadamente limitados:
1. Los golpes normales ya no congelan Engine.time_scale global.
2. Hit-stop local más corto y seco para puños.
3. Hit-stop local algo mayor para patadas.
4. Especial / rematador / absoluto conservan una jerarquía de impacto superior en el receptor.
5. Cámara, audio, partículas, pushbox 2.1, daño, IA, rangos y CORE quedan intactos.

Objetivo:
Mantener el juego rápido y divertido, pero hacer que cada categoría de impacto tenga identidad propia.
Además reduce una dependencia de time_scale global que sería incómoda para el futuro multijugador/rollback.

Instalación:
Reemplazar scripts/fighter.gd y scripts/main.gd por los incluidos.

Prueba recomendada:
- 10-15 puños seguidos/intercambiados
- 10 patadas
- bloqueos
- CORE I, II y III
- observar si el puño se siente rápido y la patada claramente más pesada sin sensación de cámara lenta en cada contacto.
