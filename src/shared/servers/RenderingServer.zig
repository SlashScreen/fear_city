const std = @import("std");

pub const RenderCommand3DTag = enum {
    DrawCube,
};

pub const RenderCommand3D = union(RenderCommand3DTag) {
    DrawCube: struct {
        pos: @Vector(3, f32),
        extents: @Vector(3, f32),
        color: @Vector(4, f32),
    },
};

pub const RenderCommand = union { command_3d: RenderCommand3D };
