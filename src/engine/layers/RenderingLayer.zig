const std = @import("std");
const core = @import("../lib.zig").Core;

const Layer = core.Layer;
const Event = core.Event;
const RenderingLayer = @This();

pub fn init(self: *RenderingLayer) !void {
    _ = self;
    std.debug.print("Initialized RenderLayer\n", .{});
}

pub fn tick(self: *RenderingLayer) !void {
    _ = self;
}

pub fn deinit(self: *RenderingLayer) !void {
    _ = self;
}

pub fn on_message(self: *RenderingLayer, event: *Event) !void {
    _ = self;
    _ = event;
}

pub fn as_layer(self: *RenderingLayer) Layer {
    return Layer.wrap(
        RenderingLayer,
        self,
        init,
        tick,
        deinit,
        on_message,
    );
}
