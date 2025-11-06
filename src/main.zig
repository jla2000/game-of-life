const std = @import("std");

const c = @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});

const WIN_WIDTH = 1920;
const WIN_HEIGHT = 1080;

const GRID_SCALE = 4;
const GRID_WIDTH = WIN_WIDTH / GRID_SCALE;
const GRID_HEIGHT = WIN_HEIGHT / GRID_SCALE;

fn glfwErrorCallback(code: c_int, message: [*c]const u8) callconv(.c) void {
    std.log.err("{d}: {s}\n", .{ code, message });
}

fn compileShader(kind: c.GLenum, code: [:0]const u8) !c.GLuint {
    const shader_id = c.glCreateShader(kind);

    c.glShaderSource(shader_id, 1, &code.ptr, null);
    c.glCompileShader(shader_id);

    var compile_status: c.GLint = 0;
    c.glGetShaderiv(shader_id, c.GL_COMPILE_STATUS, &compile_status);

    if (compile_status == c.GL_FALSE) {
        var info_log = std.mem.zeroes([1024]u8);
        var info_log_len: c.GLint = 0;

        c.glGetShaderInfoLog(shader_id, info_log.len, &info_log_len, &info_log);
        std.debug.print("Error during shader compilation:\n{s}\n", .{info_log[0..@intCast(info_log_len)]});

        return error.CompilationFailed;
    } else {
        return shader_id;
    }
}

fn linkProgram(shaders: []const c.GLuint) !c.GLuint {
    const program_id = c.glCreateProgram();

    for (shaders) |shader_id| {
        c.glAttachShader(program_id, shader_id);
    }
    c.glLinkProgram(program_id);

    var link_status: c.GLint = 0;
    c.glGetProgramiv(program_id, c.GL_LINK_STATUS, &link_status);

    if (link_status == c.GL_FALSE) {
        var info_log = std.mem.zeroes([1024]u8);
        var info_log_len: c.GLint = 0;

        c.glGetProgramInfoLog(program_id, info_log.len, &info_log_len, &info_log);
        std.debug.print("Error when linking program:\n{s}\n", .{info_log[0..@intCast(info_log_len)]});

        return error.LinkingFailed;
    } else {
        return program_id;
    }
}

pub fn main() !void {
    _ = c.glfwSetErrorCallback(glfwErrorCallback);

    if (c.glfwInit() == c.GLFW_FALSE) {
        return error.GlfwInit;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(WIN_WIDTH, WIN_HEIGHT, "Game of Life", null, null) orelse {
        return error.GlfwWindow;
    };
    defer c.glfwDestroyWindow(window);

    c.glfwSetInputMode(window, c.GLFW_STICKY_KEYS, c.GLFW_TRUE);

    c.glfwMakeContextCurrent(window);
    std.debug.assert(c.epoxy_gl_version() == 45);

    var vao: c.GLuint = 0;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    const compute_shader = try compileShader(c.GL_COMPUTE_SHADER, @embedFile("compute.glsl"));
    const compute_program = try linkProgram(&[_]c.GLuint{compute_shader});

    const vert_shader = try compileShader(c.GL_VERTEX_SHADER, @embedFile("vertex.glsl"));
    const frag_shader = try compileShader(c.GL_FRAGMENT_SHADER, @embedFile("fragment.glsl"));
    const render_program = try linkProgram(&[_]c.GLuint{ vert_shader, frag_shader });

    var texture0: c.GLuint = 0;
    c.glGenTextures(1, &texture0);
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, texture0);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_R8, GRID_WIDTH, GRID_HEIGHT, 0, c.GL_RED, c.GL_UNSIGNED_BYTE, null);
    c.glBindImageTexture(0, texture0, 0, c.GL_FALSE, 0, c.GL_READ_WRITE, c.GL_R8);

    var texture1: c.GLuint = 0;
    c.glGenTextures(1, &texture1);
    c.glActiveTexture(c.GL_TEXTURE1);
    c.glBindTexture(c.GL_TEXTURE_2D, texture1);
    c.glBindImageTexture(1, texture1, 0, c.GL_FALSE, 0, c.GL_READ_WRITE, c.GL_R8UI);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_R8, GRID_WIDTH, GRID_HEIGHT, 0, c.GL_RED, c.GL_UNSIGNED_BYTE, null);
    c.glBindImageTexture(1, texture1, 0, c.GL_FALSE, 0, c.GL_READ_WRITE, c.GL_R8);

    const input_data = c.glGetUniformLocation(compute_program, "input_data");
    const output_data = c.glGetUniformLocation(compute_program, "output_data");

    std.debug.assert(input_data != -1);
    std.debug.assert(output_data != -1);

    c.glClearColor(0, 0, 0, 1);

    var input_unit: c.GLint = 0;
    var output_unit: c.GLint = 1;

    var input_texture: c.GLuint = texture0;
    var output_texture: c.GLuint = texture1;

    var running = true;
    var pressed = false;

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glMemoryBarrier(c.GL_SHADER_IMAGE_ACCESS_BARRIER_BIT | c.GL_TEXTURE_FETCH_BARRIER_BIT);
        c.glUseProgram(render_program);
        c.glUniform1i(c.glGetUniformLocation(render_program, "render_texture"), input_unit);
        c.glDrawArrays(c.GL_TRIANGLE_STRIP, 0, 4);

        if (running) {
            c.glUseProgram(compute_program);
            c.glUniform1i(input_data, input_unit);
            c.glUniform1i(output_data, output_unit);
            c.glDispatchCompute(WIN_WIDTH / 10, WIN_HEIGHT / 10, 1);

            std.mem.swap(@TypeOf(input_unit), &input_unit, &output_unit);
            std.mem.swap(@TypeOf(input_texture), &input_texture, &output_texture);
        }

        c.glfwPollEvents();
        c.glfwSwapBuffers(window);

        if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
            break;
        }

        if (c.glfwGetKey(window, c.GLFW_KEY_SPACE) == c.GLFW_PRESS) {
            if (!pressed) {
                running = !running;
                pressed = true;
            }
        } else {
            pressed = false;
        }

        if (c.glfwGetMouseButton(window, c.GLFW_MOUSE_BUTTON_1) == c.GLFW_PRESS) {
            var temp_buf: [GRID_WIDTH * GRID_HEIGHT]u8 = undefined;

            c.glMemoryBarrier(c.GL_SHADER_IMAGE_ACCESS_BARRIER_BIT | c.GL_TEXTURE_FETCH_BARRIER_BIT);
            c.glBindTexture(c.GL_TEXTURE_2D, input_texture);
            c.glGetTexImage(c.GL_TEXTURE_2D, 0, c.GL_RED, c.GL_UNSIGNED_BYTE, &temp_buf);

            var x: f64 = 0.0;
            var y: f64 = 0.0;
            c.glfwGetCursorPos(window, &x, &y);

            const grid_x: usize = @intFromFloat(x / GRID_SCALE);
            const grid_y: usize = @intFromFloat(GRID_HEIGHT - y / GRID_SCALE);
            const size = 30;

            for (0..size) |y_off| {
                for (0..size) |x_off| {
                    const idx = (grid_y + y_off -| size / 2) * GRID_WIDTH + (grid_x +| x_off -| size / 2);
                    temp_buf[idx % temp_buf.len] = 255;
                }
            }

            c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_R8, GRID_WIDTH, GRID_HEIGHT, 0, c.GL_RED, c.GL_UNSIGNED_BYTE, &temp_buf);
        }
    }
}
