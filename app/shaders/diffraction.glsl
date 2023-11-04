#include <flutter/runtime_effect.glsl>

layout(location = 0)    uniform vec2 uSize;
layout(location = 1)    uniform vec2 offset;
                        uniform sampler2D iChannel0;
                        uniform sampler2D iChannel1;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    vec3 aTexture = texture(iChannel1, uv).rgb;
    float alpha = aTexture.r * aTexture.g * aTexture.b;

    fragColor = texture(iChannel0, uv) * alpha;

//    fragColor = vec4(1.0) * alpha;
//    fragColor = vec4(1.0);
}
