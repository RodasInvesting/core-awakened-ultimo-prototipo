# CORE AWAKENED — Prototipo 94

Base: Prototipo 93 (secuencia narrativa del origen, antes del menú).

## Segunda secuencia: la voz de Varkhos, antes de cada Arcade/Batalla Rápida

Nueva pantalla entre el menú principal y el selector de personajes. Se
dispara al elegir **cualquiera de los dos modos** (Arcade o Batalla
Rápida) -- ambos botones ya pasaban por la misma función interna
(`_ir_selector()` en `menu_principal.gd`), así que un solo cambio ahí
cubre los dos casos.

### Flujo de escenas (antes → ahora)
```
Antes:   MenuPrincipal ──(Arcade o Rápida)──────────────► SelectorPersonajes
Ahora:   MenuPrincipal ──(Arcade o Rápida)── IntroBatalla ─► SelectorPersonajes
```

### Mismo mecanismo que la secuencia del origen (Prototipo 93)
Fundido cruzado entre láminas, música de fondo, se puede saltar en
cualquier momento con tecla/click/toque, cartelito discreto avisando que
se puede saltar. El tema que mandaste dura 34.512s; repartí las 9 láminas
sin partes iguales, dándole más aire a la "Y finalmente..." → reveal
("...encontré a aquellos capaces de despertarme") y a las dos últimas de
logo, que cierran la secuencia.

### Aprendizaje del error de tipado del prototipo anterior
Esta vez escribí `_unhandled_input()` con el cast explícito desde el
arranque (no repetí el error de leer `.pressed` sobre `InputEvent` sin
convertir primero al tipo específico) y `DURACIONES` ya nace como
`Array[float]` en vez de un array sin tipo. No debería dar el mismo
problema que la vez pasada.

## Efecto en el juego
Ahora, cada vez que se elige Arcade o Batalla Rápida, antes de llegar al
selector de personajes se ve esta secuencia -- refuerza la idea de que
Varkhos observa cada pelea (encaja con su frase ya existente, "Cada
batalla que libraron... fue para despertarme"). Se puede saltar, así que
no estorba a quien ya la vio.

## Archivos nuevos/tocados
- `scenes/IntroBatalla.tscn` (nuevo)
- `scripts/intro_batalla.gd` (nuevo)
- `scripts/menu_principal.gd` — `_ir_selector()` ahora pasa por
  `IntroBatalla.tscn` antes de `SelectorPersonajes.tscn`
- `assets/historia_batalla/slide_1.png` … `slide_9.png` (nuevos)
- `assets/sonidos/historia_batalla.mp3` (nuevo)

## Mismo pendiente de la vez pasada
Sin sistema de guardado, esta secuencia también se ve siempre, cada vez
que se entra a jugar -- no hay forma de saltarla automáticamente después
de la primera vez sin agregar persistencia.
