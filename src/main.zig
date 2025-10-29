const std = @import("std");
const rl = @cImport({
    @cDefine("GRAPHICS_API_OPENGL_43", "");
    @cInclude("raylib.h");
    @cInclude("rlgl.h");
});

const WIN_WIDTH = 800;
const WIN_HEIGHT = 600;

const GRID_SCALE = 10;
const GRID_WIDTH = WIN_WIDTH / GRID_SCALE;
const GRID_HEIGHT = WIN_HEIGHT / GRID_SCALE;

const shader =
    \\ # version 330 core
    \\ layout(binding = 0, r8u) uniform readonly image2D input;
    \\ layout(binding = 1, r8u) uniform writeonly image2D output;
    \\ void main() {}
;

pub fn main() !void {
    var particles = std.mem.zeroes([GRID_WIDTH * GRID_HEIGHT]bool);
    var next_particles = std.mem.zeroes([GRID_WIDTH * GRID_HEIGHT]bool);

    for (0..GRID_HEIGHT * 10) |_| {
        const x: usize = @intCast(rl.GetRandomValue(0, GRID_WIDTH - 1));
        const y: usize = @intCast(rl.GetRandomValue(0, GRID_HEIGHT - 1));
        next_particles[y * GRID_WIDTH + x] = true;
    }

    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Particles");
    rl.SetWindowState(rl.FLAG_VSYNC_HINT);

    _ = rl.rlCompileShader(shader, rl.RL_COMPUTE_SHADER);

    while (!rl.WindowShouldClose()) {
        @memcpy(&particles, &next_particles);

        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);

        for (0..particles.len) |idx| {
            const x = idx % GRID_WIDTH;
            const y = (idx - x) / GRID_WIDTH;

            if (particles[idx]) {
                const radius = GRID_SCALE / 2;
                const half_radius = radius / 2;
                rl.DrawCircle(@intCast(x * GRID_SCALE + half_radius), @intCast(WIN_HEIGHT - y * GRID_SCALE - half_radius), radius, rl.WHITE);

                if (y > 0) {
                    const down_idx = (y - 1) * GRID_WIDTH + x;
                    if (!next_particles[down_idx]) {
                        next_particles[idx] = false;
                        next_particles[down_idx] = true;
                        continue;
                    }

                    if (x > 0) {
                        const down_left_idx = (y - 1) * GRID_WIDTH + (x - 1);
                        if (!next_particles[down_left_idx]) {
                            next_particles[idx] = false;
                            next_particles[down_left_idx] = true;
                            continue;
                        }
                    }

                    if (x < GRID_WIDTH - 1) {
                        const down_right_idx = (y - 1) * GRID_WIDTH + (x + 1);
                        if (!next_particles[down_right_idx]) {
                            next_particles[idx] = false;
                            next_particles[down_right_idx] = true;
                            continue;
                        }
                    }
                }
            }
        }

        rl.DrawFPS(0, 0);
        rl.EndDrawing();

        const mouse_pos = rl.GetMousePosition();
        const x: usize = @intFromFloat(mouse_pos.x);
        const y = WIN_HEIGHT - @as(usize, @intFromFloat(mouse_pos.y));

        const idx = (y / GRID_SCALE) * GRID_WIDTH + (x / GRID_SCALE);
        if (idx < next_particles.len) {
            next_particles[idx] = true;
        }
    }

    rl.CloseWindow();
}
