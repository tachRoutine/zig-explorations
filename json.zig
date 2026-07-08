const std = @import("std");

const User = struct { name: []const u8 };

const user_json =
    \\{"name":"Tach"}
;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;
    const cwd = std.Io.Dir.cwd();
    const file_path = "user.json";

    const json_data = try cwd.readFileAlloc(io, file_path, allocator, .unlimited);
    defer allocator.free(json_data);

    std.debug.print("raw data from {s} {s}", .{ file_path, json_data });
    const parsed_user = try std.json.parseFromSlice(User, allocator, user_json, .{});
    defer parsed_user.deinit();

    std.debug.print("user before: {s}\n", .{parsed_user.value.name});

    const user1: User = .{
        .name = "meee",
    };

    var buf: std.Io.Writer.Allocating = .init(allocator);
    defer buf.deinit();

    try buf.writer.print("{f}", .{std.json.fmt(user1, .{})});
    const json_bytes = buf.written();
    std.debug.print("After {s}\n", .{json_bytes});
}

// pub fn readJsonFile(io Io){

// }
