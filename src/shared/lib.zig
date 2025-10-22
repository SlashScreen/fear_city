const std = @import("std");
const ecs = @import("ecs");
const rl = @import("raylib");

pub const config = @import("config.zig");
pub const App = @import("App.zig");

// Servers

pub const TimeServer = @import("servers/TimeServer.zig");

// Components
pub const Position = @import("components/Position.zig");

// Tags
pub const NetworkReflected = struct {};
pub const TestTag = struct {};

pub fn test_tag_update(reg: *ecs.Registry, app: *App) void {
    var view = reg.view(.{TestTag}, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        _ = entity;
        std.debug.print("update!!! dt: {} \n", .{app.time_server.delta_time});
    }
}

pub fn test_tag_draw(reg: *ecs.Registry, app: *App) void {
    _ = app;

    var view = reg.view(.{TestTag}, .{});
    var iter = view.entityIterator();

    while (iter.next()) |entity| {
        _ = entity;
        rl.drawCube(rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, 1.0, 1.0, .red);
    }
}

// ECS stuff
pub const ScheduleManager = @import("ScheduleManager.zig");
