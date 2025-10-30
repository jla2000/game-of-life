# version 450 core

void main() {
  gl_Position.x = (gl_VertexID & 1) * 2 - 1;
  gl_Position.y = ((gl_VertexID >> 1) & 1) * 2 - 1;
  gl_Position.z = 0;
  gl_Position.w = 1;
}
