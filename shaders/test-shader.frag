#include <flutter/runtime_effect.glsl>

#define PI 3.14159265359
#define MAX_WAVES 4

struct Wave {
    vec3 c1; // Color1 [r,g,b]
    vec3 c2; // Color2 [r,g,b]
    vec2 d; // Direction [[-1,-1],[1,1]]
    float t; // Transition state [0,1]
};

uniform vec2 u_size;
uniform float u_modeT;
uniform float u_nWaves;
uniform Wave u_waves[MAX_WAVES];

out vec4 fragColor;

float rand (vec2 v) {
    return fract(sin(dot(v.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float rand2(vec2 v) {
    return -0.5 + rand(v);
}

mat2 rotate(float theta){
    return mat2(
    cos(theta), -sin(theta),
    sin(theta), cos(theta)
    );
}

float smoothside(vec2 a, vec2 b, vec2 p, float w) {
    vec2 ap = p - a;
    vec2 bp = p - b;
    float wn = w / max(0.0001, (ap.length() * bp.length()));
    return smoothstep(-wn, wn, ap.x * bp.y - ap.y * bp.x);
}

float quad(vec2 a, vec2 b, vec2 c, vec2 d, vec2 p, float w) {
    return smoothside(a, b, p, w)
    * smoothside(b, c, p, w)
    * smoothside(c, d, p, w)
    * smoothside (d, a, p, w);
}

float maskedge(vec2 p, float w) {
    return step(w, p.x) * step(w, p.y)
    * (1 - step(1-w, p.x)) * (1 - step(1-w, p.y));
}

float tileWaveTime(vec2 p, Wave wave) {
    float w = 0.5;// Inner tile period relative to wave period
    //    float t = waveT / w - (step(0.5, - waveDir.x) + sign(waveDir.x) * p.x) * (1 / w - 1);

    vec2 delay = (step(0.5, - wave.d) + sign(wave.d) * p) * (1 / w - 1);
    float t = wave.t / w * 1.5 - delay.x - delay.y;
    return clamp(t, 0.0, 1.0);
}

vec3 tileWaveColor(vec2 p, Wave wave) {
    return mix(wave.c1, wave.c2, tileWaveTime(p, wave));
}

vec3 tileColor(vec2 p, Wave[MAX_WAVES] waves, float n) {
    for (int i=0; i < n; i++) {

    }
}

vec4 tiles(vec2 pos, vec3 color1, vec3 color2, vec2 waveDir, float waveT) {
    vec2[6*6] v;// Tile vertices
    float vr = 0.1;// Vertex position random factor
    for (int i=0; i < 6; i++) {
        for (int j=0; j < 6; j++) {
            float rx = vr * rand2(vec2(i, j)) * step(0.5, i) * (1 - step(4.5, i));
            float ry = vr * rand2(vec2(j, i)) * step(0.5, j) * (1 - step(4.5, j));
            v[i*6 + j] = vec2(0.01 + 0.196 * i + rx, 0.01 + 0.196 * j + ry);
        }
    }

    float d = 0.01;// Tile distance from vertex
    float dr = 0.02;// Tile random distance from vertex
    float sm = 0.003;// Smoothing factor
    vec4 result = vec4(0.0, 0.0, 0.0, 0.0);
    for (int i=0; i < 5; i++) {
        for (int j=0; j < 5; j++) {
            float t = tileWaveTime(vec2(i, j) / 4.0, waveDir, waveT);
            float q = quad(
            dr * rand2(v[i*6 + j]) + mix(v[i*6 + j] + vec2(d, d), v[(i+1)*6 + j] + vec2(-d, d), t),
            dr * rand2(v[(i+1)*6 + j]) + mix(v[(i+1)*6 + j] + vec2(-d, d), v[(i+1)*6 + j+1] + vec2(-d, -d), t),
            dr * rand2(v[i*6 + j+1]) + mix(v[(i+1)*6 + j+1] + vec2(-d, -d), v[i*6 + j+1] + vec2(d, -d), t),
            dr * rand2(v[(i+1)*6 + j+1]) + mix(v[i*6 + j+1] + vec2(d, -d), v[i*6 + j] + vec2(d, d), t),
            pos,
            sm);
            result += vec4(mix(color1, color2, t) * q * (0.5 + 0.5 * rand(v[i*6 + j])), q);
        }
    }
    return result;
}

void main() {
    vec2 p = FlutterFragCoord().xy / u_size;
    p -= 0.5;

    // Rotate with transition
    p = rotate(u_modeT *  PI / 4.0) * p * (1 + 0.4142 * u_modeT);

    // Warp with transition
    float l = length(p);
    float w = 2 * l * l * l;
    p *= (1 + u_modeT * w);

    fragColor = tiles(fract(1.1 * p + 0.5), u_color1, u_color2, u_waveDir, u_waveT);

    // Final mask
    p = FlutterFragCoord().xy / u_size;
    fragColor *= maskedge(p, 0.06);
}
