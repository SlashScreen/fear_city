const Event = @This();

label: []u8,
contents: *anyopaque,
consumed: bool,

pub fn consume(self: *Event) void {
    self.consumed = true;
}
