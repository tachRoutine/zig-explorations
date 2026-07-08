const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const argv = [_][]const u8{ "echo", "hello", "zig" };

    const result = try std.process.run(gpa, io, .{
        .argv = &argv,
    });

    defer gpa.free(result.stderr);
    defer gpa.free(result.stdout);

    std.debug.print("stdout: {s}\n", .{result.stdout});
    std.debug.print("exit code: {}\n", .{result.term.exited});
}

pub fn splitStringToArrayWithdelimeter(
    gpa: std.mem.Allocator, 
    s: []const u8,
    delimiter: []const u8
)[_] [] const u8{
    var it = std.mem.splitScalar(u8, s,delimiter);
    var arrVal: std.ArrayList(u8) = .empty;
    while(it.next()) |val| {
        arrVal.append(gpa, val);
    }

    return arrVal;
}