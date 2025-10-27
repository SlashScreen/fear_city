const std = @import("std");
const core = @import("engine").Core;
const rl = @import("raylib");

const Layer = core.Layer;
const Event = core.Event;
const RenderingLayer = @This();

pub fn init(self: *RenderingLayer, app: *core.App) !void {
    _ = self;
    _ = app;

    rl.initWindow(800, 450, "fear city");
    rl.setTargetFPS(60);

    std.debug.print("Initialized RenderLayer\n", .{});
}

pub fn tick(self: *RenderingLayer, app: *core.App) !void {
    _ = self;
    if (rl.windowShouldClose()) {
        app.close();
        return;
    }

    rl.beginDrawing();
    {
        rl.clearBackground(.white);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
    }
    rl.endDrawing();
}

pub fn deinit(self: *RenderingLayer, app: *core.App) !void {
    _ = self;
    _ = app;
    rl.closeWindow();
}

pub fn on_message(self: *RenderingLayer, event: *Event, app: *core.App) !void {
    _ = self;
    _ = event;
    _ = app;
}

pub fn as_layer(self: *RenderingLayer) Layer {
    return Layer.wrap(
        RenderingLayer,
        self,
        "RenderingLayer",
        init,
        tick,
        deinit,
        on_message,
    );
}
