shader_type canvas_item;

// FASE 99 — viñeta de tensión. Se oscurecen los bordes de pantalla cuando
// el jugador queda en vida crítica -- refuerzo visual de la urgencia,
// además de la barra de vida. Autocontenido (solo su propia UV, no lee la
// pantalla ya renderizada), mismo criterio que destello_impacto.gdshader.

uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_vineta : source_color = vec4(0.55, 0.03, 0.05, 1.0);
uniform float dureza : hint_range(0.2, 3.0) = 1.7;

void fragment() {
	vec2 centro = vec2(0.5, 0.5);
	float dist = distance(UV, centro) * 1.4142135;
	float vineta = pow(clamp(dist, 0.0, 1.0), dureza);

	float pulso = 1.0;
	if (intensidad > 0.50) {
		pulso = 0.82 + 0.18 * sin(TIME * 5.0);
	}

	float alpha = intensidad * vineta * pulso;
	COLOR = vec4(color_vineta.rgb, alpha);
}
