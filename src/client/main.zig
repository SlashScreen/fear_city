const std = @import("std");
const engine = @import("engine");

pub fn main() !void {
    var app = engine.Core.App.new();
    const gpa = std.heap.GeneralPurposeAllocator(.{});
    app.init(gpa.allocator());

    const r_layer = engine.Layers.RenderingLayer{};
    const render_layer = r_layer.as_layer();

    app.layer_stack.add_layer(render_layer);

    while (app.running) {
        app.tick();
    }

    app.deinit();
}
