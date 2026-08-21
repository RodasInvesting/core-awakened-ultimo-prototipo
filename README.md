# CORE AWAKENED — Prototipo 45

Base: Prototipo 44 FIX.

Cambios principales:
- Personajes en estado normal sin tintado lila/verde/etc.; el color elemental queda reservado a Furia/efectos/UI.
- Selección manual del personaje del jugador con Q/W/E/R/T/Y/U:
  Q Kai, W Fang, E Cibor-X, R Kali, T Aethel, Y Magnus, U Helena.
- Las teclas numéricas 1–6 siguen seleccionando el rival IA.
- Si jugador y rival coinciden, el rival cambia automáticamente al siguiente personaje.
- Piso vivo: halo/iluminación ambiental por elemento, pulso suave y ondas de impacto.
- Respuesta del suelo en golpes fuertes: onda, fragmentos y luz de impacto.
- Partículas ambientales procedurales más visibles y específicas por escenario/elemento.
- Brumas, destellos y rastros de aire reforzados.
- Se mantiene la mecánica principal de CORE: 0/3 → primera carga → segunda carga/Furia → tercera carga/Absoluto.


Build 46: control humano para los 7 luchadores (Q/W/E/R/T/Y/U), más expresividad procedural de postura, ataque, bloqueo, impacto y reposo.


## Prototipo 47 — Expresividad corporal
Transferencia de peso en ataques, anticipación y recuperación, microbalance en reposo, respuesta amortiguada al impacto, luz de contacto bajo los pies y pequeñas respuestas del suelo al caminar y aterrizar. La mecánica CORE se mantiene sin cambios.


## Prototipo 80 — Derribo cinematográfico PRO
Deslizamiento al caer tras remates especiales, rebote breve contra borde de arena en derribos fuertes, recuperación más natural al levantarse y bloqueo duro de los límites del escenario.


## Prototipo 81 — Estabilidad visual y anti-bug
Se corrige un bug del segundo golpe fuerte donde el rival podía quedar colgado en la pose de impacto. Además se endurece la normalización de tamaño: recibir golpes, puños, patadas, recarga y combo quedan mucho más parejos entre sí, reduciendo el efecto de “recortes” gigantes o chicos según el PNG.


## Prototipo 82 — Corrección fina de escalas y cinemática
Se endurece la normalización de tamaños para que recibir golpes, recargas y combos queden casi al mismo tamaño base. Además, el rival ya no se libera durante el póster/remate, evitando reacciones prematuras mientras la cinemática sigue activa.


## Prototipo 83 — Normalización real de sprites
Se reemplaza la normalización por altura por una tabla precalibrada por masa alfa de todos los PNG actuales. Se elimina el crecimiento del combo y se corrige el timing de reacción para que el rival no se mueva mientras el póster sigue visible.


## Prototipo 84 — Poderes restaurados
Se mantienen los tamaños corporales estables de la 83, pero los poderes/rematadores vuelven al tamaño cinematográfico anterior: especial 320, rematador 390 y absoluto 430.
