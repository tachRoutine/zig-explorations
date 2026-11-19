const std = @import("std");

const flags = @import("flags");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    std.debug.print("helloeeee", .{});
}
