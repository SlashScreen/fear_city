const std = @import("std");

const Layer = @import("Layer.zig");
const Event = @import("Event.zig");
const App = @import("App.zig");
const LayerStack = @This();

stack: std.ArrayList(Layer),
allocator: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator) LayerStack {
    return .{
        .allocator = alloc,
        .stack = .empty,
    };
}

pub fn add_layer(self: *LayerStack, layer: Layer, app: *App) void {
    self.stack.append(self.allocator, layer) catch {
        std.log.err("Ran out of memory adding layer {s}", .{layer.name});
        return;
    };

    layer.on_attach(layer.context, app);
}

pub fn pop_layer(self: *LayerStack, app: *App) void {
    if (self.stack.pop()) |layer| {
        layer.on_detach(layer.context, app);
    }
}

pub fn update_layers(self: *LayerStack, app: *App) void {
    for (self.stack.items) |value| {
        value.on_update(value.context, app);
    }
}

pub fn broadcast_event(self: *LayerStack, event: *Event, app: *App) void {
    for (self.stack.items) |value| {
        value.on_event(value.context, event, app);
    }
}

pub fn shutdown(self: *LayerStack, app: *App) void {
    while (self.stack.items.len > 0) {
        self.pop_layer(app);
    }
}
