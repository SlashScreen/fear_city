const std = @import("std");
const ecs = @import("ecs");

const App = @import("App.zig");
const ScheduleManager = @This();

const Schedule = @import("Schedule.zig");
const System = Schedule.System;

schedules: std.AutoHashMap(*const anyopaque, Schedule),
allocator: std.mem.Allocator,

pub fn init(alloc: std.mem.Allocator) !ScheduleManager {
    return .{ .allocator = alloc, .schedules = .init(alloc) };
}

pub fn add_schedule(self: *ScheduleManager, comptime hook: @Type(.enum_literal)) !void {
    const sch: Schedule = .init(self.allocator);
    try self.schedules.put(@tagName(hook), sch);
}

pub fn add_system(self: *ScheduleManager, comptime hook: @Type(.enum_literal), system: System) !void {
    var schedule = self.schedules.getPtr(@tagName(hook)) orelse {
        std.debug.print("Add system: No schedule found for {s}", .{@tagName(hook)});
        return;
    };
    try schedule.add_system(system);
}

pub fn deinit(self: *ScheduleManager) void {
    var iter = self.schedules.valueIterator();
    while (iter.next()) |v| {
        v.deinit();
    }
}

pub fn run_schedule(self: *ScheduleManager, comptime hook: @Type(.enum_literal), reg: *ecs.Registry, app: *App) void {
    var schedule = self.schedules.getPtr(@tagName(hook)) orelse {
        std.debug.print("Run: No schedule found for {s}", .{@tagName(hook)});
        return;
    };
    schedule.run_systems(reg, app);
}
