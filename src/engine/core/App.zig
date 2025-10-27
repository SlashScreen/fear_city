const std = @import("std");

const App = @This();
const LayerStack = @import("LayerStack.zig");

allocator: std.mem.Allocator,
layer_stack: LayerStack,
running: bool,

pub fn init(alloc: std.mem.Allocator) App {
    return .{
        .allocator = alloc,
        .layer_stack = .init(alloc),
        .running = true,
    };
}

pub fn tick(self: *App) void {
    self.layer_stack.tick() catch |err| {
        std.log.err("Error occured during tick: {any}", .{err});
    };
}

pub fn deinit(self: *App) void {
    self.layer_stack.deinit();
}

pub fn close(self: *App) void {
    self.running = false;
}
