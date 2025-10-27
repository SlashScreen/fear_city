const std = @import("std");

const App = @This();
const LayerStack = @import("LayerStack.zig");

allocator: std.mem.Allocator,
layer_stack: LayerStack,
running: bool,

pub fn new() App {
    return .{
        .allocator = undefined,
        .layer_stack = .new(),
        .running = true,
    };
}

pub fn init(self: *App, alloc: std.mem.Allocator) void {
    self.allocator = alloc;
    self.layer_stack.init(alloc);
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
