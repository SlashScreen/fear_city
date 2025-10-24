const Event = @This();

label: []const u8,
contents: ?*anyopaque,
consumed: bool,

pub fn new(label: []const u8, contents: ?*anyopaque) Event {
    return .{
        .label = label,
        .contents = contents,
        .consumed = false,
    };
}

pub fn consume(self: *Event) void {
    self.consumed = true;
}
