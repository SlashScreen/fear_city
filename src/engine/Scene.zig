const std = @import("std");
const ecs = @import("ecs");

const Scene = @This();

allocator: std.mem.Allocator,
registry: ecs.Registry,
children: std.ArrayList(Scene),

fn init(alloc: std.mem.Allocator) Scene {
    return .{
        .allocator = alloc,
        .children = .empty,
        .registry = ecs.Registry.init(alloc),
    };
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
