# version 450 core

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(r8, binding = 0) uniform image2D input_data;
layout(r8, binding = 1) uniform image2D output_data;

float get_cell(uint x, uint y) {
  return imageLoad(input_data, ivec2(x, y)).r;
}

void main() {
  ivec2 pos = ivec2(gl_GlobalInvocationID.xy);

  float neighbours = 0;
  neighbours += get_cell(pos.x - 1, pos.y - 1);
  neighbours += get_cell(pos.x - 1, pos.y);
  neighbours += get_cell(pos.x - 1, pos.y + 1);
  neighbours += get_cell(pos.x, pos.y - 1);
  neighbours += get_cell(pos.x, pos.y + 1);
  neighbours += get_cell(pos.x + 1, pos.y - 1);
  neighbours += get_cell(pos.x + 1, pos.y);
  neighbours += get_cell(pos.x + 1, pos.y + 1);

  float self = get_cell(pos.x, pos.y);

  if (neighbours < 2 || neighbours >= 4) {
    self = 0;
  } else if (neighbours == 3) {
    self = 1;
  }

  imageStore(output_data, pos, vec4(self, 0, 0, 1));
}
