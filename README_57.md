# CORE AWAKENED — Prototipo 57

Cambios principales:
- Eliminada la variación de altura entre personajes en el modo normal: todos usan la misma altura visual objetivo.
- Normalización de escala por pose: salto, caída, caminata, golpes y golpe recibido conservan la altura visual del personaje de referencia.
- Derribado normalizado por ancho visual para evitar que el cuerpo tumbado se vea gigante al caer.
- Recalibrada la posición del parpadeo para cada personaje; se eliminó la posición flotante que producía una línea negra arriba de la cabeza.
- Parpadeo más limpio, corto y restringido al estado de reposo.
- Sin cambios en el sistema CORE 0/3 → poder → Furia → Absoluto.

Nota: esta build fue revisada estáticamente. Godot 4 no está disponible en el entorno de preparación para ejecutar una prueba visual completa.
