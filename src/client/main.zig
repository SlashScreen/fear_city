const std = @import("std");
const engine = @import("engine");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var app = engine.Core.App.init(alloc);

    var r_layer = engine.Layers.RenderingLayer{};
    const render_layer = r_layer.as_layer();

    try app.layer_stack.add_layer(render_layer);

    while (app.running) {
        app.tick();
    }

    app.deinit();
}
