shader_type canvas_item;

// FASE 92: destello de pantalla completa para golpes fuertes/remates/
// absolutos. Es intencionalmente autocontenido (solo usa su propio UV,
// no lee la pantalla ya renderizada) para que compile y funcione siempre,
// sin depender de un BackBufferCopy ni de configuración extra del nodo.

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float dureza_vineta : hint_range(0.2, 3.0) = 1.4;

void fragment() {
	vec2 centro = vec2(0.5, 0.5);
	float dist = distance(UV, centro) * 1.4142135; // normaliza para que las esquinas lleguen a ~1
	float vineta = pow(clamp(dist, 0.0, 1.0), dureza_vineta);

	// Combina un destello centrado (más fuerte en el medio de la pantalla,
	// donde suele estar la acción) con un marco que se refuerza en los
	// bordes -- da la sensación de "la pantalla entera lo sintió", no solo
	// un cuadradito de color plano.
	float alpha_centro = intensidad * (1.0 - vineta * 0.62);
	float alpha_borde = intensidad * vineta * 0.55;

	COLOR = vec4(flash_color.rgb, clamp(alpha_centro + alpha_borde, 0.0, 1.0));
}
