const std = @import("std");
const engine = @import("lib.zig");

const LayerStack = @import("LayerStack.zig");
const Layer = @import("Layer.zig");
const App = @This();

name: [:0]const u8,
layer_stack: LayerStack,
allocator: std.mem.Allocator,
should_stop: bool,
width: u32,
height: u32,
fps: u32,

pub fn init(alloc: std.mem.Allocator, name: [:0]const u8, width: u32, height: u32) App {
    return .{
        .name = name,
        .layer_stack = .init(alloc),
        .allocator = alloc,
        .should_stop = false,
        .width = width,
        .height = height,
        .fps = 60,
    };
}

pub fn close(self: *App) void {
    self.should_stop = true;
}

pub fn add_layer(self: *App, layer: Layer) void {
    std.debug.print("Adding layer {s}\n", .{layer.name});
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

pub fn broadcast_event(self: *App, event: *engine.Event) void {
    self.layer_stack.broadcast_event(event, self);
}
