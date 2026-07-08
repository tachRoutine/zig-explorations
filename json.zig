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

    // Reading the json data from the file
    const json_data = cwd.readFileAlloc(io, file_path, allocator, .unlimited) catch | err | switch (err) {
        error.FileNotFound => {
            std.debug.print("File does not exist\n",.{});
            @panic("required config file missing");
        },
        else => unreachable
    };
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
