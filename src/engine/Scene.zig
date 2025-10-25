const std = @import("std");
const ecs = @import("ecs");
const engine = @import("lib.zig");

const Scene = @This();
const App = engine.App;
const ScheduleManager = engine.ScheduleManager;

allocator: std.mem.Allocator,
registry: ecs.Registry,
children: std.ArrayList(Scene),

pub fn init(alloc: std.mem.Allocator) Scene {
    return .{
        .allocator = alloc,
        .children = .empty,
        .registry = ecs.Registry.init(alloc),
    };
}

pub fn update(self: *Scene, app: *App, sm: *ScheduleManager) void {
    sm.run_schedule(.update, &self.registry, app);
    for (self.children.items) |s| {
        s.update(app, sm);
    }
}

pub fn draw(self: *Scene, app: *App, sm: *ScheduleManager) void {
    sm.run_schedule(.draw, &self.registry, app);
    for (self.children.items) |s| {
        s.draw(app, sm);
    }
}

pub const TestComponentRepresentation = union {
    TestComponent: struct {},
    CubeComponent: struct {
        extents: @Vector(3, f32),
    },
};

pub const SceneRepresentation = struct {
    entities: []struct {
        components: []TestComponentRepresentation,
    },
};
