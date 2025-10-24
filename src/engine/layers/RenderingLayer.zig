const std = @import("std");
const rl = @import("raylib");
const engine = @import("../lib.zig");

const RenderingLayer = @This();
const App = engine.App;
const Layer = engine.Layer;
const Event = engine.Event;

screen_texture: ?rl.RenderTexture2D,

pub fn new() !RenderingLayer {
    return .{
        .screen_texture = null,
    };
}

fn init(self: *RenderingLayer, app: *App) void {
    _ = self;
    _ = app;
}

fn update(self: *RenderingLayer, app: *App) void {
    var tex = self.screen_texture orelse return;

    rl.beginTextureMode(tex);
    {
        rl.clearBackground(.white);
        rl.drawText("Yeeeeaay. Peace peace", 190, 200, 20, .light_gray);
    }
    rl.endTextureMode();

    var ev = Event.new("render_texture_ready", @ptrCast(@alignCast(&tex)));
    app.broadcast_event(&ev);
}

fn shutdown(self: *RenderingLayer, app: *App) void {
    _ = app;

    rl.unloadTexture(self.screen_texture.?.texture);
}

fn on_message(self: *RenderingLayer, event: *Event, app: *App) void {
    if (std.mem.eql(u8, event.label, "window_created")) {
        self.screen_texture = rl.loadRenderTexture(@intCast(app.width), @intCast(app.height)) catch |e| {
            std.log.err("Error creating screen texture: {any}", .{e});
            @panic("Uh oh sisters!!");
        };
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

pub fn as_layer(self: *RenderingLayer) Layer {
    return .{
        .name = "RenderingLayer",
        .on_attach = on_attach,
        .on_detach = on_detach,
        .on_event = on_event,
        .on_update = on_update,
        .context = @ptrCast(@alignCast(self)),
    };
}
