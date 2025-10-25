const std = @import("std");
const engine = @import("../lib.zig");

const SceneLayer = @This();
const Scene = engine.Scene;
const App = engine.App;
const ScheduleManager = engine.ScheduleManager;

root_scene: ?Scene,
allocator: std.mem.Allocator,
schedule_manager: ScheduleManager,
timer: std.time.Timer,

fn update(self: *SceneLayer, app: *App) void {
    if (self.timer.read() >= std.time.ns_per_s / engine.TICKS_PER_SECOND) {
        _ = self.timer.lap();
        if (self.root_scene) |sc| {
            sc.update(app, &self.schedule_manager);
        }
    }

    if (self.root_scene) |sc| {
        sc.draw(app, &self.schedule_manager);
    }
}
