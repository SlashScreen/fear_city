const std = @import("std");
const rl = @import("raylib");
const ws = @import("websocket");
const ecs = @import("ecs");
const shared = @import("shared");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var sm: shared.ScheduleManager = try .init(allocator);
    defer sm.deinit();

    try sm.add_schedule(.init);
    try sm.add_schedule(.update);
    try sm.add_schedule(.draw);

    var registry = ecs.Registry.init(allocator);
    var app = shared.App.new();

    const entity = registry.create();
    registry.add(entity, shared.TestTag{});

    try sm.add_system(.update, shared.test_tag_update);
    try sm.add_system(.draw, shared.test_tag_draw);

    sm.run_schedule(.init, &registry, &app);

    const camera = rl.Camera3D{
        .fovy = 45.0,
        .position = rl.Vector3{ .x = 10.0, .y = 10.0, .z = 10.0 },
        .target = rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .projection = .perspective,
        .up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 },
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        app.tick();
        sm.run_schedule(.update, &registry, &app);
        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();
        {
            rl.clearBackground(.white);

            rl.beginMode3D(camera);
            {
                sm.run_schedule(.draw, &registry, &app);
            }
            rl.endMode3D();

            rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        }
    }
}

const Handler = struct {
    client: ws.Client,

    fn init(allocator: std.mem.Allocator) !Handler {
        var client = try ws.Client.init(allocator, .{
            .port = shared.config.PORT,
            .host = "localhost",
        });
        defer client.deinit();

        // send the initial handshake request
        const request_path = "/ws";
        try client.handshake(request_path, .{
            .timeout_ms = 1000,
            .headers = "host: localhost:9224\r\n",
        });

        return .{
            .client = client,
        };
    }

    pub fn startLoop(self: *Handler) !void {
        // use readLoop for a blocking version
        const thread = try self.client.readLoopInNewThread(self);
        thread.detach();
    }

    pub fn serverMessage(self: *Handler, data: []u8) !void {
        // echo back to server
        return self.client.write(data);
    }
};
