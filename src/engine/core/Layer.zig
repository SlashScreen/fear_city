const Event = @import("Event.zig");
const App = @import("App.zig");
const Layer = @This();

name: []const u8,
context: *anyopaque,
vtable: VTable,

pub const VTable = struct {
    init: *const fn (*anyopaque, *App) anyerror!void,
    tick: *const fn (*anyopaque, *App) anyerror!void,
    deinit: *const fn (*anyopaque, *App) anyerror!void,
    on_message: *const fn (*anyopaque, *Event, *App) anyerror!void,
};

pub fn init(self: Layer, app: *App) !void {
    try self.vtable.init(self.context, app);
}

pub fn tick(self: Layer, app: *App) !void {
    try self.vtable.tick(self.context, app);
}

pub fn deinit(self: Layer, app: *App) !void {
    try self.vtable.deinit(self.context, app);
}

pub fn on_message(self: Layer, event: *Event, app: *App) !void {
    try self.vtable.on_message(self.context, event, app);
}

pub fn wrap(
    comptime T: anytype,
    context: *T,
    name: []const u8,
    init_fn: fn (*T, *App) anyerror!void,
    tick_fn: fn (*T, *App) anyerror!void,
    deinit_fn: fn (*T, *App) anyerror!void,
    message_fn: fn (*T, *Event, *App) anyerror!void,
) Layer {
    const wrapped = struct {
        fn init(ctx: *anyopaque, app: *App) anyerror!void {
            try init_fn(@ptrCast(@alignCast(ctx)), app);
        }

        fn tick(ctx: *anyopaque, app: *App) anyerror!void {
            try tick_fn(@ptrCast(@alignCast(ctx)), app);
        }

        fn deinit(ctx: *anyopaque, app: *App) anyerror!void {
            try deinit_fn(@ptrCast(@alignCast(ctx)), app);
        }

        fn on_message(ctx: *anyopaque, event: *Event, app: *App) anyerror!void {
            try message_fn(@ptrCast(@alignCast(ctx)), event, app);
        }
    };

    const vtable = VTable{
        .init = wrapped.init,
        .tick = wrapped.tick,
        .deinit = wrapped.deinit,
        .on_message = wrapped.on_message,
    };

    return .{
        .name = name,
        .context = @ptrCast(@alignCast(context)),
        .vtable = vtable,
    };
}
