pub const TimeServer = @import("servers/TimeServer.zig");

const App = @This();

time_server: TimeServer,

pub fn new() App {
    return .{
        .time_server = .new(),
    };
}

pub fn tick(self: *App) void {
    self.time_server.tick();
}
