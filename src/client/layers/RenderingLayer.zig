const std = @import("std");
const core = @import("engine").Core;
const rl = @import("raylib");

const Layer = core.Layer;
const Event = core.Event;
const RenderingLayer = @This();

const screen_w = 800;
const screen_h = 450;

render_tex: ?rl.RenderTexture,

pub fn init(self: *RenderingLayer, app: *core.App) !void {
    _ = self;
    _ = app;

    std.debug.print("Initialized RenderLayer\n", .{});
}

pub fn tick(self: *RenderingLayer, app: *core.App) !void {
    if (rl.windowShouldClose()) {
        app.close();
        return;
    }

    if (self.render_tex) |tex| {
        rl.beginTextureMode(tex);
        {
            rl.clearBackground(.white);
            rl.drawText("Render texture works", 190, 200, 20, .light_gray);
        }
        rl.endTextureMode();

        var ev = Event.create(rl.RenderTexture, .screen_rendered, @constCast(&tex));
        app.layer_stack.broadcast_event(&ev, app);
    }
}

pub fn deinit(self: *RenderingLayer, app: *core.App) !void {
    _ = app;
    if (self.render_tex) |tex| {
        rl.unloadTexture(tex.texture);
    }
}

pub fn on_message(self: *RenderingLayer, event: *Event, app: *core.App) !void {
    _ = app;

    if (event.is(.window_created)) {
        self.render_tex = try rl.loadRenderTexture(screen_w, screen_h);
    }
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
