const std = @import("std");
const net = std.Io.net;
const Io = std.Io;
const http = std.http;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const addr = try net.IpAddress.parse("127.0.0.1", 8080);

    const server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    std.log.info("Server running at http://127.0.0.1:8080", .{});

    while (true) {
        const stream = server.accept(io) catch |err| {
            std.log.err("accept failed: {s}", .{@errorName(err)});
            continue;
        };

        const thread = try std.Thread.spawn(.{}, handleConnection, .{ stream, io });
        thread.detach();
    }
}

fn handleConnection(stream: net.Stream, io: Io) !void {}
