const std = @import("std");
const ecs = @import("ecs");

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

// ECS stuff
pub const ScheduleManager = @import("ScheduleManager.zig");
