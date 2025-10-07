const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const Cell = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    rl.InitWindow(800, 600, "Game of Life");

    const allocator = std.heap.c_allocator;

    var current_cells = std.AutoHashMap(Cell, void).init(allocator);
    var next_cells = std.AutoHashMap(Cell, void).init(allocator);

    for (0..600) |y| {
        for (0..800) |x| {
            if (rl.GetRandomValue(0, 100) == 0) {
                try current_cells.put(.{ .x = @intCast(x), .y = @intCast(y) }, void{});
            }
        }
    }

    rl.SetTargetFPS(60);
    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        rl.DrawFPS(0, 0);

        var cell_iter = current_cells.iterator();
        while (cell_iter.next()) |cell| {
            rl.DrawPixel(@intCast(cell.key_ptr.x), @intCast(cell.key_ptr.y), rl.WHITE);
        }

        rl.EndDrawing();

        current_cells = next_cells;
        next_cells.clearRetainingCapacity();
        try next_cells.ensureTotalCapacity(current_cells.count());
    }
}
