const std = @import("std");
const linux = std.os.linux;

pub fn main() void {
    const msg = "hello from a raw syscall\n";
    const rc = linux.write(1, msg.ptr, msg.len); // wrapper
    const rc2 = linux.syscall3(.write, 1, @intFromPtr(msg.ptr), msg.len); // raw

    for ([_]usize{ rc, rc2 }) |r| switch (linux.errno(r)) {
        .SUCCESS => {},
        else => |e| std.debug.print("write failed: {s}\n", .{@tagName(e)}),
    };
}
