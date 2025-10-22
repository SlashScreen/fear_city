const std = @import("std");
const ws = @import("websocket");
const shared = @import("shared");
const ecs = @import("ecs");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Server

    var server = try ws.Server(Handler).init(allocator, .{
        .port = shared.config.PORT,
        .address = "127.0.0.1",
        .handshake = .{
            .timeout = 3,
            .max_size = 1024,
            // since we aren't using hanshake.headers
            // we can set this to 0 to save a few bytes.
            .max_headers = 0,
        },
    });

    var data = ServerData{};
    var server_thread = try server.listenInNewThread(&data);
    server_thread.detach();

    // ECS

    var sm: shared.ScheduleManager = try .init(allocator);
    defer sm.deinit();

    try sm.add_schedule(.init);
    try sm.add_schedule(.update);
    try sm.add_schedule(.draw);

    var registry = ecs.Registry.init(allocator);
    var app = shared.App.new();

    const entity = registry.create();
    registry.add(entity, shared.TestTag{});

    // Systems

    try sm.add_system(.update, shared.test_tag_update);

    sm.run_schedule(.init, &registry, &app);
    const threshold_ns = std.time.ns_per_s / shared.config.TICKS_PER_SECOND;
    var timer = try std.time.Timer.start();

    while (true) {
        if (timer.read() <= threshold_ns) {
            continue;
        }
        _ = timer.lap();

        app.tick();
        sm.run_schedule(.update, &registry, &app);
    }
}

// This is your application-specific wrapper around a websocket connection
const Handler = struct {
    app: *ServerData,
    conn: *ws.Conn,

    // You must define a public init function which takes
    pub fn init(h: *ws.Handshake, conn: *ws.Conn, app: *ServerData) !Handler {
        // `h` contains the initial websocket "handshake" request
        // It can be used to apply application-specific logic to verify / allow
        // the connection (e.g. valid url, query string parameters, or headers)

        _ = h; // we're not using this in our simple case

        std.debug.print("initialized server", .{});

        return .{
            .app = app,
            .conn = conn,
        };
    }

    // You must defined a public clientMessage method
    pub fn clientMessage(self: *Handler, data: []const u8) !void {
        std.debug.print("got message {s}", .{data});
        try self.conn.write(data); // echo the message back
    }
};

const ServerData = struct {};
