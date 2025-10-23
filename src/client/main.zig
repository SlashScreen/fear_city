const std = @import("std");
const ws = @import("websocket");
const engine = @import("engine");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app = engine.App.init(allocator);

    var rendering_layer = engine.RenderingLayer{};
    const r_layer = rendering_layer.as_layer();

    app.add_layer(r_layer);

    app.run();

    app.shutdown();
}
