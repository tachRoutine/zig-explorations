const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // const io = init.io;
    const allocator = init.gpa;
    const string = try allocator.create([]const u8);
    defer allocator.destroy(string);
    

    std.debug.print("string:{any} \n\n allocator:{any}",.{&string,allocator});
}