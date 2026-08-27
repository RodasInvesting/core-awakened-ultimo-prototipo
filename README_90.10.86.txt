CORE AWAKENED 90.10.86 — PUSHBOX NEUTRAL COMPACTO

Corrección basada en el diagnóstico 90.10.85:
- J2 mostraba RAW-X=0, D-pad=0, L/R=0, DASH=0 y VX=0.
- Sin embargo su X mundial cambiaba mientras J1 hacía dash.
- El movimiento era externo al input de J2.

Cambio 90.10.86:
- El pushbox en NEUTRAL queda limitado a un máximo físico compacto de 118 px.
- Alas, cabello, sprites horizontales y poses de carrera ya no pueden convertir
  cientos de píxeles de separación en contacto corporal.
- Ataques, hitstun, bloqueo, CORE, knockback y separación post-impacto conservan
  sus reglas específicas.
- Se retira el overlay temporal de diagnóstico de 90.10.85.

Archivos modificados realmente:
- scripts/fighter.gd
- scripts/main.gd (solo se retira el overlay de diagnóstico; gameplay = 90.10.84)

Los archivos de Versus Local/selector se conservan de 90.10.85.
