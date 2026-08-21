shader_type canvas_item;

// FASE 97 — Relieve 2D sin normal maps por pose.
//
// Problema que resuelve: los luchadores son PNG planos (sin normal map),
// así que aunque hubiera una luz en escena, Godot solo los tiñe/aclara
// parejo -- no hay lado iluminado y lado en sombra, se sienten "de papel".
//
// Solución: en vez de generar y mantener un normal map por cada una de las
// ~250 poses del roster, se calcula un pseudo-normal EN VIVO a partir del
// borde de la silueta (canal alpha) de la textura que ya está puesta. El
// gradiente de alpha cerca del contorno da una dirección "hacia afuera" en
// los bordes del cuerpo, y queda plano (mirando a cámara) en el interior --
// es la técnica clásica de "sticker/vinilo abombado" que usan muchos juegos
// 2D para dar volumen sin re-trabajar el arte.
//
// fragment() dibuja el sprite a un piso de brillo ambiente (nunca negro,
// nunca cambia el look actual si no hay luces). light() SUMA el relieve
// direccional encima cuando hay una luz (Light2D) afectando al nodo.

uniform float fuerza_relieve : hint_range(0.0, 4.0) = 1.8;
uniform float piso_ambiente : hint_range(0.2, 1.0) = 0.68;
uniform float brillo_maximo : hint_range(0.0, 1.0) = 0.42;

// FASE 98b — aura de borde en Furia. Reusa el mismo gradiente de alpha que
// ya se calcula para el relieve (más grande cerca del contorno del cuerpo,
// casi cero en el interior) como máscara de "borde" para prender un aro de
// luz del color de fase del personaje, pulsando. El color se empuja por
// encima de 1.0 a propósito para que enganche con el Glow ya activo.
uniform bool en_furia = false;
uniform vec4 color_furia : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fuerza_aura : hint_range(0.0, 3.0) = 1.4;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb * piso_ambiente, tex.a);
}

void light() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.01) {
		LIGHT = vec4(0.0);
		return;
	}

	vec2 px = TEXTURE_PIXEL_SIZE * 2.0;
	float a_r = texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
	float a_l = texture(TEXTURE, UV - vec2(px.x, 0.0)).a;
	float a_d = texture(TEXTURE, UV + vec2(0.0, px.y)).a;
	float a_u = texture(TEXTURE, UV - vec2(0.0, px.y)).a;
	float dx = (a_r - a_l) * fuerza_relieve;
	float dy = (a_d - a_u) * fuerza_relieve;
	vec3 normal_falso = normalize(vec3(-dx, -dy, 1.0));

	float ndotl = clamp(dot(normal_falso, normalize(LIGHT_DIRECTION)), 0.0, 1.0);
	float extra = (1.0 - piso_ambiente) + ndotl * brillo_maximo;
	vec3 resultado = tex.rgb * LIGHT_COLOR.rgb * LIGHT_ENERGY * extra;

	if (en_furia) {
		float borde = clamp(length(vec2(dx, dy)) * 1.3, 0.0, 1.0);
		float pulso = 0.7 + 0.3 * sin(TIME * 5.5);
		resultado += color_furia.rgb * borde * pulso * fuerza_aura;
	}

	LIGHT = vec4(resultado, tex.a * LIGHT_COLOR.a);
}
