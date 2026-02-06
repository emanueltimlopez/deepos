extern number time;
extern number trace_intensity;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(tex, texture_coords);

    // Subtle scanlines
    float scanline = sin(texture_coords.y * 720.0 * 3.14159) * 0.015;
    pixel.rgb -= scanline;

    // Soft vignette
    vec2 uv = texture_coords;
    float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    vignette = clamp(pow(vignette * 16.0, 0.3), 0.0, 1.0);
    pixel.rgb *= mix(1.0, vignette, 0.5);

    // Trace flicker (neutral grey, not green)
    if (trace_intensity > 0.5) {
        float flicker = sin(time * 30.0) * trace_intensity * 0.05;
        pixel.rgb += flicker;
    }

    return pixel * color;
}
