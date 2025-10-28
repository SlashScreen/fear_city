const std = @import("std");
const core = @import("engine").Core;
const rl = @import("raylib");

const Layer = core.Layer;
const Event = core.Event;
const WindowLayer = @This();

const screen_w = 800;
const screen_h = 450;

pub fn init(self: *WindowLayer, app: *core.App) !void {
    _ = self;

    rl.initWindow(screen_w, screen_h, "fear city");
    rl.setTargetFPS(60);

    std.debug.print("Initialized WindowLayer\n", .{});

    var ev = Event.create(u0, .window_created, null);
    app.layer_stack.broadcast_event(&ev, app);
}

pub fn tick(self: *WindowLayer, app: *core.App) !void {
    _ = self;

    if (rl.windowShouldClose()) {
        app.close();
        return;
    }
}

pub fn deinit(self: *WindowLayer, app: *core.App) !void {
    _ = self;
    _ = app;
    rl.closeWindow();
}

pub fn on_message(self: *WindowLayer, event: *Event, app: *core.App) !void {
    _ = self;
    _ = app;

    if (event.is(.screen_rendered)) {
        const tex: *rl.RenderTexture = @ptrCast(@alignCast(event.payload.?));
        rl.beginDrawing();
        {
            rl.clearBackground(.black);
            rl.drawTextureRec(
                tex.texture,
                .init(
                    0.0,
                    0.0,
                    @floatFromInt(tex.texture.width),
                    @floatFromInt(-tex.texture.height),
                ),
                .init(0.0, 0.0),
                .white,
            );
        }
        rl.endDrawing();
    }
}

pub fn as_layer(self: *WindowLayer) Layer {
    return Layer.wrap(
        WindowLayer,
        self,
        "WindowLayer",
        init,
        tick,
        deinit,
        on_message,
    );
}
