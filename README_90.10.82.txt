CORE AWAKENED 90.10.82 — PUSHBOX ÚNICO / FIX ASIMETRÍA J1→J2

Cambio funcional:
- Fighter vs Fighter deja de usar la respuesta física automática de CharacterBody2D.
- La colisión con suelo/escenario permanece intacta.
- El contacto horizontal entre luchadores queda exclusivamente en el pushbox manual.
- Esto elimina la doble resolución Godot + pushbox que podía desplazar a J2 cuando J1 hacía dash.

No se modificó:
- daño
- velocidad de dash
- alcance/hitboxes
- CORE
- IA
- controles
- escenarios
- sprites

Archivo realmente modificado respecto de 90.10.81:
- scripts/fighter.gd

Prueba crítica:
1) Versus local, 1 mando conectado.
2) J1 Kali = teclado; J2 Helena = mando.
3) No tocar el mando.
4) Hacer doble flecha derecha con Kali varias veces contra Helena.
5) Kali debe frenarse en el pushbox; Helena no debe desplazarse ni entrar en movimiento por el contacto.
6) Repetir a la inversa con J2 hacia J1.
