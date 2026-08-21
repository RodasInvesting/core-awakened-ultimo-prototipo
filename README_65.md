# Rodas Fighters — Prototipo 65

## Fase: Limpieza de sprites / Impactos limpios

Corrección sobre el Prototipo 64 sin tocar la lógica de combate ni Furia.

- Se reemplazaron los 3 nuevos puñetazos normales de cada luchador por recortes limpios tomados de las hojas originales suministradas.
- Se eliminaron restos de poses vecinas que habían quedado pegados en los bordes de algunos recortes.
- Se reconstruyeron las reacciones `golpe_recibido_2` y `golpe_recibido_3` de los 7 luchadores con recortes limpios.
- Se conserva `golpe_recibido.png` original para mantener la primera reacción existente.
- Se conserva todo el contenido anterior: golpes normales previos, patadas, Furia, poderes, avance hacia el rival, CORE y demás sistemas.
- Los PNG corregidos tienen fondo transparente y se recortan al contenido útil para que el sistema de normalización de tamaño de Fighter pueda mantener la escala visual.

### Prueba recomendada
1. Pulsar X repetidamente y revisar los 3 golpes nuevos de cada personaje.
2. Recibir varios golpes seguidos para comprobar que las reacciones A/B/C no muestran fragmentos negros ni de otros frames.
3. Revisar especialmente Magnus, Cibor-X, Helena y Kai, que tenían recortes problemáticos.
4. Comprobar que Furia y su combo automático siguen exactamente igual.
