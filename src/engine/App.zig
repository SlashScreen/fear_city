const std = @import("std");

const LayerStack = @import("LayerStack.zig");
const Layer = @import("Layer.zig");
const App = @This();

layer_stack: LayerStack,
allocator: std.mem.Allocator,
should_stop: bool,

pub fn init(alloc: std.mem.Allocator) App {
    return .{
        .layer_stack = .init(alloc),
        .allocator = alloc,
        .should_stop = false,
    };
}

pub fn close(self: *App) void {
    self.should_stop = true;
}

pub fn add_layer(self: *App, layer: Layer) void {
    self.layer_stack.add_layer(layer, self);
}

pub fn run(self: *App) void {
    while (!self.should_stop) {
        self.layer_stack.update_layers(self);
    }
}

pub fn shutdown(self: *App) void {
    self.layer_stack.shutdown(self);
}
