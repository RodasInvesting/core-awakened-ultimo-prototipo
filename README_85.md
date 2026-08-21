# CORE AWAKENED — PROTOTIPO 85

Base: Prototipo 84 con los siete escenarios nuevos ya integrados.

## Fase 85 — Pulido del núcleo de pelea

### 1. Colisiones y contacto
- Hurtbox ampliada para cubrir mejor torso/cabeza del cuerpo visible.
- La caja física sigue siendo más compacta para evitar empujes a distancia.
- Altura de colisión física ajustada de forma estable, sin depender de cada PNG.
- Se conserva la normalización de escala por pose del Prototipo 84.

### 2. CORE balanceado
- Ganancia de CORE por golpe normal acotada a un rango más parejo entre personajes.
- Las patadas generan un pequeño extra de CORE por ser más lentas.
- Un golpe bloqueado entrega solo 18% de la carga normal.
- Los golpes que forman parte de una cinemática CORE ya no recargan automáticamente el siguiente CORE.

### 3. Movimiento Furia de Kai
Se conectaron assets que ya estaban dentro del proyecto pero no se usaban:
- furia_caminata_der
- furia_caminata_izq
- furia_salto
- furia_doble_salto
- furia_descenso
- furia_bloqueo
- descenso normal

### 4. Rotación de patadas
- La primera pulsación de C ahora usa patada_1.
- Las siguientes pulsaciones recorren la secuencia en orden.

### 5. Presentación de victoria
- Tras el Absoluto y la caída definitiva, el ganador entra en una pose de victoria.
- Cámara de victoria enfocada en el ganador.
- El derrotado queda atenuado para dar lectura a la escena.
- Si en el futuro existe assets/<personaje>/victoria.png, Fighter lo detecta automáticamente.
- Mientras no exista ese PNG, usa Furia parado / parado como respaldo.

### 6. Escenarios
Se mantienen los fondos nuevos del 84 actualizado:
- Kai: templo místico violeta
- Helena: santuario del dragón rosa
- Fang: templo de fuego/tigres
- Cibor-X: reactor tecnológico azul
- Kali: arena tóxica del escarabajo
- Aethel: arena celestial
- Magnus: guardián de piedra

## Pruebas recomendadas
1. Probar X/C a distintas distancias y verificar que el contacto visual registre mejor.
2. Bloquear golpes y verificar que la barra CORE suba muy poco.
3. Ejecutar CORE 1 y confirmar que el especial no auto-recargue la siguiente barra.
4. Llegar a CORE 2 y comprobar transformación, recarga, combo, remate, vuelo, caída y levantada.
5. Llegar a CORE 3 y comprobar Absoluto, caída definitiva y presentación de victoria.
6. Jugar con Kai en Furia y revisar caminata, salto, doble salto, descenso y bloqueo.
