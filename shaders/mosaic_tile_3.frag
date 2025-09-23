#include <flutter/runtime_effect.glsl>

#define PI 3.14159265359
#define MAX_WAVES 4
#define N 3

uniform float u_seed;
uniform vec2 u_size;
uniform float u_n;
uniform float u_brightness;
uniform float u_modeT;
uniform float u_flash;

uniform vec3 u_wC_1;
uniform vec3 u_wC_2;
uniform vec3 u_wC_3;
uniform vec3 u_wC_4;
uniform vec4 u_wDT_1;
uniform vec4 u_wDT_2;
uniform vec4 u_wDT_3;
uniform vec4 u_wDT_4;

vec3 u_wC[MAX_WAVES];
vec4 u_wDT[MAX_WAVES];

out vec4 fragColor;

float rand (vec2 v) {
    return fract(sin(dot(v.xy, vec2(12.9898, 78.233))) * 43758.5453123 * u_seed);
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
    vec2 pa = p - a;
    vec2 ba = b - a;
    vec2 baPerpNorm = normalize(vec2(-ba.y, ba.x));
    return smoothstep(-w, w, dot(pa, baPerpNorm));
}

float quad(vec2 a, vec2 b, vec2 c, vec2 d, vec2 p, float w) {
    return smoothside(a, b, p, w)
    * smoothside(b, c, p, w)
    * smoothside(c, d, p, w)
    * smoothside(d, a, p, w);
}

float tileWaveTime(vec2 p, vec4 wDT, float x) {
    float w = 0.5;// Inner tile period relative to wave period
    vec2 delay = (step(0.5, - wDT.xy) + sign(wDT.xy) * p) * (1 / w - 1);
    float t = x / w * 1.5 - delay.x - delay.y;
    return clamp(t, 0.0, 1.0);
}

float tileRotTime(vec2 p) {
    float t = 0.0;
    for (int i=0; i < MAX_WAVES; i++) {
        t += tileWaveTime(p, u_wDT[i], u_wDT[i].w);
    }
    return fract(t);
}

vec3 tileColor(vec2 p) {
    vec3 color = vec3(0.0, 0.0, 0.0);
    float drawCount = 0.0;
    for (int i=0; i < MAX_WAVES; i++) {
        float x = step(0.001, u_wDT[i].w);
        float t = ((1-x) * u_wDT[i].z + x * tileWaveTime(p, u_wDT[i], u_wDT[i].z));
        t *= max(0.0, 1.0 - drawCount);
        drawCount += t;
        color += u_wC[i] * t;
    }
    return color + u_wC[MAX_WAVES - 1] * max(0.0, 1.0 - drawCount);
}

vec4 tiles(vec2 pos, vec2 size, float brightness, float flash) {
    vec2[(N+1) * (N+1)] v;// Tile vertices
    float vr = 0.1;// Vertex position random factor
    for (int i=0; i < N + 1; i++) {
        for (int j=0; j < N + 1; j++) {
            float rx = vr * rand2(vec2(i, j)) * step(0.5, i) * (1 - step(N - 0.5, i));
            float ry = vr * rand2(vec2(j, i)) * step(0.5, j) * (1 - step(N - 0.5, j));
            v[i*(N+1) + j] = vec2(0.01 + (0.98 / N) * i + rx, 0.01 + (0.98 / N) * j + ry);
        }
    }

    float d = 0.005;// Tile distance from vertex
    float dr = 0.02;// Tile random distance from vertex
    float sm = 0.75;// Smoothing factor
    float smn = sm / size.x;
    vec3 color = vec3(0.0, 0.0, 0.0);
    float b = 0.0;
    float qq = 0.0;
    for (int i=0; i < N; i++) {
        for (int j=0; j < N; j++) {
            float t = tileRotTime(vec2(i, j) / (N-1));
            vec2 i0j0 = v[i*(N+1) + j];
            vec2 i0j1 = v[i*(N+1) + j+1];
            vec2 i1j0 = v[(i+1)*(N+1) + j];
            vec2 i1j1 = v[(i+1)*(N+1) + j+1];
            i0j0 += dr * rand2(i0j0);
            i0j1 += dr * rand2(i0j1);
            i1j0 += dr * rand2(i1j0);
            i1j1 += dr * rand2(i1j1);
            float q = quad(
            mix(i0j0 + vec2(d, d), i1j0 + vec2(-d, d), t),
            mix(i1j0 + vec2(-d, d), i1j1 + vec2(-d, -d), t),
            mix(i1j1 + vec2(-d, -d), i0j1 + vec2(d, -d), t),
            mix(i0j1 + vec2(d, -d), i0j0 + vec2(d, d), t),
            pos,
            smn);
            b += (0.65 + 0.6 * rand(v[i*N + j])) * q * brightness;
            qq += q;
            color += vec3(tileColor(vec2(i, j) / (N-1)) * q);
        }
    }

    vec3 flashed = mix(color, vec3(1.0, 1.0, 1.0), flash * qq);
    vec3 light = step(1.0, b) * mix(flashed, vec3(1.0, 1.0, 1.0), b - 1.0);
    light += step(0.0, 1.0 - b) * flashed * b;

    return vec4(light, smoothstep(0.0, 0.95, qq));
}

void main() {
    vec2 p = FlutterFragCoord().xy / u_size;

    u_wC[0] = u_wC_1;
    u_wC[1] = u_wC_2;
    u_wC[2] = u_wC_3;
    u_wC[3] = u_wC_4;

    u_wDT[0] = u_wDT_1;
    u_wDT[1] = u_wDT_2;
    u_wDT[2] = u_wDT_3;
    u_wDT[3] = u_wDT_4;

    p -= 0.5;

    // Rotate with mode
    p = rotate(u_modeT * PI / 4.0) * p * (1 + 0.4142 * u_modeT);

    // Warp with mode
    float l = length(p);
    float w = (10 * pow(1-l, 1.0) * pow(l, 4.0) - 0.3)*0.8;
    p *= (1.0 + u_modeT * w);

    // Mode light effect
    float mode = step(0.001, u_modeT);
    // Circular gradient
    float brightness = u_brightness * ((1 - mode) * pow(1-l, 0.1) + mode * 1.2 * pow(1-l, 0.2));
    // Central diamond highlight
    brightness *= (1-mode) + (mode) * (0.6 + 0.4 * (1.0 - step(0.5, max(abs(p.x), abs(p.y)) * u_modeT) * 1.0));

    fragColor = tiles(fract(p + 0.5), u_size, brightness, u_flash);
}
