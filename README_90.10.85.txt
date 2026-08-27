CORE AWAKENED 90.10.85 — DIAGNOSTICO J2 / BACKDASH FANTASMA

OBJETIVO
Esta versión NO intenta otra corrección especulativa. Mantiene el gameplay de 90.10.84
y agrega un overlay temporal solamente en VERSUS LOCAL para identificar de dónde nace
el desplazamiento de J2 cuando J1 hace dash.

MUESTRA EN PANTALLA
J1: L/R, DASH, VX, X y dX por frame.
J2: RAW-X del stick, D-Pad L/R, intención L/R, DASH, VX, X y dX por frame.

PRUEBA
1. VERSUS LOCAL.
2. J1 Kali con teclado; J2 Helena con el mando.
3. No tocar absolutamente el mando de J2.
4. Hacer varias veces doble flecha derecha con Kali contra Helena.
5. Grabar 5-10 segundos donde se vea el texto DEBUG.

INTERPRETACION
- Si J2 muestra RAW-X fuera de ±0.45, DP-L/DP-R=1 o L/R=1, el input viene del mando/driver.
- Si J2 mantiene RAW-X cerca de 0, L=0 R=0 DASH=0 pero VX/dX cambian, la velocidad nace de otra rutina física.

ARCHIVOS MODIFICADOS REALMENTE
scripts/fighter.gd
scripts/main.gd

Los otros cuatro archivos son idénticos a 90.10.84 y se incluyen para conservar VERSUS LOCAL.
