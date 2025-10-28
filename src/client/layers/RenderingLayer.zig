const std = @import("std");
const core = @import("engine").Core;
const rl = @import("raylib");

const Layer = core.Layer;
const Event = core.Event;
const RenderingLayer = @This();

const screen_w = 800;
const screen_h = 450;

render_tex: rl.RenderTexture,

pub fn init(self: *RenderingLayer, app: *core.App) !void {
    _ = app;

    rl.initWindow(screen_w, screen_h, "fear city");
    rl.setTargetFPS(60);

    self.render_tex = try rl.loadRenderTexture(screen_w, screen_h);

    std.debug.print("Initialized RenderLayer\n", .{});
}

pub fn tick(self: *RenderingLayer, app: *core.App) !void {
    if (rl.windowShouldClose()) {
        app.close();
        return;
    }

    rl.beginTextureMode(self.render_tex);
    {
        rl.clearBackground(.white);
        rl.drawText("Render texture works", 190, 200, 20, .light_gray);
    }
    rl.endTextureMode();

    rl.beginDrawing();
    {
        rl.clearBackground(.black);
        rl.drawTextureRec(
            self.render_tex.texture,
            .init(
                0.0,
                0.0,
                @floatFromInt(self.render_tex.texture.width),
                @floatFromInt(-self.render_tex.texture.height),
            ),
            .init(0.0, 0.0),
            .white,
        );
    }
    rl.endDrawing();
}

pub fn deinit(self: *RenderingLayer, app: *core.App) !void {
    _ = app;
    rl.unloadTexture(self.render_tex.texture);
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
