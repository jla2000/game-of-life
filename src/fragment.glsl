#version 450 core

uniform sampler2D render_texture;

in vec2 uv;
out vec4 color;

void main() {
  color = vec4(vec3(texture(render_texture, uv).r), 1);
}
