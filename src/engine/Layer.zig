const Event = @import("Event.zig");
const App = @import("App.zig");

name: []const u8,
userdata: *anyopaque,

on_attach: *const fn (*anyopaque, *App) void,
on_update: *const fn (*anyopaque, *App) void,
on_detach: *const fn (*anyopaque, *App) void,
on_event: *const fn (*anyopaque, *Event, *App) void,
