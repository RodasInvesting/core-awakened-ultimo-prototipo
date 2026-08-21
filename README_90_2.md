# CORE AWAKENED — Prototipo 90.2

Base: Prototipo 90.1 (Varkhos integrado como jefe final, WIP).

## Fix: el rival quedaba "pegado" recibiendo golpes durante el combo del CORE

### Qué pasaba
En `_chequear_impacto_ataque()` había una línea que, apenas el rival
estaba congelado por la cinemática del combo automático (`congelado_por_rival`),
reducía el empuje del golpe a un 22% de lo normal:

```
if objetivo.congelado_por_rival:
    empuje_final *= 0.22
```

Ese 22% restante, encima repartido en un empuje que dura fracciones de
segundo, prácticamente no se notaba -- el rival mostraba la pose de
"recibiendo golpe" pero el cuerpo casi no se movía. Como
`_acercar_para_combo_auto()` ya recalcula la distancia real al rival
antes de cada golpe del combo, esa reducción no hacía falta para que el
combo funcionara -- era la causa directa de lo que viste.

### Qué se cambió
1. Se eliminó por completo esa reducción del 22%. Ahora el combo automático
   empuja al rival con la misma física que un golpe normal, y como
   `_acercar_para_combo_auto()` ya persigue la posición actual del rival en
   cada golpe, el resultado es justo el efecto pedido: cada golpe lo tira
   para atrás y el atacante avanza para conectar el siguiente.
2. Se agregó `MULT_EMPUJE_GLOBAL := 1.35` (mismo patrón que ya existía para
   daño y CORE: `MULT_DANO_GLOBAL`, `MULT_PODER_GLOBAL`) y se aplica a TODOS
   los golpes del juego, no solo al combo -- para que el empuje se sienta
   más presente en general, como pediste.

### Para ajustar el "feeling" más adelante
Todo el tuneo queda en un solo lugar: `MULT_EMPUJE_GLOBAL` en `fighter.gd`
(cerca de `MULT_DANO_GLOBAL`). Subirlo = golpes más espectaculares/más
empuje; bajarlo = peleas más "plantadas". El límite de desplazamiento por
golpe individual sigue acotado en `aplicar_empuje()` (clamp 35–620), así
que aunque subas mucho el multiplicador no hay riesgo de que alguien salga
disparado por la arena de un solo golpe.

Si después de probarlo un rato lo sienten fuerte de más (o de menos)
específicamente durante el combo del CORE (y no en golpes sueltos), avisen
y lo separamos en dos multiplicadores en vez de uno solo.

## Archivo tocado
- `scripts/fighter.gd` — `_chequear_impacto_ataque()`, nueva constante
  `MULT_EMPUJE_GLOBAL`
