# CORE AWAKENED — Prototipo 86.2 / Audio real II

Esta revisión parte del Prototipo 86.1 e integra el segundo lote de sonidos reales.

## Nuevos impactos activos
- weak-punch-to-the-face -> impacto suave de puño
- short-kick -> patada corta/rápida
- punched-in-the-face -> impacto medio/fuerte a cuerpo/cara
- a-blow-with-a-fist-on-a-deaf-object -> impacto sordo/pesado

Los impactos nuevos se mezclan con el banco real de 86.1 según la fuerza del golpe.

## Reacciones vocales activas
El audio largo de gritos y respiraciones fue recortado en clips breves para uso jugable.
Actualmente las voces masculinas se asignan solamente a Kai, Fang, Aethel y Magnus.
Helena, Kali y Cibor-X quedan sin estas voces para no romper su identidad sonora.

- Reacción a golpe: probabilidad dependiente de la fuerza
- Respiraciones/dolor: impactos suaves/medios
- Gritos breves: ataques ocasionales y Furia
- Grito fuerte: recarga CORE 3 / Absoluto (con probabilidad)
- Cooldown vocal: evita gritos superpuestos en combos rápidos

## Archivos reservados
- blows-and-shouts-during-the-fight: convertido pero no usado por defecto por contener una secuencia completa.
- the-eerie-scream-of-a-bird-of-prey y the-hawk-is-screaming: guardados en `assets/sonidos/reserva_halcon/` para el futuro personaje Halcón.

## Duplicados detectados y NO reimportados
Hard-Slap-C, Crunchy-Punch-A, Crunchy-Punch-B, Fight-Kicks-A1 y Fight-Kicks-A3 recibidos en este lote son copias byte-a-byte de los que ya estaban en 86.1. También había dos copias adicionales de Fight-Kicks-A3.

Conversión de los clips nuevos: WAV PCM 16-bit, 48 kHz, mono, con normalización de nivel para mezcla de juego.
