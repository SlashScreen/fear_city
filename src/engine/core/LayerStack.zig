const std = @import("std");

const Event = @import("Event.zig");
const Layer = @import("Layer.zig");
const LayerStack = @This();

allocator: std.mem.Allocator,
stack: std.ArrayList(Layer),

pub fn new() LayerStack {
    return .{
        .allocator = undefined,
        .stack = .empty,
    };
}

pub fn init(self: *LayerStack, alloc: std.mem.Allocator) void {
    self.allocator = alloc;
}

pub fn add_layer(self: *LayerStack, layer: Layer) !void {
    try self.stack.append(self.allocator, layer);
    layer.init() catch |err| {
        std.log.err("Error executing init at layer: {any}", .{err});
    };
}

pub fn remove_top_layer(self: *LayerStack) !void {
    const l = self.stack.pop();
    if (l) |layer| {
        layer.deinit() catch |err| {
            std.log.err("Error executing deinit at layer: {any}", .{err});
        };
    }
}

pub fn tick(self: *LayerStack) !void {
    for ((self.stack.items.len - 1)..0) |idx| {
        const layer = self.stack.items[idx];
        layer.tick() catch |err| {
            std.log.err("Error executing tick at layer at {d}: {any}", .{ idx, err });
        };
    }
}

pub fn broadcast_event(self: *LayerStack, event: *Event) void {
    for ((self.stack.items.len - 1)..0) |idx| {
        if (event.consumed) {
            break;
        }

        const layer = self.stack.items[idx];
        layer.on_message(event) catch |err| {
            std.log.err("Error broadcasting event {} to layer {d}: {}", .{ event.key, idx, err });
        };
    }
}

pub fn deinit(self: *LayerStack) void {
    while (self.stack.items.len > 0) {
        const l = self.stack.pop();
        if (l) |layer| {
            layer.deinit() catch |err| {
                std.log.err("Error executing deinit at layer: {any}", .{err});
            };
        } else {
            break;
        }
    }
    self.stack.deinit(self.allocator);
}
