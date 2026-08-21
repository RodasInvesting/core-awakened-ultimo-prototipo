shader_type canvas_item;

uniform float pulse_strength : hint_range(0.0, 0.08) = 0.018;
uniform float pulse_speed : hint_range(0.05, 2.0) = 0.55;
uniform float vertical_variation : hint_range(0.0, 1.0) = 0.35;
uniform float edge_breathing : hint_range(0.0, 0.06) = 0.012;
uniform float drift_strength : hint_range(0.0, 0.02) = 0.004;
uniform float energy_flash : hint_range(0.0, 0.30) = 0.0;

// FASE 87: deformación atmosférica exclusiva del fondo. La máscara evita
// deformar demasiado el piso de combate; se nota sobre fuego, bruma, energía
// y cielo, no sobre los cuerpos de los luchadores.
uniform float warp_strength : hint_range(0.0, 0.004) = 0.00035;
uniform float warp_speed : hint_range(0.05, 4.0) = 0.75;
uniform float warp_frequency : hint_range(4.0, 40.0) = 16.0;

void fragment() {
    vec2 uv = UV;
    float upper_mask = 1.0 - smoothstep(0.56, 0.84, UV.y);
    float wave_x = sin(TIME * warp_speed + UV.y * warp_frequency + UV.x * 2.7);
    float wave_y = cos(TIME * warp_speed * 0.63 + UV.x * warp_frequency * 0.72);
    uv.x += wave_x * warp_strength * upper_mask;
    uv.y += wave_y * warp_strength * 0.42 * upper_mask;

    vec4 tex = texture(TEXTURE, uv);
    float pulse = sin(TIME * pulse_speed + UV.y * 5.0 + UV.x * 1.7) * pulse_strength;
    float drift = sin(TIME * 0.17 + UV.x * 3.0) * drift_strength;
    float edge = smoothstep(0.0, 0.30, UV.x) * (1.0 - smoothstep(0.70, 1.0, UV.x));
    float vertical = smoothstep(0.0, 0.30, UV.y) * (1.0 - smoothstep(0.70, 1.0, UV.y));
    float vignette_breath = sin(TIME * 0.42 + UV.y * 3.5) * edge * vertical * edge_breathing;
    float breathing = mix(1.0, 1.0 + pulse, vertical_variation);
    vec3 rgb = tex.rgb * (breathing + drift + vignette_breath);
    rgb += tex.rgb * energy_flash * (0.45 + vertical * 0.55);
    COLOR = vec4(rgb, tex.a);
}
