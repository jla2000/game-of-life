const std = @import("std");

const c = @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});

const WIN_WIDTH = 800;
const WIN_HEIGHT = 600;

const GRID_SCALE = 10;
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

pub fn main() !void {
    _ = c.glfwSetErrorCallback(glfwErrorCallback);

    if (c.glfwInit() == c.GLFW_FALSE) {
        return error.GlfwInit;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 5);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(WIN_WIDTH, WIN_HEIGHT, "Particles", null, null) orelse {
        return error.GlfwWindow;
    };
    defer c.glfwDestroyWindow(window);

    c.glfwMakeContextCurrent(window);
    std.debug.assert(c.epoxy_gl_version() == 45);

    var vao: c.GLuint = 0;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    const comp_shader_id = try compileShader(c.GL_COMPUTE_SHADER, @embedFile("compute.glsl"));
    const vert_shader_id = try compileShader(c.GL_VERTEX_SHADER, @embedFile("vertex.glsl"));

    _ = comp_shader_id;
    _ = vert_shader_id;

    c.glClearColor(1.0, 1.0, 0.5, 1.0);

    while (c.glfwWindowShouldClose(window) == 0) {
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glfwPollEvents();
        c.glfwSwapBuffers(window);

        if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
            break;
        }
    }
}
