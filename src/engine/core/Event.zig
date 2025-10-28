const std = @import("std");

const Event = @This();

key: []const u8,
payload: ?*anyopaque,
consumed: bool,

pub fn create(comptime T: anytype, key: @Type(.enum_literal), data: ?*T) Event {
    return .{
        .key = @tagName(key),
        .payload = @ptrCast(@alignCast(data)),
        .consumed = false,
    };
}

pub fn consume(self: *Event) void {
    self.consumed = true;
}

pub fn is(self: *Event, key: @Type(.enum_literal)) bool {
    return std.mem.eql(u8, @tagName(key), self.key);
}
