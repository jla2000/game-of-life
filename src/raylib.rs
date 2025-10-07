use std::ffi::{c_char, c_int, c_uchar};

#[repr(C)]
pub struct Color {
    r: c_uchar,
    g: c_uchar,
    b: c_uchar,
    a: c_uchar,
}

impl Color {
    pub const WHITE: Self = Self {
        r: 0,
        g: 0,
        b: 0,
        a: 255,
    };
}

unsafe extern "C" {
    pub safe fn InitWindow(width: c_int, height: c_int, title: *const c_char);
    pub safe fn CloseWindow();
    pub safe fn WindowShouldClose() -> bool;
    pub safe fn BeginDrawing();
    pub safe fn EndDrawing();
    pub safe fn ClearBackground(color: Color);
    pub safe fn DrawFPS(pos_x: c_int, pos_y: c_int);
    pub safe fn SetTargetFPS(fps: c_int);
}
