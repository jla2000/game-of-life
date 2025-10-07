mod raylib;
use std::collections::HashSet;

use raylib::*;

#[derive(Hash, PartialEq, Eq)]
struct Cell {
    x: i32,
    y: i32,
}

const WINDOW_WIDTH: i32 = 800;
const WINDOW_HEIGHT: i32 = 600;

fn main() {
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, c"Game of Life".as_ptr());

    let mut cells = HashSet::new();

    for y in 0..WINDOW_HEIGHT {
        for x in 0..WINDOW_WIDTH {
            if GetRandomValue(0, 10) == 0 {
                cells.insert(Cell { x, y });
            }
        }
    }

    SetTargetFPS(60);
    while !WindowShouldClose() {
        BeginDrawing();
        ClearBackground(Color::BLACK);
        DrawFPS(0, 0);
        for cell in &cells {
            DrawPixel(cell.x, cell.y, Color::WHITE);
        }
        EndDrawing();
    }

    CloseWindow();
}
