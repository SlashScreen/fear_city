const Event = @This();

key: @Type(.enum_literal),
payload: *anyopaque,
consumed: bool,

pub fn create(comptime T: anytype, key: @Type(.enum_literal), data: *T) Event {
    return .{
        .key = key,
        .payload = @ptrCast(@alignCast(data)),
        .consumed = false,
    };
}

pub fn consume(self: *Event) void {
    self.consumed = true;
}
