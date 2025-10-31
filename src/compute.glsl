# version 450 core

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(r8, binding = 0) uniform image2D input_data;
layout(r8, binding = 1) uniform image2D output_data;

float get_cell(uint x, uint y) {
  return imageLoad(input_data, ivec2(x, y)).r;
}

void main() {
  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);

  // uint neighbours = 0;
  // for (uint y_off = -1; y_off <= 1; y_off += 2) {
  //   for (uint x_off = -1; x_off <= 1; x_off += 2) {
  //     neighbours += is_alive(pos.x + x_off, pos.y + y_off);
  //   }
  // }
  //
  // uint alive = is_alive(pos.x, pos.y);
  // if (neighbours == 3 || (alive == 1) && neighbours == 2) {
  //   alive = 1;
  // } else {
  //   alive = 0;
  // }
  //
  // imageStore(output_data, pos, uvec4(alive, 0, 0, 0));

  float neighbours = 0;
  for (int y_off = -1; y_off <= 1; y_off += 2) {
    for (int x_off = -1; x_off <= 1; x_off += 2) {
      neighbours += get_cell(pos.x + x_off, pos.y + y_off);
    }
  }

  float self = get_cell(pos.x, pos.y);

  if (neighbours < 2 || neighbours >= 4) {
    self = 0;
  } else if (neighbours == 3) {
    self = 1;
  }

  imageStore(output_data, pos, vec4(self, 0, 0, 1));
}
