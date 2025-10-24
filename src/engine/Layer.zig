const Event = @import("Event.zig");
const App = @import("App.zig");

pub const PtrType = *anyopaque;
pub const Context = *anyopaque;

name: []const u8,
context: Context,

on_attach: *const fn (Context, *App) void,
on_update: *const fn (Context, *App) void,
on_detach: *const fn (Context, *App) void,
on_event: *const fn (Context, *Event, *App) void,
