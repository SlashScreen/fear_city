const std = @import("std");
const rl = @import("raylib");

const RenderingLayer = @This();
const App = @import("../App.zig");
const Layer = @import("../Layer.zig");
const Event = @import("../Event.zig");

const screenWidth = 800;
const screenHeight = 450;

screen_texture: ?rl.RenderTexture2D,
screen_rect: ?rl.Rectangle,

pub fn new() !RenderingLayer {
    return .{
        .screen_texture = null,
        .screen_rect = null,
    };
}

fn init(self: *RenderingLayer, app: *App) void {
    rl.initWindow(screenWidth, screenHeight, app.name);
    rl.setTargetFPS(60);

    self.screen_texture = rl.loadRenderTexture(screenWidth, screenHeight) catch |e| {
        std.log.err("Error creating screen texture: {any}", .{e});
        @panic("Uh oh sisters!!");
    };
    self.screen_rect = rl.Rectangle{
        .x = 0.0,
        .y = 0.0,
        .width = @floatFromInt(self.screen_texture.?.texture.width),
        .height = @floatFromInt(-self.screen_texture.?.texture.height),
    };
}

fn update(self: *RenderingLayer, app: *App) void {
    if (rl.windowShouldClose()) {
        app.close();
        return;
    }

    rl.beginTextureMode(self.screen_texture.?);
    {
        rl.clearBackground(.white);
        rl.drawText("Yeeeeaay. Peace peace", 190, 200, 20, .light_gray);
    }
    rl.endTextureMode();

    rl.beginDrawing();
    {
        rl.clearBackground(.black);
        rl.drawTextureRec(self.screen_texture.?.texture, self.screen_rect.?, rl.Vector2{ .x = 0.0, .y = 0.0 }, .white);
    }
    rl.endDrawing();
}

fn shutdown(self: *RenderingLayer, app: *App) void {
    _ = app;

    rl.unloadTexture(self.screen_texture.?.texture);

    rl.closeWindow();
}

fn on_message(self: *RenderingLayer, event: *Event, app: *App) void {
    _ = self;
    _ = event;
    _ = app;
}

fn on_attach(self: Layer.UserData, app: *App) void {
    init(@ptrCast(self), app);
}

fn on_detach(self: Layer.UserData, app: *App) void {
    shutdown(@ptrCast(self), app);
}

fn on_event(self: Layer.UserData, event: *Event, app: *App) void {
    on_message(@ptrCast(self), event, app);
}

fn on_update(self: Layer.UserData, app: *App) void {
    update(@ptrCast(self), app);
}

pub fn as_layer(self: *RenderingLayer) Layer {
    return .{
        .name = "RenderingLayer",
        .on_attach = on_attach,
        .on_detach = on_detach,
        .on_event = on_event,
        .on_update = on_update,
        .userdata = @ptrCast(self),
    };
}
