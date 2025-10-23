const rl = @import("raylib");

const RenderingLayer = @This();
const App = @import("../App.zig");
const Layer = @import("../Layer.zig");
const Event = @import("../Event.zig");

fn init(self: *RenderingLayer, app: *App) void {
    _ = self;
    _ = app;

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    rl.setTargetFPS(60);
}

fn update(self: *RenderingLayer, app: *App) void {
    _ = self;

    if (rl.windowShouldClose()) {
        app.close();
        return;
    }

    rl.beginDrawing();
    {
        rl.clearBackground(.white);
        rl.drawText("Yeeeeaay. Peace peace", 190, 200, 20, .light_gray);
    }
    rl.endDrawing();
}

fn shutdown(self: *RenderingLayer, app: *App) void {
    _ = self;
    _ = app;

    rl.closeWindow();
}

fn on_message(self: *RenderingLayer, event: *Event, app: *App) void {
    _ = self;
    _ = event;
    _ = app;
}

fn on_attach(self: *anyopaque, app: *App) void {
    init(@ptrCast(self), app);
}

fn on_detach(self: *anyopaque, app: *App) void {
    shutdown(@ptrCast(self), app);
}

fn on_event(self: *anyopaque, event: *Event, app: *App) void {
    on_message(@ptrCast(self), event, app);
}

fn on_update(self: *anyopaque, app: *App) void {
    update(@ptrCast(self), app);
}

pub fn as_layer(self: *RenderingLayer) Layer {
    return .{
        .name = "RenderingLayer",
        .on_attach = on_attach,
        .on_detach = on_detach,
        .on_event = on_event,
        .on_update = on_update,
        .userdata = self,
    };
}
