# version 450 core

layout(local_size_x = 10, local_size_y = 10) in;

layout(binding = 0, r8ui) uniform uimage2D input_grid;
layout(binding = 1, r8ui) uniform uimage2D output_grid;

uint is_alive(uint x, uint y) {
  return imageLoad(input_grid, ivec2(x, y)).r;
}

void main() {
  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);

  uint neighbours = 0;
  for (uint y_off = -1; y_off <= 1; y_off += 2) {
    for (uint x_off = -1; x_off <= 1; x_off += 2) {
      neighbours += is_alive(pos.x + x_off, pos.y + y_off);
    }
  }

  uint alive = is_alive(pos.x, pos.y);
  if (neighbours == 3 || (alive == 1) && neighbours == 2) {
    alive = 1;
  } else {
    alive = 0;
  }

  imageStore(output_grid, pos, uvec4(alive, 0, 0, 0));
}
