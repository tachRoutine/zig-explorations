const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    std.debug.print("io:{any} \n\n allocator:{any}",.{io,allocator});
}