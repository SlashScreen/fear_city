const std = @import("std");
const engine = @import("engine");

const RenderingLayer = @import("layers/RenderingLayer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    var app = engine.Core.App.init(alloc);

    var r_layer = RenderingLayer{};
    const render_layer = r_layer.as_layer();

    try app.layer_stack.add_layer(render_layer, &app);

    while (app.running) {
        app.tick();
    }

    app.deinit();
}
