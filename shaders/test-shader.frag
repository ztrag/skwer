#include <flutter/runtime_effect.glsl>

#define PI 3.14159265359

uniform float u_time;
uniform vec2 u_size;

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

float maskEdge(vec2 p, float w) {
    return step(w, p.x) * step(w, p.y)
    * (1 - step(1-w, p.x)) * (1 - step(1-w, p.y));
}

vec4 tiles(vec2 pos, float ti) {
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
    float sm = 0.003;// Smoothing factor TODO hmmm...
    vec4 result = vec4(0.0, 0.0, 0.0, 0.0);
    for (int i=0; i < 5; i++) {
        for (int j=0; j < 5; j++) {
            float t = max(0.0, min(1.0, (ti - i*0.125) * 2));
            float q = quad(
            dr * rand2(v[i*6 + j]) + mix(v[i*6 + j] + vec2(d, d), v[(i+1)*6 + j] + vec2(-d, d), t),
            dr * rand2(v[(i+1)*6 + j]) + mix(v[(i+1)*6 + j] + vec2(-d, d), v[(i+1)*6 + j+1] + vec2(-d, -d), t),
            dr * rand2(v[i*6 + j+1]) + mix(v[(i+1)*6 + j+1] + vec2(-d, -d), v[i*6 + j+1] + vec2(d, -d), t),
            dr * rand2(v[(i+1)*6 + j+1]) + mix(v[i*6 + j+1] + vec2(d, -d), v[i*6 + j] + vec2(d, d), t),
            pos,
            sm);
            result += vec4(mix(vec3(1.0, 0.0, 0.5), vec3(0.0, 0.4, 1.0), t) * q * (0.5 + 0.5 * rand(v[i*6 + j])), q);
        }
    }
    return result;
}

void main() {
    vec2 p = FlutterFragCoord().xy / u_size;
    float t = fract(u_time * 0.2);
    //    t = 0;
    //    t = 1;
    p -= 0.5;

    // Rotate with transition
    p = rotate(t *  PI / 4.0) * p * (1 + 0.4142 * t);

    // Warp with transition
    float l = length(p);
    float w = 2 * l * l * l;
    p *= (1 + t * w);

    fragColor = tiles(fract(1.1 * p + 0.5), t);

    // Final mask
    p = FlutterFragCoord().xy / u_size;
    fragColor *= maskEdge(p, 0.06);
}
