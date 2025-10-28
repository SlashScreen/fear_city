const std = @import("std");
const engine = @import("engine");

const RenderingLayer = @import("layers/RenderingLayer.zig");
const WindowLayer = @import("layers/WindowLayer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var app = engine.Core.App.init(alloc);

    var r_layer = RenderingLayer{
        .render_tex = null,
    };
    const render_layer = r_layer.as_layer();
    try app.layer_stack.add_layer(render_layer, &app);

    var w_layer = WindowLayer{};
    const window_layer = w_layer.as_layer();
    try app.layer_stack.add_layer(window_layer, &app);

    while (app.running) {
        app.tick();
    }

    app.deinit();
}
