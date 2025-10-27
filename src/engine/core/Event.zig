const Event = @This();

key: []const u8,
payload: *anyopaque,
consumed: bool,

pub fn create(comptime T: anytype, key: @Type(.enum_literal), data: *T) Event {
    return .{
        .key = @typeName(key),
        .payload = @ptrCast(@alignCast(data)),
        .consumed = false,
    };
}

pub fn consume(self: *Event) void {
    self.consumed = true;
}
