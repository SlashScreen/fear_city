const std = @import("std");
const rl = @import("raylib");
const engine = @import("../lib.zig");

const App = engine.App;
const Event = engine.Event;
const Layer = engine.Layer;
const WindowLayer = @This();

pub fn new() WindowLayer {
    return .{};
}

pub fn init(self: *WindowLayer, app: *App) void {
    _ = self;

    rl.initWindow(@intCast(app.width), @intCast(app.height), app.name);
    rl.setTargetFPS(@intCast(app.fps));

    var ev = Event.new("window_created", null);
    app.broadcast_event(&ev);

    std.debug.print("Broadcasted window created event.", .{});
}

pub fn update(self: *WindowLayer, app: *App) void {
    _ = self;

    if (rl.windowShouldClose()) {
        app.close();
    }
}

pub fn shutdown(self: *WindowLayer, app: *App) void {
    _ = self;
    _ = app;

    rl.closeWindow();
}

fn on_message(self: *WindowLayer, event: *Event, app: *App) void {
    _ = self;
    _ = app;

    if (std.mem.eql(u8, event.label, "render_texture_ready")) {
        const texture: *rl.RenderTexture = @ptrCast(@alignCast(event.contents.?));

        rl.beginDrawing();
        {
            rl.drawTextureRec(
                texture.texture,
                rl.Rectangle.init(0.0, 0.0, @floatFromInt(texture.texture.width), @floatFromInt(-texture.texture.height)),
                rl.Vector2.init(0.0, 0.0),
                .white,
            );
        }
        rl.endDrawing();
    }
}

fn on_attach(self: Layer.Context, app: *App) void {
    init(@ptrCast(@alignCast(self)), app);
}

fn on_detach(self: Layer.Context, app: *App) void {
    shutdown(@ptrCast(@alignCast(self)), app);
}

fn on_event(self: Layer.Context, event: *Event, app: *App) void {
    on_message(@ptrCast(@alignCast(self)), event, app);
}

fn on_update(self: Layer.Context, app: *App) void {
    update(@ptrCast(@alignCast(self)), app);
}

pub fn as_layer(self: *WindowLayer) Layer {
    return .{
        .name = "WindowLayer",
        .on_attach = on_attach,
        .on_detach = on_detach,
        .on_event = on_event,
        .on_update = on_update,
        .context = @ptrCast(@alignCast(self)),
    };
}
