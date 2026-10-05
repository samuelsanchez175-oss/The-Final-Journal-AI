#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

// Nudges only the bottom of GhostIcon. Dome and eyes stay put.
[[ stitchable ]] float2 ghostHemWave(float2 position, float time, float size) {
    float span = max(size, 1.0);
    float down = position.y / span;
    float along = position.x / span;
    float hem = smoothstep(0.70, 0.84, down);
    float wave = sin(along * 18.8496 + time) * 1.5 * hem;
    return float2(position.x, position.y + wave);
}
