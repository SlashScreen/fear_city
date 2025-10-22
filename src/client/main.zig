const std = @import("std");
const rl = @import("raylib");
const ws = @import("websocket");
const shared = @import("shared");

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

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------
    }
}
