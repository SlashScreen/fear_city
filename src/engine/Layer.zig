const Event = @import("Event.zig");
const App = @import("App.zig");

pub const PtrType = *align(@alignOf(*const fn () void)) anyopaque;
pub const UserData = *align(@alignOf(u32)) anyopaque;

name: []const u8,
userdata: UserData,

on_attach: *const fn (UserData, *App) void,
on_update: *const fn (UserData, *App) void,
on_detach: *const fn (UserData, *App) void,
on_event: *const fn (UserData, *Event, *App) void,
