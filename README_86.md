# CORE AWAKENED — PROTOTIPO 86
## Fase: Sonido + Impacto Premium

Base: Prototipo 85 con los siete escenarios actualizados.

### Cambios de audio
- Banco nuevo de puñetazos con variaciones de pitch y peso.
- Banco nuevo de patadas.
- Whoosh separado para puños y patadas, incluso si el ataque no conecta.
- Sonido seco específico de bloqueo.
- Sonidos de aterrizaje y caída fuerte.
- Sonido de CORE listo.
- Recarga CORE 2 y recarga absoluta CORE 3 con capas dedicadas.
- Impacto específico del rematador.
- Impacto de graves específico del ABSOLUTO.
- Identidad sonora elemental por luchador:
  - Kai: energía oscura.
  - Helena: energía luminosa.
  - Fang: fuego.
  - Cibor-X: electricidad.
  - Kali: ácido.
  - Aethel: viento.
  - Magnus: piedra.

### Cambios de impacto visual/físico
- Onda circular de contacto que cambia de tamaño según puño, patada, especial,
  rematador, absoluto o bloqueo.
- Patadas generan más peso de cámara que los puños.
- Bloqueos tienen impacto corto y seco.
- Derribos generan caída pesada + vibración.
- Rematador y Absoluto tienen respuesta de cámara reforzada.
- Se conserva hit-stop, respuesta del piso, partículas y reacción ambiental
  de las fases anteriores.

### Integración técnica
- `Fighter` ahora expone señales detalladas de impacto, ataque, aterrizaje y CORE listo.
- El audio se reproduce con players temporales para permitir capas simultáneas sin
  cortar el sonido anterior.
- Los sistemas anteriores siguen compatibles.
