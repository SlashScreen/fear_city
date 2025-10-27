const std = @import("std");

const Event = @import("Event.zig");
const Layer = @import("Layer.zig");
const App = @import("App.zig");
const LayerStack = @This();

allocator: std.mem.Allocator,
stack: std.ArrayList(Layer),

pub fn init(alloc: std.mem.Allocator) LayerStack {
    return .{
        .allocator = alloc,
        .stack = .empty,
    };
}

pub fn add_layer(self: *LayerStack, layer: Layer, app: *App) !void {
    try self.stack.append(self.allocator, layer);
    layer.init(app) catch |err| {
        std.log.err("Error executing init to layer {s}: {any}", .{ layer.name, err });
    };
}

pub fn remove_top_layer(self: *LayerStack, app: *App) void {
    const l = self.stack.pop();
    if (l) |layer| {
        layer.deinit(app) catch |err| {
            std.log.err("Error executing deinit to layer {s}: {any}", .{ layer.name, err });
        };
    }
}

pub fn tick(self: *LayerStack, app: *App) void {
    var it = std.mem.reverseIterator(self.stack.items);
    while (it.next()) |layer| {
        layer.tick(app) catch |err| {
            std.log.err("Error executing tick at layer at {s}: {any}", .{ layer.name, err });
        };
    }
}

pub fn broadcast_event(self: *LayerStack, event: *Event, app: *App) void {
    var it = std.mem.reverseIterator(self.stack.items);
    while (it.next()) |layer| {
        if (event.consumed) {
            break;
        }

        layer.on_message(event, app) catch |err| {
            std.log.err("Error broadcasting event {} to layer {s}: {}", .{ event.key, layer.name, err });
        };
    }
}

pub fn deinit(self: *LayerStack, app: *App) void {
    while (self.stack.items.len > 0) {
        const l = self.stack.pop();
        if (l) |layer| {
            layer.deinit(app) catch |err| {
                std.log.err("Error executing deinit to layer {s}: {any}", .{ layer.name, err });
            };
        } else {
            break;
        }
    }
    self.stack.deinit(self.allocator);
}
