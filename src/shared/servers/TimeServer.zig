const std = @import("std");

const TimeServer = @This();

timer: std.time.Timer,
delta_time: f32,

pub fn new() TimeServer {
    return .{
        .delta_time = 0.0,
        .timer = std.time.Timer.start() catch {
            std.log.err("Timer unsupported on this platform. What? What are we doing here", .{});
            unreachable;
        },
    };
}

pub fn tick(self: *TimeServer) void {
    const delta_ms: f32 = @floatFromInt(self.timer.lap() / std.time.ns_per_ms);
    self.delta_time = delta_ms / std.time.ms_per_s;
}
