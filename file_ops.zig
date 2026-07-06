const std = @import("std");

pub fn main(init: std.process.Init) void {
    const io = init.io;
    std.debug.print("hello world\n", .{});
}
