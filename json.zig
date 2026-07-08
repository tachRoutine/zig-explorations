const std = @import("std");

const User =  struct{
    name: []const u8
};

const user_json =
    \\{"name":"Tach"}
;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const parsed_user = try std.json.parseFromSlice(User, gpa, user_json, .{});
    defer parsed_user.deinit();
    std.debug.print("user before: {s}\n",.{parsed_user.value.name});

    var user1: User = .{
        .name= "meee",
    };

    try std.json.Formatter(User).format();
    
}
