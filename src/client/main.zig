const std = @import("std");
const ws = @import("websocket");
const engine = @import("engine");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var app = engine.App.init(allocator, "Fear City 1975", 800, 450);

    var rl = try engine.RenderingLayer.new();
    const r_layer = rl.as_layer();
    var wl = engine.WindowLayer.new();
    const w_layer = wl.as_layer();

    app.add_layer(r_layer);
    app.add_layer(w_layer);

    app.run();

    app.shutdown();
}
