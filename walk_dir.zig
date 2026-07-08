const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    // .iterate = true is required, or walk()/iterate() won't work
    var dir = try std.Io.Dir.cwd().openDir(io, "/Users/mac/work/akili/erp/backend/docs/_wms_module", .{ .iterate = true });
    defer dir.close(io);

    var walker = try dir.walk(gpa);
    defer walker.deinit();

    while (try walker.next(io)) |entry| {
        std.debug.print("path: {s}, kind: {s}\n", .{ entry.path, @tagName(entry.kind) });
    }
}