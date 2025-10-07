mod raylib;
use raylib::*;

fn main() {
    InitWindow(800, 600, c"Game of Life".as_ptr());

    SetTargetFPS(60);
    while !WindowShouldClose() {
        BeginDrawing();
        ClearBackground(Color::WHITE);
        DrawFPS(0, 0);
        EndDrawing();
    }

    CloseWindow();
}
