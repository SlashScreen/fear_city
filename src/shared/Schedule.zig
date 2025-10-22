const std = @import("std");
const ecs = @import("ecs");
const App = @import("App.zig");

const Schedule = @This();
const ArrayList = std.ArrayList;

pub const System = *const fn (reg: *ecs.Registry, app: *App) void;

systems: ArrayList(System),
allocator: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator) Schedule {
    return .{
        .allocator = alloc,
        .systems = ArrayList(System).empty,
    };
}

pub fn run_systems(self: *Schedule, reg: *ecs.Registry, app: *App) void {
    for (self.systems.items) |s| {
        s(reg, app);
    }
}

pub fn add_system(self: *Schedule, system: System) !void {
    try self.systems.append(self.allocator, system);
    std.debug.print("Added system {any} ({d})\n", .{ system, self.systems.items.len });
}

pub fn deinit(self: *Schedule) void {
    self.systems.deinit(self.allocator);
}
