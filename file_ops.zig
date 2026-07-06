const std = @import("std");
const String: type = []const u8;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    const cwd = std.Io.Dir.cwd();

    const file = try cwd.openFile(io, "yoo.txt", .{});
    defer file.close(io);

    const stats = try file.stat(io);

    const data = try allocator.alloc(u8, stats.size);
    defer allocator.free(data);

    const bytes_read = try file.readPositionalAll(io,data,0);
    std.debug.print("{s}\n", .{data[0..bytes_read]});

    // the easy approach
    const datta = try cwd.readFileAlloc(io, "yoo.txt", allocator, .unlimited);
    defer allocator.free(datta);

    std.debug.print("{s}",.{datta});
}
