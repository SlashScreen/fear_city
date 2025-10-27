const Event = @import("Event.zig");
const Layer = @This();

context: *anyopaque,
vtable: VTable,

pub const VTable = struct {
    init: *const fn (*anyopaque) anyerror!void,
    tick: *const fn (*anyopaque) anyerror!void,
    deinit: *const fn (*anyopaque) anyerror!void,
    on_message: *const fn (*anyopaque, *Event) anyerror!void,
};

pub fn init(self: Layer) !void {
    try self.vtable.init(self.context);
}

pub fn tick(self: Layer) !void {
    try self.vtable.tick(self.context);
}

pub fn deinit(self: Layer) !void {
    try self.vtable.deinit(self.context);
}

pub fn on_message(self: Layer, event: *Event) !void {
    try self.vtable.on_message(self.context, event);
}

pub fn wrap(
    comptime T: anytype,
    context: *T,
    init_fn: fn (*T) anyerror!void,
    tick_fn: fn (*T) anyerror!void,
    deinit_fn: fn (*T) anyerror!void,
    message_fn: fn (*T, *Event) anyerror!void,
) Layer {
    const wrapped = struct {
        fn init(ctx: *anyopaque) anyerror!void {
            try init_fn(@ptrCast(@alignCast(ctx)));
        }

        fn tick(ctx: *anyopaque) anyerror!void {
            try tick_fn(@ptrCast(@alignCast(ctx)));
        }

        fn deinit(ctx: *anyopaque) anyerror!void {
            try deinit_fn(@ptrCast(@alignCast(ctx)));
        }

        fn on_message(ctx: *anyopaque, event: *Event) anyerror!void {
            try message_fn(@ptrCast(@alignCast(ctx)), event);
        }
    };

    const vtable = VTable{
        .init = wrapped.init,
        .tick = wrapped.tick,
        .deinit = wrapped.deinit,
        .on_message = wrapped.on_message,
    };

    return .{
        .context = @ptrCast(@alignCast(context)),
        .vtable = vtable,
    };
}
